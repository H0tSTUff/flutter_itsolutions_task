import 'package:flutter_itsolutions_task/helpers/data_provider.dart';
import 'package:flutter_itsolutions_task/ui/widgets/home_screen/home_screen_models.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// [Widget] displaying the home page consisting of an image the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final screenStateModel = ScreenStateModel();
  final htmlWidgetModel = HtmlWidgetModel();
  final popUpMenuModel = PopUpMenuModel();
  late Function() _listener;

  @override
  void initState() {
    super.initState();

    ui_web.platformViewRegistry.registerViewFactory(
      'img-view',
      (int viewId, {Object? params}) {
        // Create and return an HTML Element from here
        final web.HTMLImageElement myImg = web.HTMLImageElement()
          ..id = 'img_id_$viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = (params as String?) ?? '';
        return myImg;
      },
    );

    _listener = () => setState(() {});
    popUpMenuModel.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return DataProvider<ScreenStateModel>(
      model: screenStateModel,
      child: Stack(children: [
        Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: DataProvider<HtmlWidgetModel>(
              model: htmlWidgetModel,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HtmlImageWidget(),
                  SizedBox(height: 8),
                  _UrlStringWidget(),
                  SizedBox(height: 64),
                ],
              ),
            ),
          ),
          floatingActionButton: DataProvider<PopUpMenuModel>(
            model: popUpMenuModel,
            child: const _PopUpMenuButton(),
          ),
        ),
        popUpMenuModel.isPopUpMenuOpen
            ? const OpacityModalWidget()
            : const SizedBox.shrink(),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    popUpMenuModel.removeListener(_listener);
  }
}

/// A widget used to make PopUp menu button with list of items.
class _PopUpMenuButton extends StatelessWidget {
  /// Creates a const [_PopUpMenuButton].
  const _PopUpMenuButton({
    super.key,
  });

  List<MenuItemButton> _makeItemButtons(ScreenStateModel? model) {
    return <MenuItemButton>[
      MenuItemButton(
          onPressed: model?.requestFullscreen,
          child: const Text('Enter fullscreen')),
      MenuItemButton(
          onPressed: model?.exitFullscreen,
          child: const Text('Exit fullscreen')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final popUpMenuModel = DataProvider.read<PopUpMenuModel>(context);
    final screenStateModel = DataProvider.read<ScreenStateModel>(context);

    return Container(
      width: 100,
      height: 100,
      alignment: AlignmentDirectional.bottomEnd,
      child: MenuAnchor(
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              controller.isOpen ? controller.close() : controller.open();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Select screen mode',
          );
        },
        menuChildren: _makeItemButtons(screenStateModel),
        alignmentOffset: const Offset(-80.0, 15.0),
        onOpen: popUpMenuModel?.onToggelePopUpMenu,
        onClose: popUpMenuModel?.onToggelePopUpMenu,
      ),
    );
  }
}

/// A widget used to make Image from HTML, using tag <img>.
class HtmlImageWidget extends StatelessWidget {
  /// Creates a widget that builds Flutter widget tree from html.
  const HtmlImageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenStateModel = DataProvider.read<ScreenStateModel>(context);
    final htmlWidgetModel = DataProvider.watch<HtmlWidgetModel>(context);
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onDoubleTap: screenStateModel?.onDoubleTapImage,
            child: HtmlElementView(
              key: UniqueKey(),
              viewType: 'img-view',
              creationParams: htmlWidgetModel?.imageUrl,
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget used to make URL string and button.
class _UrlStringWidget extends StatelessWidget {
  /// Creates a const [_UrlStringWidget].
  const _UrlStringWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = DataProvider.read<HtmlWidgetModel>(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(hintText: 'Image URL'),
            onChanged: (value) => model?.imageUrl = value,
          ),
        ),
        ElevatedButton(
          onPressed: model?.updateImage,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Icon(Icons.arrow_forward),
          ),
        ),
      ],
    );
  }
}

/// A widget that creates a [ModalBarrier] with custom [opacity] and [color].
class OpacityModalWidget extends StatelessWidget {
  /// Creates a const [OpacityModalWidget].
  const OpacityModalWidget({
    this.opacity = 0.5,
    this.color = Colors.grey,
    super.key,
  });

  /// The fraction to scale the child's alpha value.
  ///
  /// An opacity of one is fully opaque. An opacity of zero is fully transparent.
  ///
  /// See also:
  ///
  ///  * [Opacity.opacity].
  final double opacity;

  /// If non-null, fill the barrier with this color.
  ///
  /// See also:
  ///
  ///  * [ModalBarrier.color].
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ModalBarrier(dismissible: false, color: color),
    );
  }
}
