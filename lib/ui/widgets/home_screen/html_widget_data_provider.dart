import 'package:flutter/material.dart';

class HtmlWidgetModel extends ChangeNotifier {
  String? imageUrl; // https://pixlr.com/images/generator/text-to-image.webp

  void updateImage() => notifyListeners();
}

class HtmlWidgetDataProvider extends InheritedNotifier<HtmlWidgetModel> {
  const HtmlWidgetDataProvider({
    required this.model,
    required super.child,
    super.key,
  }) : super(notifier: model);

  final HtmlWidgetModel model;

  static HtmlWidgetModel? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HtmlWidgetDataProvider>()
        ?.model;
  }

  static HtmlWidgetModel? read(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<HtmlWidgetDataProvider>()
        ?.model;
  }
}
