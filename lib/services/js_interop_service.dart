import 'dart:js_interop';

@JS()
external void requestFullscreen();

@JS()
external void exitFullscreen();

/// A service class that provides Javascript methods, using [dart:js_interop]
class JSInteropService {
  /// Sets the screen to full screen mode.
  static requestFullScreen() => requestFullscreen();

  /// Sets the screen to windowed screen mode.
  static exitFullScreen() => exitFullscreen();
}
