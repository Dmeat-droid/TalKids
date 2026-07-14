/* ==========================================================================
   TALKIDS APP LOGIC
   ========================================================================== */

// App State
const state = {
  // Calibration thresholds (loaded from localStorage or defaults)
  thresholds: {
    mouth: parseFloat(localStorage.getItem('thresh_mouth')) || 0.35,
    audio: parseFloat(localStorage.getItem('thresh_audio')) || 0.03,
  },
  stars: parseInt(localStorage.getItem('talkids_stars')) || 0,
  targetDuration: 1.0, // target duration in seconds to hold the vowel
  isRecording: false,
  isMouthOpen: false,
  isSoundActive: false,
  startTime: null,
  isSuccessTriggered: false,
  smoothVolume: 0,
  particles: []
};

// DOM Elements
const webcamElement = document.getElementById('webcam');
const canvasElement = document.getElementById('canvas');
const ctx = canvasElement.getContext('2d');
const loadingOverlay = document.getElementById('loading-overlay');
const successOverlay = document.getElementById('success-overlay');
const btnContinue = document.getElementById('btn-continue');
const btnSettings = document.getElementById('btn-settings');
const btnCloseSettings = document.getElementById('btn-close-settings');
const btnResetCalibration = document.getElementById('btn-reset-calibration');
const calibrationDrawer = document.getElementById('calibration-drawer');

// Telemetry & Indicators
const badgeMouth = document.getElementById('badge-mouth');
const badgeSound = document.getElementById('badge-sound');
const barMouth = document.getElementById('bar-mouth');
const barAudio = document.getElementById('bar-audio');
const threshMouthLine = document.getElementById('thresh-mouth-line');
const threshAudioLine = document.getElementById('thresh-audio-line');
const progressRingBar = document.getElementById('progress-ring-bar');
const timerText = document.getElementById('timer-text');
const starCountBadge = document.getElementById('star-count');
const starsContainer = document.getElementById('stars-container');

// Settings Sliders
const sliderThreshMouth = document.getElementById('slider-thresh-mouth');
const sliderThreshAudio = document.getElementById('slider-thresh-audio');
const lblThreshMouth = document.getElementById('lbl-thresh-mouth');
const lblThreshAudio = document.getElementById('lbl-thresh-audio');

// PWA installation
let deferredPrompt;
const btnInstall = document.getElementById('btn-install');

// Web Audio API variables
let audioContext;
let analyser;
let micStream;
let javascriptNode;

// Particle Canvas for Effects
const effectsCanvas = document.getElementById('effects-canvas');
const effectsCtx = effectsCanvas.getContext('2d');

/* ==========================================================================
   INITIALIZATION & PERMISSIONS
   ========================================================================== */

// Handle PWA installation prompt
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  btnInstall.classList.remove('hidden');
});

btnInstall.addEventListener('click', async () => {
  if (!deferredPrompt) return;
  deferredPrompt.prompt();
  const { outcome } = await deferredPrompt.userChoice;
  console.log(`User response to install prompt: ${outcome}`);
  deferredPrompt = null;
  btnInstall.classList.add('hidden');
});

// Setup Start State on Load
window.addEventListener('DOMContentLoaded', () => {
  // Update threshold UI lines and values
  updateSlidersUI();
  updateStarShelfUI();
  
  // Setup particle canvas size
  resizeEffectsCanvas();
  window.addEventListener('resize', resizeEffectsCanvas);
  
  // Render loop for particles
  requestAnimationFrame(particleRenderLoop);

  // Add click to start on loading overlay (required for Web Audio Context auto-play policy)
  setupStartTrigger();
});

function setupStartTrigger() {
  loadingOverlay.innerHTML = `
    <div class="welcome-box">
      <svg class="smiley-star" viewBox="0 0 100 100" width="80" height="80" style="margin-bottom: 1rem;">
        <path d="M 50 5 L 63 35 L 95 38 L 70 60 L 78 92 L 50 75 L 22 92 L 30 60 L 5 38 L 37 35 Z" fill="#fbbf24" stroke="#d97706" stroke-width="4" stroke-linejoin="round"/>
        <circle cx="40" cy="45" r="5" fill="#1e293b"/>
        <circle cx="60" cy="45" r="5" fill="#1e293b"/>
        <path d="M 38 58 Q 50 68 62 58" fill="none" stroke="#1e293b" stroke-width="4" stroke-linecap="round"/>
      </svg>
      <h2 style="margin-bottom: 0.5rem; font-weight:800;">Hai! Selamat Datang</h2>
      <p style="color:#94a3b8; font-size:0.95rem; margin-bottom: 1.5rem; max-width:280px; margin-left:auto; margin-right:auto;">
        Yuk belajar melafalkan suara bersama TalKids! Kami perlu izin kamera dan mikrofonmu ya.
      </p>
      <button id="btn-start-app" class="btn-primary">Mulai Sekarang ➔</button>
    </div>
  `;

  document.getElementById('btn-start-app').addEventListener('click', async () => {
    loadingOverlay.innerHTML = `
      <div class="spinner"></div>
      <p>Mengaktifkan Kamera & Mikrofon...</p>
    `;
    try {
      await initAudio();
      initFaceMesh();
    } catch (err) {
      console.error(err);
      loadingOverlay.innerHTML = `
        <div class="error-box" style="padding: 1.5rem; color:#f43f5e;">
          <span style="font-size:3rem;">⚠️</span>
          <h3 style="margin-top: 0.5rem;">Izin Ditolak</h3>
          <p style="color:#94a3b8; font-size:0.9rem; margin-top:0.5rem; max-width: 300px;">
            Aplikasi butuh akses kamera dan mikrofon untuk mendeteksi suara dan gerakan bibirmu. Silakan izinkan di browser.
          </p>
          <button onclick="location.reload()" class="btn-primary" style="margin-top: 1rem; padding: 0.6rem 1.2rem;">Coba Lagi</button>
        </div>
      `;
    }
  });
}

// Web Audio API Initialization
async function initAudio() {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
  micStream = stream;
  audioContext = new (window.AudioContext || window.webkitAudioContext)();
  analyser = audioContext.createAnalyser();
  analyser.fftSize = 256;
  
  const source = audioContext.createMediaStreamSource(stream);
  source.connect(analyser);
  
  // Periodically process audio volume
  const bufferLength = analyser.frequencyBinCount;
  const dataArray = new Uint8Array(bufferLength);
  
  const processAudio = () => {
    if (!micStream) return;
    
    // Get time domain data for RMS
    analyser.getByteTimeDomainData(dataArray);
    
    let sumSquares = 0;
    for (let i = 0; i < bufferLength; i++) {
      const normalizedValue = (dataArray[i] - 128) / 128; // -1.0 to 1.0
      sumSquares += normalizedValue * normalizedValue;
    }
    
    const rms = Math.sqrt(sumSquares / bufferLength);
    
    // Smooth the volume changes to avoid flickering UI
    state.smoothVolume = 0.8 * state.smoothVolume + 0.2 * rms;
    
    // Audio threshold validation
    state.isSoundActive = state.smoothVolume >= state.thresholds.audio;
    
    // Update audio level indicator bar (scaled to max expected amplitude of 0.15)
    const audioLevelPct = Math.min((state.smoothVolume / 0.15) * 100, 100);
    barAudio.style.width = `${audioLevelPct}%`;
    
    // Update badge status
    if (state.isSoundActive) {
      badgeSound.className = 'status-badge success';
      badgeSound.querySelector('.text').innerText = 'Bersuara';
      barAudio.style.background = 'linear-gradient(90deg, #10b981, #34d399)';
    } else {
      badgeSound.className = 'status-badge error';
      badgeSound.querySelector('.text').innerText = 'Diam';
      barAudio.style.background = 'linear-gradient(90deg, #6366f1, #a5b4fc)';
    }
    
    // Trigger loop
    if (state.isRecording) {
      requestAnimationFrame(processAudio);
    }
  };
  
  state.isRecording = true;
  requestAnimationFrame(processAudio);
}

// MediaPipe FaceMesh Initialization
function initFaceMesh() {
  const faceMesh = new FaceMesh({
    locateFile: (file) => `https://cdn.jsdelivr.net/npm/@mediapipe/face_mesh/${file}`
  });

  faceMesh.setOptions({
    maxNumFaces: 1,
    refineLandmarks: true,
    minDetectionConfidence: 0.5,
    minTrackingConfidence: 0.5
  });

  faceMesh.onResults(onFaceMeshResults);

  // Initialize camera helper
  const camera = new Camera(webcamElement, {
    onFrame: async () => {
      await faceMesh.send({ image: webcamElement });
    },
    width: 640,
    height: 480
  });
  
  camera.start()
    .then(() => {
      // Hide loading overlay once camera feeds frame
      loadingOverlay.classList.add('hidden');
    })
    .catch((err) => {
      console.error("Camera failed to start:", err);
      throw err;
    });
}

/* ==========================================================================
   AI COMPUTER VISION & VALIDATION CORE
   ========================================================================== */

// Mouth / Lip Landmark Indices
const LIP_INNER_TOP = 13;
const LIP_INNER_BOTTOM = 14;
const LIP_CORNER_LEFT = 78;
const LIP_CORNER_RIGHT = 308;

const LIP_CONTOUR_INDICES = [
  78, 191, 80, 81, 82, 13, 312, 311, 310, 415, 
  308, 324, 318, 402, 317, 14, 87, 178, 88, 95
];

function onFaceMeshResults(results) {
  // Sync canvas size to video size
  if (canvasElement.width !== webcamElement.videoWidth) {
    canvasElement.width = webcamElement.videoWidth;
    canvasElement.height = webcamElement.videoHeight;
  }

  // Clear Canvas
  ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);

  if (results.multiFaceLandmarks && results.multiFaceLandmarks.length > 0) {
    const landmarks = results.multiFaceLandmarks[0];
    
    // Scale normalized landmarks to pixel coordinates
    const getPixelPt = (idx) => ({
      x: landmarks[idx].x * canvasElement.width,
      y: landmarks[idx].y * canvasElement.height
    });

    const p13 = getPixelPt(LIP_INNER_TOP);
    const p14 = getPixelPt(LIP_INNER_BOTTOM);
    const p78 = getPixelPt(LIP_CORNER_LEFT);
    const p308 = getPixelPt(LIP_CORNER_RIGHT);

    // Calculate vertical and horizontal distances
    const verticalDist = Math.hypot(p13.x - p14.x, p13.y - p14.y);
    const horizontalDist = Math.hypot(p78.x - p308.x, p78.y - p308.y);
    
    // Mouth open ratio
    const mouthRatio = verticalDist / Math.max(horizontalDist, 1);
    
    // Evaluate if mouth is open wide enough for "A"
    state.isMouthOpen = mouthRatio >= state.thresholds.mouth;

    // Update mouth level UI bar (capped at max ratio 0.8)
    const mouthPercent = Math.min((mouthRatio / 0.8) * 100, 100);
    barMouth.style.width = `${mouthPercent}%`;

    // Draw glowing lip contour
    drawGlowingLips(landmarks, state.isMouthOpen);

    // Update mouth status badge
    if (state.isMouthOpen) {
      badgeMouth.className = 'status-badge success';
      badgeMouth.querySelector('.text').innerText = 'Mulut Terbuka';
      barMouth.style.background = 'linear-gradient(90deg, #10b981, #34d399)';
    } else {
      badgeMouth.className = 'status-badge error';
      badgeMouth.querySelector('.text').innerText = 'Mulut Tertutup';
      barMouth.style.background = 'linear-gradient(90deg, #6366f1, #a5b4fc)';
    }

    // Run Synchronous Validation
    runValidationLogic();

  } else {
    // Face not detected
    resetValidation();
    badgeMouth.className = 'status-badge error';
    badgeMouth.querySelector('.text').innerText = 'Wajah Tidak Terdeteksi';
    barMouth.style.width = '0%';
  }
}

function drawGlowingLips(landmarks, isOpen) {
  ctx.save();
  ctx.beginPath();
  
  const startPt = landmarks[LIP_CONTOUR_INDICES[0]];
  ctx.moveTo(startPt.x * canvasElement.width, startPt.y * canvasElement.height);
  
  for (let i = 1; i < LIP_CONTOUR_INDICES.length; i++) {
    const pt = landmarks[LIP_CONTOUR_INDICES[i]];
    ctx.lineTo(pt.x * canvasElement.width, pt.y * canvasElement.height);
  }
  ctx.closePath();

  // Glow styles
  ctx.lineWidth = isOpen ? 6 : 4;
  ctx.strokeStyle = isOpen ? '#10b981' : '#f43f5e';
  ctx.shadowColor = isOpen ? '#10b981' : '#f43f5e';
  ctx.shadowBlur = isOpen ? 15 : 5;
  ctx.fillStyle = isOpen ? 'rgba(16, 185, 129, 0.25)' : 'rgba(244, 63, 94, 0.15)';
  
  ctx.fill();
  ctx.stroke();
  ctx.restore();
}

/* ==========================================================================
   SYNCHRONOUS VALIDATION LOGIC (1.0 SECOND HOLD)
   ========================================================================== */

function runValidationLogic() {
  const isConditionsMet = state.isMouthOpen && state.isSoundActive;
  
  if (state.isSuccessTriggered) return; // Prevent double trigger

  if (isConditionsMet) {
    if (!state.startTime) {
      state.startTime = Date.now();
    }
    
    const elapsedMs = Date.now() - state.startTime;
    const elapsedSec = elapsedMs / 1000;
    const progress = Math.min((elapsedSec / state.targetDuration) * 100, 100);
    
    // Update Circular Progress
    updateProgressRing(progress, elapsedSec);
    
    if (elapsedSec >= state.targetDuration) {
      triggerSuccess();
    }
  } else {
    resetValidation();
  }
}

function resetValidation() {
  state.startTime = null;
  updateProgressRing(0, 0);
}

function updateProgressRing(progress, elapsedSec) {
  const radius = 50;
  const circumference = 2 * Math.PI * radius; // 314.16
  const offset = circumference - (progress / 100) * circumference;
  
  progressRingBar.style.strokeDashoffset = offset;
  timerText.innerText = `${elapsedSec.toFixed(1)}s`;
  
  // Glow progress ring when active
  if (progress > 0) {
    progressRingBar.style.filter = 'drop-shadow(0 0 8px #6366f1)';
    progressRingBar.style.stroke = '#10b981'; // Green progress color
  } else {
    progressRingBar.style.filter = 'none';
    progressRingBar.style.stroke = '#6366f1'; // Blue default color
  }
}

/* ==========================================================================
   VISUAL REWARDS / GAMIFICATION SYSTEM
   ========================================================================== */

function triggerSuccess() {
  state.isSuccessTriggered = true;
  
  // 1. Play Full-Screen Confetti Particle Explosion
  spawnConfettiExplosion();
  
  // 2. Increment score & Save to storage
  state.stars += 1;
  localStorage.setItem('talkids_stars', state.stars);
  
  // 3. Update UI
  updateStarShelfUI();
  
  // 4. Show success modal with delay for particles visual
  setTimeout(() => {
    successOverlay.classList.remove('hidden');
  }, 400);
}

function updateStarShelfUI() {
  starCountBadge.innerText = `⭐ ${state.stars}`;
  
  if (state.stars === 0) {
    starsContainer.innerHTML = `<p class="empty-shelf-text">Ayo kumpulkan bintang pertamamu!</p>`;
    return;
  }
  
  // Render stars shelf
  starsContainer.innerHTML = '';
  // Max display shelf capacity, loop and create elements
  const starsToDisplay = Math.min(state.stars, 24); // Cap display elements, but count increases
  for (let i = 0; i < starsToDisplay; i++) {
    const star = document.createElement('span');
    star.className = 'star-icon';
    star.innerText = '⭐';
    star.style.animationDelay = `${i * 0.05}s`;
    starsContainer.appendChild(star);
  }
  
  if (state.stars > 24) {
    const overflowBadge = document.createElement('span');
    overflowBadge.className = 'val-badge';
    overflowBadge.innerText = `+${state.stars - 24}`;
    starsContainer.appendChild(overflowBadge);
  }
}

// Reset Success Overlay to Try Again
btnContinue.addEventListener('click', () => {
  successOverlay.classList.add('hidden');
  state.isSuccessTriggered = false;
  resetValidation();
});

/* ==========================================================================
   PARTICLE ENGINE (CUSTOM CANVAS EMITTER)
   ========================================================================== */

function resizeEffectsCanvas() {
  effectsCanvas.width = window.innerWidth;
  effectsCanvas.height = window.innerHeight;
}

class Particle {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    // Exploding outwards speed
    const angle = Math.random() * Math.PI * 2;
    const speed = 2 + Math.random() * 8;
    this.vx = Math.cos(angle) * speed;
    this.vy = Math.sin(angle) * speed - 2; // slight upward drift
    
    this.size = 10 + Math.random() * 15;
    this.color = `hsl(${Math.random() * 360}, 90%, 65%)`;
    this.alpha = 1;
    this.gravity = 0.15;
    this.type = Math.random() > 0.4 ? 'star' : 'circle';
    this.rotation = Math.random() * Math.PI;
    this.rotSpeed = (Math.random() - 0.5) * 0.1;
  }

  update() {
    this.vy += this.gravity;
    this.x += this.vx;
    this.y += this.vy;
    this.alpha -= 0.015;
    this.rotation += this.rotSpeed;
  }

  draw(c) {
    c.save();
    c.globalAlpha = this.alpha;
    c.translate(this.x, this.y);
    c.rotate(this.rotation);
    c.fillStyle = this.color;
    
    if (this.type === 'star') {
      // Draw 5-pointed star
      c.beginPath();
      for (let i = 0; i < 5; i++) {
        c.lineTo(Math.cos((18 + i * 72) * Math.PI / 180) * this.size,
                 Math.sin((18 + i * 72) * Math.PI / 180) * this.size);
        c.lineTo(Math.cos((54 + i * 72) * Math.PI / 180) * (this.size / 2),
                 Math.sin((54 + i * 72) * Math.PI / 180) * (this.size / 2));
      }
      c.closePath();
      c.fill();
    } else {
      c.beginPath();
      c.arc(0, 0, this.size / 2, 0, Math.PI * 2);
      c.fill();
    }
    c.restore();
  }
}

function spawnConfettiExplosion() {
  const x = window.innerWidth / 2;
  const y = window.innerHeight / 2;
  
  for (let i = 0; i < 80; i++) {
    state.particles.push(new Particle(x, y));
  }
}

function particleRenderLoop() {
  effectsCtx.clearRect(0, 0, effectsCanvas.width, effectsCanvas.height);
  
  // Filter out faded particles
  state.particles = state.particles.filter(p => p.alpha > 0);
  
  // Draw remaining
  state.particles.forEach(p => {
    p.update();
    p.draw(effectsCtx);
  });
  
  requestAnimationFrame(particleRenderLoop);
}

/* ==========================================================================
   CALIBRATION & SETTINGS SYSTEM
   ========================================================================== */

function updateSlidersUI() {
  // Update thresholds inputs
  sliderThreshMouth.value = state.thresholds.mouth;
  sliderThreshAudio.value = state.thresholds.audio;
  
  // Update labels
  lblThreshMouth.innerText = state.thresholds.mouth.toFixed(2);
  lblThreshAudio.innerText = state.thresholds.audio.toFixed(2);
  
  // Update visual lines in the card
  // Mouth threshold line: scale is 0 to 0.8
  const mouthLinePct = (state.thresholds.mouth / 0.8) * 100;
  threshMouthLine.style.left = `${mouthLinePct}%`;
  
  // Audio threshold line: scale is 0 to 0.15
  const audioLinePct = (state.thresholds.audio / 0.15) * 100;
  threshAudioLine.style.left = `${audioLinePct}%`;
}

// Sliders event listeners
sliderThreshMouth.addEventListener('input', (e) => {
  const val = parseFloat(e.target.value);
  state.thresholds.mouth = val;
  localStorage.setItem('thresh_mouth', val);
  updateSlidersUI();
});

sliderThreshAudio.addEventListener('input', (e) => {
  const val = parseFloat(e.target.value);
  state.thresholds.audio = val;
  localStorage.setItem('thresh_audio', val);
  updateSlidersUI();
});

// Calibration Reset
btnResetCalibration.addEventListener('click', () => {
  state.thresholds.mouth = 0.35;
  state.thresholds.audio = 0.03;
  localStorage.setItem('thresh_mouth', 0.35);
  localStorage.setItem('thresh_audio', 0.03);
  updateSlidersUI();
});

// Drawer toggle
btnSettings.addEventListener('click', () => {
  calibrationDrawer.classList.add('open');
});

btnCloseSettings.addEventListener('click', () => {
  calibrationDrawer.classList.remove('open');
});

// Close drawer if user clicks outside of it
window.addEventListener('click', (e) => {
  if (e.target === calibrationDrawer) {
    calibrationDrawer.classList.remove('open');
  }
});
