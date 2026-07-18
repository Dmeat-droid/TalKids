import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static final ScoreService _instance = ScoreService._internal();
  factory ScoreService() => _instance;
  ScoreService._internal();

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Stars
  int getStars() {
    return _prefs?.getInt('talkids_stars') ?? 0;
  }

  Future<void> addStars(int amount) async {
    int current = getStars();
    await _prefs?.setInt('talkids_stars', current + amount);
  }

  // XP
  int getXp() {
    return _prefs?.getInt('talkids_xp') ?? 0;
  }

  Future<void> addXp(int amount) async {
    int current = getXp();
    await _prefs?.setInt('talkids_xp', current + amount);
  }

  // Level (100 XP per level, starts at level 1)
  int getLevel() {
    int xp = getXp();
    return (xp / 100).floor() + 1;
  }

  // Streak
  int getStreak() {
    return _prefs?.getInt('talkids_streak') ?? 0;
  }

  // Record practice success
  Future<bool> recordPracticeSuccess(String itemId) async {
    if (_prefs == null) return false;

    // 1. Add star & XP
    await addStars(1);
    await addXp(10);

    // 2. Update streak
    await _updateStreak();

    // 3. Update practice counts per item
    String countsJson = _prefs!.getString('talkids_practice_counts') ?? '{}';
    Map<String, dynamic> counts;
    try {
      counts = jsonDecode(countsJson);
    } catch (_) {
      counts = {};
    }
    counts[itemId] = (counts[itemId] ?? 0) + 1;
    await _prefs!.setString('talkids_practice_counts', jsonEncode(counts));

    // 4. Record practice activity for weekly graph
    String activityJson = _prefs!.getString('talkids_practice_activity') ?? '{}';
    Map<String, dynamic> activity;
    try {
      activity = jsonDecode(activityJson);
    } catch (_) {
      activity = {};
    }
    
    // Use date string format YYYY-MM-DD
    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}";
    activity[todayKey] = (activity[todayKey] ?? 0) + 1;
    await _prefs!.setString('talkids_practice_activity', jsonEncode(activity));

    return true;
  }

  // Helper: format two digits
  String _twoDigits(int n) => n >= 10 ? "$n" : "0$n";

  // Update streak logic
  Future<void> _updateStreak() async {
    String? lastDateStr = _prefs!.getString('talkids_last_practice_date');
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (lastDateStr == null) {
      // First time practicing
      await _prefs!.setInt('talkids_streak', 1);
      await _prefs!.setString('talkids_last_practice_date', today.toIso8601String());
      return;
    }

    DateTime lastDate;
    try {
      lastDate = DateTime.parse(lastDateStr);
    } catch (_) {
      lastDate = today;
    }
    DateTime lastPracticeDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

    int differenceInDays = today.difference(lastPracticeDay).inDays;

    if (differenceInDays == 1) {
      // Practiced on the consecutive day
      int currentStreak = getStreak();
      await _prefs!.setInt('talkids_streak', currentStreak + 1);
      await _prefs!.setString('talkids_last_practice_date', today.toIso8601String());
    } else if (differenceInDays > 1) {
      // Streak broken
      await _prefs!.setInt('talkids_streak', 1);
      await _prefs!.setString('talkids_last_practice_date', today.toIso8601String());
    } else if (differenceInDays == 0) {
      // Already practiced today, streak remains same, but we update date
      await _prefs!.setString('talkids_last_practice_date', today.toIso8601String());
    }
  }

  // Get practice count for each item
  Map<String, int> getPracticeCounts() {
    if (_prefs == null) return {};
    String countsJson = _prefs!.getString('talkids_practice_counts') ?? '{}';
    try {
      Map<String, dynamic> decoded = jsonDecode(countsJson);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (_) {
      return {};
    }
  }

  // Get weekly practice activity: list of 7 items representing counts from last 7 days (including today)
  List<int> getWeeklyActivity() {
    if (_prefs == null) return List.filled(7, 0);
    String activityJson = _prefs!.getString('talkids_practice_activity') ?? '{}';
    Map<String, dynamic> activity = {};
    try {
      activity = jsonDecode(activityJson);
    } catch (_) {}

    List<int> weeklyCounts = [];
    DateTime now = DateTime.now();
    
    // Get last 7 days including today, ordered from 6 days ago until today
    for (int i = 6; i >= 0; i--) {
      DateTime targetDate = now.subtract(Duration(days: i));
      String dateKey = "${targetDate.year}-${_twoDigits(targetDate.month)}-${_twoDigits(targetDate.day)}";
      weeklyCounts.add(activity[dateKey] ?? 0);
    }

    return weeklyCounts;
  }
}
