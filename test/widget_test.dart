import 'package:basketball_game/game/basketball_game.dart';
import 'package:basketball_game/services/score_storage.dart';
import 'package:basketball_game/services/shop_storage.dart';
import 'package:basketball_game/shop/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Scoring, streaks and On Fire', () {
    late BasketBallGame game;

    setUp(() => game = BasketBallGame());

    test('a basket is worth 1 point and extends the streak', () {
      expect(game.registerBasket(), 1);
      expect(game.score.value, 1);
      expect(game.streak.value, 1);
      expect(game.onFire.value, isFalse);
    });

    test('3 baskets in a row set the player on fire for double points', () {
      for (var i = 0; i < BasketBallGame.fireStreak; i++) {
        game.registerBasket();
      }
      expect(game.onFire.value, isTrue);
      expect(game.score.value, 3);

      expect(game.registerBasket(), BasketBallGame.fireMultiplier);
      expect(game.score.value, 5);
    });

    test('a miss resets the streak and puts the fire out', () {
      for (var i = 0; i < 4; i++) {
        game.registerBasket();
      }
      game.registerMiss();
      expect(game.streak.value, 0);
      expect(game.onFire.value, isFalse);
      expect(game.registerBasket(), 1);
    });

    test('nothing is scored once the round is over', () {
      game.isGameOver = true;
      expect(game.registerBasket(), 0);
      expect(game.score.value, 0);
    });

    test('resetScore clears score, streak, fire and dunk charge', () {
      for (var i = 0; i < 4; i++) {
        game.registerBasket();
        game.chargeDunk();
      }
      game.resetScore();
      expect(game.score.value, 0);
      expect(game.streak.value, 0);
      expect(game.onFire.value, isFalse);
      expect(game.dunkCharge.value, 0);
    });
  });

  group('Dunk meter', () {
    test('charges up to the limit and then stays full', () {
      final game = BasketBallGame();
      expect(game.isDunkReady, isFalse);
      for (var i = 0; i < BasketBallGame.dunkChargeNeeded + 2; i++) {
        game.chargeDunk();
      }
      expect(game.dunkCharge.value, BasketBallGame.dunkChargeNeeded);
      expect(game.isDunkReady, isTrue);
    });
  });

  group('Shop catalog', () {
    test('ids are unique and the defaults are free', () {
      final all = [...ShopCatalog.balls, ...ShopCatalog.courts];
      expect(all.map((i) => i.id).toSet().length, all.length);
      expect(ShopCatalog.ballById(ShopCatalog.defaultBallId).isFree, isTrue);
      expect(ShopCatalog.courtById(ShopCatalog.defaultCourtId).isFree, isTrue);
    });

    test('every court has an image and unknown ids fall back to the default',
        () {
      for (final court in ShopCatalog.courts) {
        expect(court.image, isNotNull);
      }
      expect(ShopCatalog.ballById('missing').id, ShopCatalog.defaultBallId);
      expect(ShopCatalog.courtById('missing').id, ShopCatalog.defaultCourtId);
    });
  });

  group('Saved data', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('high score round-trips', () async {
      expect(await ScoreStorage.loadHighScore(), 0);
      await ScoreStorage.saveHighScore(42);
      expect(await ScoreStorage.loadHighScore(), 42);
    });

    test('new players start with defaults and no coins', () async {
      final state = await ShopStorage.load();
      expect(state.coins, 0);
      expect(state.equippedBall.id, ShopCatalog.defaultBallId);
      expect(state.equippedCourt.id, ShopCatalog.defaultCourtId);
    });

    test('buying needs enough coins and deducts the price', () async {
      final ice = ShopCatalog.ballById('ball_ice');

      expect(await ShopStorage.buy(ice), isFalse);

      await ShopStorage.addCoins(ice.price + 10);
      expect(await ShopStorage.buy(ice), isTrue);

      final state = await ShopStorage.load();
      expect(state.coins, 10);
      expect(state.owns(ice), isTrue);

      // can't buy the same item twice
      expect(await ShopStorage.buy(ice), isFalse);
    });

    test('equipping an item is remembered', () async {
      final court = ShopCatalog.courtById('court_hardwood');
      await ShopStorage.equip(court);
      final state = await ShopStorage.load();
      expect(state.equippedCourt.id, court.id);
      expect(state.isEquipped(court), isTrue);
    });
  });
}
