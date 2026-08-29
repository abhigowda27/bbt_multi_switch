import 'package:flutter/material.dart';

class AllRouterPage extends StatefulWidget {
  const AllRouterPage({super.key});

  @override
  State<AllRouterPage> createState() => _AllRouterPageState();
}

class _AllRouterPageState extends State<AllRouterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Router"),
      ),
    );
  }
}
