import 'package:flutter_itsolutions_task/ui/widgets/home_screen/html_widget_data_provider.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_itsolutions_task/services/js_interop_service.dart';

/// [Widget] displaying the home page consisting of an image the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final model = HtmlWidgetModel();

  /// Wether the Fullscreen mode is ON.
  bool _isFullScreen = false;

  /// Wether the PopUp menu is appear.
  bool _isPopUpMenuOpen = false;

  /// Toggles full screen mode when double clicking on an image.
  void _onDoubleTapImage() {
    _toggleFullScreen();
  }

  /// Toggles the screen between full screen and windowed modes.
  void _toggleFullScreen() {
    !_isFullScreen
        ? JSInteropService.requestFullScreen()
        : JSInteropService.exitFullScreen();

    _isFullScreen = !_isFullScreen;
  }

  /// Sets the screen to full screen mode.
  void _requestFullscreen() {
    if (_isFullScreen) return;
    _toggleFullScreen();
  }

  /// Exit from full screen mode.
  void _exitFullscreen() {
    if (!_isFullScreen) return;
    _toggleFullScreen();
  }

  /// Updates the state when PopUp menu appears or disappears.
  void _onToggelePopUpMenu() {
    setState(() {
      _isPopUpMenuOpen = !_isPopUpMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<MenuItemButton> itemButtons = <MenuItemButton>[
      MenuItemButton(
          onPressed: _requestFullscreen, child: const Text('Enter fullscreen')),
      MenuItemButton(
          onPressed: _exitFullscreen, child: const Text('Exit fullscreen')),
    ];

    return Stack(children: [
      Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: HtmlWidgetDataProvider(
            model: model,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HtmlImageWidget(onDoubleTapImage: _onDoubleTapImage),
                const SizedBox(height: 8),
                const _UrlStringWidget(),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
        floatingActionButton: _PopUpMenuButton(
          itemButtons: itemButtons,
          icon: const Icon(Icons.add),
          tooltip: 'Select screen mode',
          onOpen: _onToggelePopUpMenu,
          onClose: _onToggelePopUpMenu,
        ),
      ),
      _isPopUpMenuOpen ? const OpacityModalWidget() : const SizedBox.shrink(),
    ]);
  }
}

/// A widget used to make PopUp menu button with list of items.
class _PopUpMenuButton extends StatelessWidget {
  /// Creates a const [_PopUpMenuButton].
  ///
  /// The [itemButtons] argument is required.
  const _PopUpMenuButton({
    required this.itemButtons,
    required this.icon,
    this.tooltip,
    this.onOpen,
    this.onClose,
    super.key,
  });

  /// A list of children containing the menu items.
  final List<Widget> itemButtons;

  /// A callback that is invoked when the menu is opened.
  final void Function()? onOpen;

  /// A callback that is invoked when the menu is closed.
  final void Function()? onClose;

  /// The icon to display inside the button.
  final Widget icon;

  /// Text that describes the action that will occur when the button is pressed.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
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
            icon: icon,
            tooltip: tooltip,
          );
        },
        menuChildren: itemButtons,
        alignmentOffset: const Offset(-80.0, 15.0),
        onOpen: onOpen,
        onClose: onClose,
      ),
    );
  }
}

/// A widget used to make Image from HTML, using tag <img>.
class HtmlImageWidget extends StatelessWidget {
  /// Creates a widget that builds Flutter widget tree from html.
  ///
  /// The [imgUrl] and [onDoubleTapImage] arguments must not be null.
  HtmlImageWidget({
    required this.onDoubleTapImage,
    super.key,
  }) {
    _registerImgFactory();
  }

  /// A callback that is invoked when the image is tapped.
  final void Function() onDoubleTapImage;

  /// Register image view type
  void _registerImgFactory() {
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
  }

  @override
  Widget build(BuildContext context) {
    final model = HtmlWidgetDataProvider.watch(context);
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onDoubleTap: () => onDoubleTapImage(),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: HtmlElementView(
              key: UniqueKey(),
              viewType: 'img-view',
              creationParams: model?.imageUrl,
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
  ///
  /// The [onChanged] and [onGetImgBtnPressed] arguments must not be null.
  const _UrlStringWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = HtmlWidgetDataProvider.read(context);
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
