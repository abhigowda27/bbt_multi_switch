import 'package:bbtml_new/screens/bbtm_screens/view/home_page.dart';
import 'package:bbtml_new/screens/profile_screen.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = [
    const HomePage(),
    const ProfileScreen(),
    // UDPExampleScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0; // switch to Home instead of exiting
          });
        }
      },
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).appColors.primary,
          unselectedItemColor: Theme.of(context).appColors.textSecondary,
          backgroundColor: Theme.of(context).appColors.background,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/home.png",
                height: 30,
                color: Theme.of(context).appColors.textSecondary,
                errorBuilder: (context, e, _) => Icon(
                  Icons.home,
                  size: 30,
                  color: Theme.of(context).appColors.textSecondary,
                ),
              ),
              activeIcon: Image.asset(
                "assets/images/home.png",
                height: 30,
                color: Theme.of(context).appColors.primary,
                errorBuilder: (context, e, _) => Icon(
                  Icons.home,
                  size: 30,
                  color: Theme.of(context).appColors.primary,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/user.png",
                height: 30,
                color: Theme.of(context).appColors.textSecondary,
                errorBuilder: (context, e, _) => Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                  color: Theme.of(context).appColors.textSecondary,
                ),
              ),
              activeIcon: Image.asset(
                "assets/images/user.png",
                height: 30,
                color: Theme.of(context).appColors.primary,
                errorBuilder: (context, e, _) => Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                  color: Theme.of(context).appColors.primary,
                ),
              ),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
