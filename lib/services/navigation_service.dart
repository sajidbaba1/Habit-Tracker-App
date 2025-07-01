import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(Widget destination) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void goBack() {
    navigatorKey.currentState!.pop();
  }
}