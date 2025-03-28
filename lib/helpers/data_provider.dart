import 'package:flutter/material.dart';

class DataProvider<Model extends Listenable> extends InheritedNotifier<Model> {
  const DataProvider({
    required Model model,
    required super.child,
    super.key,
  }) : super(notifier: model);

  static Model? watch<Model extends Listenable>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DataProvider<Model>>()
        ?.notifier;
  }

  static Model? read<Model extends Listenable>(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<DataProvider<Model>>()
        ?.notifier;
  }
}
