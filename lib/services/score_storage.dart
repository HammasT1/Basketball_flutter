import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saves and loads the player's best score on the device.
class ScoreStorage {
  ScoreStorage._();

  static const String _highScoreKey = 'high_score';

  /// Returns the saved high score, or 0 if there is none (or storage fails).
  static Future<int> loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_highScoreKey) ?? 0;
    } catch (e) {
      debugPrint('Could not load high score: $e');
      return 0;
    }
  }

  static Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, score);
    } catch (e) {
      debugPrint('Could not save high score: $e');
    }
  }
}
