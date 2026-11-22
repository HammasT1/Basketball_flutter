import 'package:flutter/material.dart';

enum ShopCategory { ball, court }

/// Something the player can buy in the shop: a ball skin or a court theme.
class ShopItem {
  final String id;
  final String name;
  final int price;
  final ShopCategory category;

  /// Ball skins only: color the ball is tinted with (null = original look).
  final Color? tint;

  /// Court themes only: background image inside assets/images/.
  final String? image;

  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.tint,
    this.image,
  });

  bool get isFree => price == 0;

  /// The color filter that turns the plain ball into this skin. Uses
  /// [BlendMode.color] so the ball keeps its shading and seams.
  ColorFilter? get ballColorFilter =>
      tint == null ? null : ColorFilter.mode(tint!, BlendMode.color);
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultBallId = 'ball_classic';
  static const String defaultCourtId = 'court_steel';

  static const List<ShopItem> balls = [
    ShopItem(
        id: defaultBallId,
        name: 'Classic',
        price: 0,
        category: ShopCategory.ball),
    ShopItem(
        id: 'ball_ice',
        name: 'Ice',
        price: 25,
        category: ShopCategory.ball,
        tint: Color(0xFF29B6F6)),
    ShopItem(
        id: 'ball_toxic',
        name: 'Toxic',
        price: 50,
        category: ShopCategory.ball,
        tint: Color(0xFF76FF03)),
    ShopItem(
        id: 'ball_royal',
        name: 'Royal',
        price: 75,
        category: ShopCategory.ball,
        tint: Color(0xFF7C4DFF)),
    ShopItem(
        id: 'ball_crimson',
        name: 'Crimson',
        price: 100,
        category: ShopCategory.ball,
        tint: Color(0xFFE53935)),
    ShopItem(
        id: 'ball_gold',
        name: 'Gold',
        price: 150,
        category: ShopCategory.ball,
        tint: Color(0xFFFFD600)),
  ];

  static const List<ShopItem> courts = [
    ShopItem(
        id: defaultCourtId,
        name: 'Steel Cage',
        price: 0,
        category: ShopCategory.court,
        image: 'mural7.jpg'),
    ShopItem(
        id: 'court_hardwood',
        name: 'Hardwood',
        price: 30,
        category: ShopCategory.court,
        image: 'mural5.JPG'),
    ShopItem(
        id: 'court_studio',
        name: 'Studio',
        price: 60,
        category: ShopCategory.court,
        image: 'mural6.jpg'),
    ShopItem(
        id: 'court_brick',
        name: 'Brick Wall',
        price: 90,
        category: ShopCategory.court,
        image: 'mural1.png'),
    ShopItem(
        id: 'court_street',
        name: 'Street Art',
        price: 120,
        category: ShopCategory.court,
        image: 'mural2.png'),
    ShopItem(
        id: 'court_urban',
        name: 'Urban Night',
        price: 200,
        category: ShopCategory.court,
        image: 'mural3.jpeg'),
  ];

  static List<ShopItem> itemsFor(ShopCategory category) =>
      category == ShopCategory.ball ? balls : courts;

  static ShopItem ballById(String id) =>
      balls.firstWhere((item) => item.id == id, orElse: () => balls.first);

  static ShopItem courtById(String id) =>
      courts.firstWhere((item) => item.id == id, orElse: () => courts.first);
}
