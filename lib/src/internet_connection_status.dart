/// Enum that represents the status of internet connection
enum InternetConnectionStatus {
  /// Internet connection is available
  connected,

  /// Internet connection is not available
  disconnected,

  /// Internet connection status is unknown or being checked
  unknown
}

/// Extension on InternetConnectionStatus to provide utility methods
extension InternetConnectionStatusExtension on InternetConnectionStatus {
  /// Returns true if the device is connected to the internet
  bool get isConnected => this == InternetConnectionStatus.connected;

  /// Returns true if the device is not connected to the internet
  bool get isDisconnected => this == InternetConnectionStatus.disconnected;

  /// Returns true if the internet connection status is unknown
  bool get isUnknown => this == InternetConnectionStatus.unknown;
}
