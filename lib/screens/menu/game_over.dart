import 'package:basketball_game/components/ball.dart';
import 'package:basketball_game/game/basketball_game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class GameOverScreen extends StatelessWidget {
  final BasketBallGame game;

  const GameOverScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Center(
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          width: screenSize.width * 0.9,
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 150,
                  child: Lottie.asset('assets/animation/gameover.json')),
              if (game.isNewHighScore)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.deepOrange]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'NEW RECORD!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Enhanced LED Board-7',
                            fontSize: 16),
                      ),
                    ],
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.1, duration: 600.ms),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  'You scored ${game.score.value} points',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Enhanced LED Board-7',
                      fontSize: 17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'BEST: ${game.highScore}',
                  style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Enhanced LED Board-7',
                      fontSize: 15),
                ),
              ),
              SizedBox(
                  height: 40,
                  width: screenSize.width * 0.7,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        game.resetScore();
                        game.resetTimer();
                        game.resumeEngine();
                        game.overlays.remove(GameOverlays.gameOver.name);
                        game.overlays.add(GameOverlays.scoreboard.name);
                        game.world.add(BallComponent());
                        FlameAudio.bgm.resume();
                      },
                      child: const Text(
                        'Play Again',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Enhanced LED Board-7',
                            fontSize: 14),
                      ).animate().fade(duration: 500.ms).scale(delay: 500.ms)))
            ],
          ),
        ),
      ),
    );
  }
}
