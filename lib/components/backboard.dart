
import 'package:basketball_game/constants/image_assets.dart';
import 'package:flame/components.dart';

import '../game/basketball_game.dart';


class BackboardComponent extends SpriteComponent
    with HasGameReference<BasketBallGame> {

  BackboardComponent(): super(priority: 1);
  @override
  void onLoad() async{
    //load backboard component
    super.onLoad();
    sprite = await game.loadSprite(ImageAssets.stand);
    position = Vector2(game.worldSize.x*0.02,7.5);
    width = game.worldSize.x*0.94;
    height = game.worldSize.y*0.9;
    //anchor = Anchor.center;
  }
}
