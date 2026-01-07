import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/online_menu_screen/components/online_categories.dart';
import 'package:desktoppossystem/screens/online_menu_screen/components/online_products.dart';
import 'package:desktoppossystem/screens/online_menu_screen/components/online_settings.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Provider to manage current tab index
final onlineMenuTabIndexProvider = StateProvider<int>((ref) => 0);

class OnlineMenuScreenMobile extends ConsumerStatefulWidget {
  const OnlineMenuScreenMobile({super.key});

  @override
  ConsumerState<OnlineMenuScreenMobile> createState() =>
      _OnlineMenuScreenMobileState();
}

class _OnlineMenuScreenMobileState extends ConsumerState<OnlineMenuScreenMobile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listen to tab changes and sync with provider
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(onlineMenuTabIndexProvider.notifier).state =
            _tabController.index;
      }
    });

    // Listen to category selection and auto-switch to Products tab
    ref.listenManual(
      menuControllerProvider.select((value) => value.selectedCategory),
      (previous, next) {
        if (next != null && previous != next) {
          // Category was selected, switch to Products tab (index 1)
          _tabController.animateTo(1);
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for external tab changes
    ref.listen<int>(onlineMenuTabIndexProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: Pallete.greyColor),
      ),
      child: Column(
        children: [
          // Custom Tab Bar
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              border: const Border(
                bottom: BorderSide(color: Pallete.greyColor, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: context.primaryColor,
              unselectedLabelColor: Pallete.greyColor,
              indicatorColor: context.primaryColor,
              indicatorWeight: 3.h,
              labelStyle: TextStyle(
                fontSize: 14.spMax,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.spMax,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.category_outlined, size: 20.spMax),
                  text: S.of(context).categories,
                ),
                Tab(
                  icon: Icon(Icons.shopping_bag, size: 20.spMax),
                  text: S.of(context).products,
                ),
                Tab(
                  icon: Icon(Icons.settings, size: 20.spMax),
                  text: S.of(context).settings,
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                OnlineCategories(),
                OnlineProducts(),
                OnlineSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
