import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/aluga_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'chat_view.dart';
import 'explore_view.dart';
import 'post_item_view.dart';
import 'profile_view.dart';
import 'rentals_view.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlugaController>();
    final currentIndex = controller.currentTabIndex;

    final List<Widget> pages = const [
      ExploreView(),
      RentalsView(),
      PostItemView(),
      ChatView(),
      ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: currentIndex == 0
          ? const CustomAppBar()
          : null, // Explore has custom header, others have internal headers
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const CustomBottomNavBar(),
        ),
      ),
    );
  }
}
