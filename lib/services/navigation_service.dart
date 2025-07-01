import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(Widget page) async {
    return navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
  }

  void goBack() {
    return navigatorKey.currentState?.pop();
  }
}