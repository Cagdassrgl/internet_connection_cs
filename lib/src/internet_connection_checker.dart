import 'dart:async';
import 'dart:io';
import 'internet_connection_status.dart';

/// A class that provides methods to check internet connectivity
class InternetConnectionChecker {
  /// Default timeout duration for connection checks
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Default host to check connection (domain name for DNS lookup)
  static const String defaultHost = 'google.com';

  /// Singleton instance
  static final InternetConnectionChecker _instance = InternetConnectionChecker._internal();

  /// Factory constructor that returns the singleton instance
  factory InternetConnectionChecker() => _instance;

  /// Private constructor
  InternetConnectionChecker._internal();

  /// Checks if there is an internet connection using DNS lookup
  ///
  /// [host] - The domain name to check connectivity against (default: google.com)
  /// [timeout] - The timeout duration for the DNS lookup (default: 10 seconds)
  ///
  /// Returns [InternetConnectionStatus.connected] if connected,
  /// [InternetConnectionStatus.disconnected] if not connected
  Future<InternetConnectionStatus> checkConnectivity({
    String host = defaultHost,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      // Validate the host
      if (host.isEmpty) {
        throw ArgumentError('Host cannot be empty');
      }

      // Remove protocol schemes if present (we only need domain name)
      String cleanHost = host;
      if (host.startsWith('http://')) {
        cleanHost = host.substring(7);
      } else if (host.startsWith('https://')) {
        cleanHost = host.substring(8);
      }

      // Remove path if present
      if (cleanHost.contains('/')) {
        cleanHost = cleanHost.split('/')[0];
      }

      // Perform DNS lookup with timeout
      final result = await InternetAddress.lookup(cleanHost).timeout(timeout);

      // Check if we got valid IP addresses
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return InternetConnectionStatus.connected;
      } else {
        return InternetConnectionStatus.disconnected;
      }
    } on SocketException {
      // DNS lookup failed - no internet connection
      return InternetConnectionStatus.disconnected;
    } on TimeoutException {
      // DNS lookup timed out
      return InternetConnectionStatus.disconnected;
    } on ArgumentError {
      // Invalid host format - rethrow
      rethrow;
    } catch (e) {
      // Any other error
      return InternetConnectionStatus.disconnected;
    }
  }

  /// Checks connectivity with a simple boolean return
  ///
  /// [host] - The domain name to check connectivity against (default: google.com)
  /// [timeout] - The timeout duration for the DNS lookup (default: 10 seconds)
  ///
  /// Returns true if connected, false otherwise
  Future<bool> hasConnection({
    String host = defaultHost,
    Duration timeout = defaultTimeout,
  }) async {
    final status = await checkConnectivity(host: host, timeout: timeout);
    return status.isConnected;
  }

  /// Alternative method using Socket connection for faster checks
  ///
  /// [host] - The IP address or domain to connect to (default: 8.8.8.8)
  /// [port] - The port to connect to (default: 53 - DNS port)
  /// [timeout] - The timeout duration for the connection (default: 3 seconds)
  ///
  /// Returns [InternetConnectionStatus.connected] if connected,
  /// [InternetConnectionStatus.disconnected] if not connected
  Future<InternetConnectionStatus> checkConnectivitySocket({
    String host = '8.8.8.8',
    int port = 53,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      if (host.isEmpty) {
        throw ArgumentError('Host cannot be empty');
      }

      if (port <= 0 || port > 65535) {
        throw ArgumentError('Port must be between 1 and 65535');
      }

      // Try to create socket connection
      final socket = await Socket.connect(host, port, timeout: timeout);

      // If we get here, connection was successful
      socket.destroy();
      return InternetConnectionStatus.connected;
    } on SocketException {
      // Network unreachable or connection failed
      return InternetConnectionStatus.disconnected;
    } on TimeoutException {
      // Connection timed out
      return InternetConnectionStatus.disconnected;
    } catch (e) {
      // Any other error
      return InternetConnectionStatus.disconnected;
    }
  }

  /// Socket-based connectivity check with boolean return
  ///
  /// [host] - The IP address or domain to connect to (default: 8.8.8.8)
  /// [port] - The port to connect to (default: 53 - DNS port)
  /// [timeout] - The timeout duration for the connection (default: 3 seconds)
  ///
  /// Returns true if connected, false otherwise
  Future<bool> hasConnectionSocket({
    String host = '8.8.8.8',
    int port = 53,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final status = await checkConnectivitySocket(host: host, port: port, timeout: timeout);
    return status.isConnected;
  }

  /// Creates a stream that periodically checks internet connectivity using DNS lookup
  ///
  /// [interval] - How often to check connectivity (default: 30 seconds)
  /// [host] - The domain name to check connectivity against (default: google.com)
  /// [timeout] - The timeout duration for each DNS lookup (default: 10 seconds)
  ///
  /// Returns a stream of [InternetConnectionStatus]
  Stream<InternetConnectionStatus> onStatusChange({
    Duration interval = const Duration(seconds: 30),
    String host = defaultHost,
    Duration timeout = defaultTimeout,
  }) {
    return Stream.periodic(interval, (count) => count)
        .asyncMap((_) => checkConnectivity(host: host, timeout: timeout))
        .distinct(); // Only emit when status changes
  }

  /// Creates a stream that periodically checks internet connectivity using socket connection
  ///
  /// [interval] - How often to check connectivity (default: 30 seconds)
  /// [host] - The IP address or domain to connect to (default: 8.8.8.8)
  /// [port] - The port to connect to (default: 53 - DNS port)
  /// [timeout] - The timeout duration for each connection (default: 3 seconds)
  ///
  /// Returns a stream of [InternetConnectionStatus]
  Stream<InternetConnectionStatus> onStatusChangeSocket({
    Duration interval = const Duration(seconds: 30),
    String host = '8.8.8.8',
    int port = 53,
    Duration timeout = const Duration(seconds: 3),
  }) {
    return Stream.periodic(interval, (count) => count)
        .asyncMap((_) => checkConnectivitySocket(host: host, port: port, timeout: timeout))
        .distinct(); // Only emit when status changes
  }
}
