import 'package:basketball_game/constants/image_assets.dart';
import 'package:basketball_game/services/shop_storage.dart';
import 'package:basketball_game/shop/shop_catalog.dart';
import 'package:flutter/material.dart';

const String _ledFont = 'Enhanced LED Board-7';

/// Lets the player spend coins on ball skins and court themes, and choose
/// which ones to use.
class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopState? _state;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final state = await ShopStorage.load();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _onItemTap(ShopItem item) async {
    final state = _state;
    if (state == null || state.isEquipped(item)) return;

    if (!state.owns(item)) {
      if (state.coins < item.price) {
        _showMessage('Not enough coins. Score more points to earn them!');
        return;
      }
      final bought = await ShopStorage.buy(item);
      if (!bought) {
        _showMessage('Purchase failed, please try again.');
        return;
      }
      _showMessage('Unlocked ${item.name}!');
    }
    // buying something also equips it right away
    await ShopStorage.equip(item);
    await _reload();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('SHOP',
              style: TextStyle(fontFamily: _ledFont, fontSize: 22)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: CoinLabel(coins: state?.coins ?? 0)),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontFamily: _ledFont, fontSize: 15),
            tabs: [
              Tab(icon: Icon(Icons.sports_basketball), text: 'BALLS'),
              Tab(icon: Icon(Icons.wallpaper), text: 'COURTS'),
            ],
          ),
        ),
        body: state == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _ItemGrid(
                      category: ShopCategory.ball,
                      state: state,
                      onTap: _onItemTap),
                  _ItemGrid(
                      category: ShopCategory.court,
                      state: state,
                      onTap: _onItemTap),
                ],
              ),
      ),
    );
  }
}

/// Coin icon and balance. Also used on the main menu and game over screen.
class CoinLabel extends StatelessWidget {
  final int coins;
  final double size;

  const CoinLabel({Key? key, required this.coins, this.size = 18})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.monetization_on, color: Colors.amber, size: size + 4),
        const SizedBox(width: 4),
        Text('$coins',
            style: TextStyle(
                color: Colors.amber,
                fontFamily: _ledFont,
                fontWeight: FontWeight.w700,
                fontSize: size)),
      ],
    );
  }
}

class _ItemGrid extends StatelessWidget {
  final ShopCategory category;
  final ShopState state;
  final ValueChanged<ShopItem> onTap;

  const _ItemGrid({
    required this.category,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = ShopCatalog.itemsFor(category);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(
          item: item,
          owned: state.owns(item),
          equipped: state.isEquipped(item),
          affordable: state.coins >= item.price,
          onTap: () => onTap(item),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ShopItem item;
  final bool owned;
  final bool equipped;
  final bool affordable;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.affordable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: equipped ? Colors.deepOrange : Colors.white12,
          width: equipped ? 3 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _preview()),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: _ledFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: _actionButton(),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    if (item.category == ShopCategory.court) {
      return Image.asset('assets/images/${item.image}', fit: BoxFit.cover);
    }
    Widget ball = Image.asset(
      'assets/images/${ImageAssets.basketballSprite}',
      fit: BoxFit.contain,
    );
    final filter = item.ballColorFilter;
    if (filter != null) {
      ball = ColorFiltered(colorFilter: filter, child: ball);
    }
    return Padding(padding: const EdgeInsets.all(18), child: ball);
  }

  Widget _actionButton() {
    Color background;
    Widget label;
    if (equipped) {
      background = Colors.green.shade700;
      label = const Text('EQUIPPED');
    } else if (owned) {
      background = Colors.deepOrange;
      label = const Text('EQUIP');
    } else {
      background = affordable ? Colors.deepOrange : Colors.grey.shade800;
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(affordable ? Icons.monetization_on : Icons.lock,
              size: 16, color: affordable ? Colors.amber : Colors.white54),
          const SizedBox(width: 4),
          Text('${item.price}'),
        ],
      );
    }
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: equipped ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          disabledBackgroundColor: background,
          disabledForegroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(
              fontFamily: _ledFont, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        child: label,
      ),
    );
  }
}
