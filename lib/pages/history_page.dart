import 'package:flutter/material.dart';
import 'history_page_desktop.dart';
import 'history_page_mobile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 720) {
      return const HistoryPageDesktop();
    }
    return const HistoryPageMobile();
  }
}
