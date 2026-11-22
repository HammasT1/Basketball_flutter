import 'package:basketball_game/game/basketball_game.dart';
import 'package:flame/components.dart';

/// The court background, using the theme equipped in the shop.
class MuralComponent extends SpriteComponent with HasGameReference<BasketBallGame> {

  MuralComponent(): super(priority: 0);
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite(game.equippedCourt.image!);
    size = game.worldSize;
  }
}
