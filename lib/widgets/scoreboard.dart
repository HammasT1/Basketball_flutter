import 'package:basketball_game/game/basketball_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScoreBoard extends StatelessWidget {
  final BasketBallGame game;

  const ScoreBoard({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontFamily: 'Enhanced LED Board-7',
    );
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 10),
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: screenSize.width * 0.95,
                height: 65,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: game.score,
                        builder: (context, score, _) {
                          return Text(
                            'PTS-> $score',
                            style: style,
                          );
                        }),
                    ValueListenableBuilder(
                        valueListenable: game.timer,
                        builder: (context, time, _) {
                          String newTime =
                              time < 10 ? '0$time' : time.toString();
                          return Text('00:$newTime <-TIME', style: style);
                        }),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(55),
                  onTap: game.dunkActiveBall,
                  child: Container(
                    width: 110,
                    height: 110,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Colors.amberAccent, Colors.deepOrange],
                        radius: 0.9,
                      ),
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.orangeAccent,
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_basketball,
                            color: Colors.white, size: 34),
                        Text(
                          'DUNK!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Enhanced LED Board-7',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.1, duration: 700.ms, curve: Curves.easeInOut),
            ),
          ),
        ],
      ),
    );
  }
}
