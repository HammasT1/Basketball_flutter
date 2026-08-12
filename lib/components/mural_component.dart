import 'package:basketball_game/constants/image_assets.dart';
import 'package:basketball_game/game/basketball_game.dart';
import 'package:flame/components.dart';

class MuralComponent extends SpriteComponent with HasGameReference<BasketBallGame> {

  MuralComponent(): super(priority: 0);
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite(ImageAssets.bg);
    size = game.worldSize;
  }
}
