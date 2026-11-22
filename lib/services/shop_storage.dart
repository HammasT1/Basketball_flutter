import 'package:basketball_game/shop/shop_catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the shop needs to remember between app launches.
class ShopState {
  final int coins;
  final Set<String> owned;
  final String equippedBallId;
  final String equippedCourtId;

  const ShopState({
    required this.coins,
    required this.owned,
    required this.equippedBallId,
    required this.equippedCourtId,
  });

  ShopItem get equippedBall => ShopCatalog.ballById(equippedBallId);
  ShopItem get equippedCourt => ShopCatalog.courtById(equippedCourtId);

  bool owns(ShopItem item) => item.isFree || owned.contains(item.id);

  bool isEquipped(ShopItem item) => item.category == ShopCategory.ball
      ? item.id == equippedBallId
      : item.id == equippedCourtId;

  static const ShopState initial = ShopState(
    coins: 0,
    owned: {},
    equippedBallId: ShopCatalog.defaultBallId,
    equippedCourtId: ShopCatalog.defaultCourtId,
  );
}

/// Saves coins, unlocked items and equipped items on the device.
class ShopStorage {
  ShopStorage._();

  static const String _coinsKey = 'coins';
  static const String _ownedKey = 'owned_items';
  static const String _ballKey = 'equipped_ball';
  static const String _courtKey = 'equipped_court';

  static Future<ShopState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return ShopState(
        coins: prefs.getInt(_coinsKey) ?? 0,
        owned: (prefs.getStringList(_ownedKey) ?? const <String>[]).toSet(),
        equippedBallId: prefs.getString(_ballKey) ?? ShopCatalog.defaultBallId,
        equippedCourtId:
            prefs.getString(_courtKey) ?? ShopCatalog.defaultCourtId,
      );
    } catch (e) {
      debugPrint('Could not load shop data: $e');
      return ShopState.initial;
    }
  }

  /// Adds coins earned in a round. Returns the new total.
  static Future<int> addCoins(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int total = (prefs.getInt(_coinsKey) ?? 0) + amount;
      await prefs.setInt(_coinsKey, total);
      return total;
    } catch (e) {
      debugPrint('Could not save coins: $e');
      return 0;
    }
  }

  /// Spends coins on [item] and unlocks it. Returns false if the player can't
  /// afford it (or already owns it).
  static Future<bool> buy(ShopItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int coins = prefs.getInt(_coinsKey) ?? 0;
      final List<String> owned = prefs.getStringList(_ownedKey) ?? <String>[];
      if (item.isFree || owned.contains(item.id) || coins < item.price) {
        return false;
      }
      await prefs.setInt(_coinsKey, coins - item.price);
      await prefs.setStringList(_ownedKey, [...owned, item.id]);
      return true;
    } catch (e) {
      debugPrint('Could not complete purchase: $e');
      return false;
    }
  }

  static Future<void> equip(ShopItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          item.category == ShopCategory.ball ? _ballKey : _courtKey, item.id);
    } catch (e) {
      debugPrint('Could not equip item: $e');
    }
  }
}
