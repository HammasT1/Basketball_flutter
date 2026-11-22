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
            top: 82,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([game.streak, game.onFire]),
                builder: (context, _) => _StreakBadge(
                  streak: game.streak.value,
                  onFire: game.onFire.value,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: game.dunkCharge,
                builder: (context, charge, _) => _DunkButton(
                  charge: charge,
                  needed: BasketBallGame.dunkChargeNeeded,
                  onTap: game.dunkActiveBall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the current basket streak, or a pulsing "ON FIRE 2X" badge once the
/// streak is long enough. Hidden when there is no streak.
class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool onFire;

  const _StreakBadge({required this.streak, required this.onFire});

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    const TextStyle style = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontFamily: 'Enhanced LED Board-7',
    );

    if (!onFire) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('STREAK x$streak', style: style),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.deepOrange, Colors.red],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.orangeAccent, blurRadius: 14, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text('ON FIRE 2X  x$streak', style: style),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.08, duration: 500.ms, curve: Curves.easeInOut);
  }
}

/// Dunk power-up button. Charges with each swiped basket and can only be
/// used once full. While charging it is grey and shows progress.
class _DunkButton extends StatelessWidget {
  final int charge;
  final int needed;
  final VoidCallback onTap;

  const _DunkButton({
    required this.charge,
    required this.needed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool ready = charge >= needed;
    const TextStyle labelStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontFamily: 'Enhanced LED Board-7',
    );

    Widget button = SizedBox(
      width: 124,
      height: 124,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // charge progress ring
          SizedBox(
            width: 124,
            height: 124,
            child: CircularProgressIndicator(
              value: charge / needed,
              strokeWidth: 6,
              backgroundColor: Colors.black45,
              valueColor: AlwaysStoppedAnimation<Color>(
                  ready ? Colors.amberAccent : Colors.orange),
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: ready ? onTap : null,
              child: Container(
                width: 110,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: ready
                        ? const [Colors.amberAccent, Colors.deepOrange]
                        : [Colors.grey.shade500, Colors.grey.shade800],
                    radius: 0.9,
                  ),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [
                    if (ready)
                      const BoxShadow(
                        color: Colors.orangeAccent,
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    const BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_basketball,
                        color: ready ? Colors.white : Colors.white54,
                        size: 34),
                    Text(ready ? 'DUNK!' : '$charge/$needed',
                        style: labelStyle),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // only pulse when the dunk is ready to use
    if (ready) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
              begin: 1.0, end: 1.1, duration: 700.ms, curve: Curves.easeInOut);
    }
    return button;
  }
}
