import 'dart:ui';

import 'package:basketball_game/game/basketball_game.dart';
import 'package:basketball_game/screens/menu/game_over.dart';
import 'package:basketball_game/screens/shop/shop_screen.dart';
import 'package:basketball_game/services/score_storage.dart';
import 'package:basketball_game/services/shop_storage.dart';
import 'package:basketball_game/widgets/scoreboard.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/image_assets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _best = 0;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final best = await ScoreStorage.loadHighScore();
    final shop = await ShopStorage.load();
    if (mounted) {
      setState(() {
        _best = best;
        _coins = shop.coins;
      });
    }
  }

  void _startGame() {
    final BasketBallGame basketballGame = BasketBallGame();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GameWidget(
                  game: basketballGame,
                  overlayBuilderMap: {
                    GameOverlays.scoreboard.name: (ctx, Game game) =>
                        ScoreBoard(game: basketballGame),
                    GameOverlays.gameOver.name: (ctx, Game game) =>
                        GameOverScreen(game: basketballGame),
                    GameOverlays.main.name:
                        (BuildContext context, BasketBallGame gameRef) =>
                            const MainMenuScreen(),
                  },
                  initialActiveOverlays: [GameOverlays.scoreboard.name],
                )));
  }

  Future<void> _openShop() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ShopScreen()));
    // coins may have been spent
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    const TextStyle buttonTextStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontFamily: 'Enhanced LED Board-7',
        fontSize: 14);
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/${ImageAssets.mural2}',
            width: screenSize.width,
            height: screenSize.height,
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              height: screenSize.height * 0.7,
              width: screenSize.width * 0.8,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Basketball game developed with Flame',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Enhanced LED Board-7',
                          fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    if (_best > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'BEST: $_best',
                          style: const TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Enhanced LED Board-7',
                              fontSize: 18),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CoinLabel(coins: _coins),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: SizedBox(
                          width: screenSize.width * 0.8,
                          height: 40,
                          child: ElevatedButton(
                              style: buttonStyle,
                              onPressed: _startGame,
                              child: const Text('Start Game',
                                      style: buttonTextStyle)
                                  .animate()
                                  .fade(duration: 500.ms)
                                  .scale(delay: 500.ms))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SizedBox(
                          width: screenSize.width * 0.8,
                          height: 40,
                          child: ElevatedButton.icon(
                              style: buttonStyle,
                              onPressed: _openShop,
                              icon: const Icon(Icons.storefront),
                              label: const Text('Shop',
                                      style: buttonTextStyle)
                                  .animate()
                                  .fade(duration: 500.ms)
                                  .scale(delay: 600.ms))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
