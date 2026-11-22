import 'package:basketball_game/components/backboard.dart';
import 'package:basketball_game/components/ball.dart';
import 'package:basketball_game/components/boundary.dart';
import 'package:basketball_game/components/mural_component.dart';
import 'package:basketball_game/components/rim.dart';
import 'package:basketball_game/constants/audio.dart';
import 'package:basketball_game/services/score_storage.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

//declaring all game overlays here
enum GameOverlays { gameOver, main, scoreboard }

class BasketBallGame extends Forge2DGame
    with HasCollisionDetection {
  late Timer _timer;

  //Timer for the game
  ValueNotifier<int> timer = ValueNotifier(30);

  //Notifier for the game score
  ValueNotifier<int> score = ValueNotifier(0);
  bool startedGame = false;

  /// Swiped baskets needed to charge one dunk.
  static const int dunkChargeNeeded = 3;

  /// Progress towards the next dunk, from 0 to [dunkChargeNeeded].
  ValueNotifier<int> dunkCharge = ValueNotifier(0);

  bool get isDunkReady => dunkCharge.value >= dunkChargeNeeded;

  /// Called when a swiped (not dunked) shot goes in. Charges the dunk meter.
  void chargeDunk() {
    if (dunkCharge.value < dunkChargeNeeded) {
      dunkCharge.value += 1;
    }
  }

  /// Baskets in a row needed to go "on fire".
  static const int fireStreak = 3;

  /// Points per basket are multiplied by this while on fire.
  static const int fireMultiplier = 2;

  /// Consecutive baskets without a miss.
  ValueNotifier<int> streak = ValueNotifier(0);

  /// True while the player is on fire: every basket is worth double.
  ValueNotifier<bool> onFire = ValueNotifier(false);

  /// Set while the round is over, so balls cleared at the buzzer don't count
  /// as missed shots.
  bool isGameOver = false;

  /// Best score ever, saved on the device.
  int highScore = 0;

  /// True when the round that just ended beat the previous [highScore].
  bool isNewHighScore = false;

  /// Compares the final score with the best one and saves it if it's higher.
  void _updateHighScore() {
    if (score.value > highScore) {
      highScore = score.value;
      isNewHighScore = true;
      ScoreStorage.saveHighScore(highScore);
    } else {
      isNewHighScore = false;
    }
  }

  /// Records a made basket (swiped or dunked), extends the streak and applies
  /// the on-fire multiplier. Returns the points awarded.
  int registerBasket() {
    if (isGameOver) return 0;
    final int points = onFire.value ? fireMultiplier : 1;
    score.value += points;
    streak.value += 1;
    if (streak.value >= fireStreak) {
      onFire.value = true;
    }
    return points;
  }

  /// Records a missed shot: the streak and the on-fire bonus are lost.
  void registerMiss() {
    if (isGameOver) return;
    streak.value = 0;
    onFire.value = false;
  }

  /// The visible game area in world (physics) coordinates, as opposed to
  /// [size] which is the screen size in virtual pixels.
  Vector2 get worldSize => screenToWorld(size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // The game's content is laid out assuming world (0,0) is the top-left
    // corner of the visible area, matching the old (pre-CameraComponent)
    // Forge2DGame behavior. The new default camera centers on (0,0) instead.
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    highScore = await ScoreStorage.loadHighScore();
    //load all gameComponents
    await loadAllComponents();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update timer.
    _timer.update(dt);
  }

//reset time when game is over
  void resetTimer() {
    timer.value = 30;
  }

//reset score when game is over
  void resetScore() {
    score.value = 0;
    dunkCharge.value = 0;
    streak.value = 0;
    onFire.value = false;
    isGameOver = false;
  }

//add overlay to game
  void addMenu(GameOverlays overlay) {
    overlays.add(overlay.name);
  }

  /// Sends the ball waiting at the bottom on a guaranteed arc into the net.
  /// Used by the on-screen Dunk button, and only works once the dunk meter
  /// is fully charged. Using it empties the meter.
  void dunkActiveBall() {
    if (!isDunkReady || paused || isGameOver) return;
    final balls = world.children
        .whereType<BallComponent>()
        .where((ball) => ball.isWaitingToBeShot);
    if (balls.isNotEmpty && balls.first.dunk()) {
      dunkCharge.value = 0;
    }
  }

//function to load all components and initiate timer
  loadAllComponents() async {
    //configure timer countdown
    _timer = Timer(
      1,
      repeat: true,
      onTick: () {
        if (timer.value == 0) {
          // Pause the game,pause bg song and remove all balls with scoreboard components
          isGameOver = true;
          _updateHighScore();
          pauseEngine();
          world.removeWhere((component) => component is BallComponent);FlameAudio.bgm.pause().then(
              (value) => FlameAudio.play(AudioAssets.buzzer, volume: 0.5));

          overlays.remove(GameOverlays.scoreboard.name);
          overlays.add(GameOverlays.gameOver.name);
          // Display game over menu.
        } else {
          // Decrement time by one second.
          timer.value -= 1;
        }
      },
    );

    //Set boundaries for game screen
    final boundaries = createBoundaries(this);
    boundaries.forEach(world.add);
    Vector2 gameSize = worldSize;
    // Preload audio files
    await FlameAudio.audioCache.loadAll([
      AudioAssets.hitRim,
      AudioAssets.hitWall,
      AudioAssets.swish1,
      AudioAssets.swish2,
      AudioAssets.buzzer,
      AudioAssets.shoot,
      AudioAssets.shoot,
      AudioAssets.bgAudio
    ]);
    // Start game bg sound
    FlameAudio.bgm.play(AudioAssets.bgAudio);
    world.addAll([
      MuralComponent(),
      BackboardComponent(),
      RimComponent(Vector2((gameSize.x / 2) + 6, 28), false),
      RimComponent(Vector2((gameSize.x / 2) - 6.7, 28), false),
      BackRimComponent(),
      FrontRimComponent(),
      BallComponent()
    ]);
  }
}
