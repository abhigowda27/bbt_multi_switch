import 'package:bbtml_new/screens/switches/add_switch.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import 'add_multi_switch.dart';

class AddSwitchTab extends StatelessWidget {
  const AddSwitchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("New Device Installation"),
          bottom: TabBar(
            unselectedLabelStyle: TextStyle(
                color: Theme.of(context).appColors.background, fontSize: 16),
            labelStyle: TextStyle(
                color: Theme.of(context).appColors.background, fontSize: 16),
            tabs: const [
              Tab(text: 'Switch'),
              Tab(text: 'Multi Switch'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddSwitchPage(),
            AddMultiSwitch(),
          ],
        ),
      ),
    );
  }
}
