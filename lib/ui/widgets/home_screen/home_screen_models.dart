import 'package:flutter/material.dart';
import 'package:flutter_itsolutions_task/services/js_interop_service.dart';

class ScreenStateModel extends ChangeNotifier {
  /// Wether the Fullscreen mode is ON.
  bool _isFullScreen = false;

  /// Toggles full screen mode when double clicking on an image.
  void onDoubleTapImage() {
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
  void requestFullscreen() {
    if (_isFullScreen) return;
    _toggleFullScreen();
  }

  /// Exit from full screen mode.
  void exitFullscreen() {
    if (!_isFullScreen) return;
    _toggleFullScreen();
  }
}

class HtmlWidgetModel extends ChangeNotifier {
  String? imageUrl; // https://pixlr.com/images/generator/text-to-image.webp

  void updateImage() => notifyListeners();
}

class PopUpMenuModel extends ChangeNotifier {
  /// Wether the PopUp menu is appear.
  bool _isPopUpMenuOpen = false;
  bool get isPopUpMenuOpen => _isPopUpMenuOpen;

  /// Updates the state when PopUp menu appears or disappears.
  void onToggelePopUpMenu() {
    _isPopUpMenuOpen = !_isPopUpMenuOpen;
    notifyListeners();
  }
}
