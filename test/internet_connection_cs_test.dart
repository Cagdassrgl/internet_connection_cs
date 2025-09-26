import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_cs/internet_connection_cs.dart';

void main() {
  group('InternetConnectionStatus', () {
    test('should have correct values', () {
      expect(InternetConnectionStatus.connected, InternetConnectionStatus.connected);
      expect(InternetConnectionStatus.disconnected, InternetConnectionStatus.disconnected);
      expect(InternetConnectionStatus.unknown, InternetConnectionStatus.unknown);
    });

    test('extension methods should work correctly', () {
      expect(InternetConnectionStatus.connected.isConnected, true);
      expect(InternetConnectionStatus.connected.isDisconnected, false);
      expect(InternetConnectionStatus.connected.isUnknown, false);

      expect(InternetConnectionStatus.disconnected.isConnected, false);
      expect(InternetConnectionStatus.disconnected.isDisconnected, true);
      expect(InternetConnectionStatus.disconnected.isUnknown, false);

      expect(InternetConnectionStatus.unknown.isConnected, false);
      expect(InternetConnectionStatus.unknown.isDisconnected, false);
      expect(InternetConnectionStatus.unknown.isUnknown, true);
    });
  });

  group('InternetConnectionChecker', () {
    late InternetConnectionChecker checker;

    setUp(() {
      checker = InternetConnectionChecker();
    });

    test('should be singleton', () {
      final checker1 = InternetConnectionChecker();
      final checker2 = InternetConnectionChecker();
      expect(checker1, same(checker2));
    });

    test('should throw error for empty host', () async {
      expect(
        () => checker.checkConnectivity(host: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should return connected for valid domain', () async {
      final status = await checker.checkConnectivity(
        host: 'google.com',
        timeout: Duration(seconds: 5),
      );
      expect(status, InternetConnectionStatus.connected);
    }, timeout: Timeout(Duration(seconds: 10)));

    test('should handle URL and extract domain', () async {
      final status = await checker.checkConnectivity(
        host: 'https://www.google.com/search',
        timeout: Duration(seconds: 5),
      );
      expect(status, InternetConnectionStatus.connected);
    }, timeout: Timeout(Duration(seconds: 10)));

    test('should return disconnected for non-existent domain', () async {
      final status = await checker.checkConnectivity(
        host: 'thisdomaindoesnotexist12345xyz.com',
        timeout: Duration(seconds: 3),
      );
      expect(status, InternetConnectionStatus.disconnected);
    }, timeout: Timeout(Duration(seconds: 5)));

    test('hasConnection should return boolean', () async {
      final hasConnection = await checker.hasConnection(
        host: 'google.com',
        timeout: Duration(seconds: 5),
      );
      expect(hasConnection, isA<bool>());
    }, timeout: Timeout(Duration(seconds: 10)));

    test('should handle timeout correctly', () async {
      final stopwatch = Stopwatch()..start();

      final status = await checker.checkConnectivity(
        host: 'google.com',
        timeout: Duration(milliseconds: 1), // Very short timeout
      );

      stopwatch.stop();

      expect(status, InternetConnectionStatus.disconnected);
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    }, timeout: Timeout(Duration(seconds: 5)));

    test('onStatusChange should emit status changes', () async {
      final stream = checker.onStatusChange(
        interval: Duration(milliseconds: 100),
        host: 'google.com',
        timeout: Duration(seconds: 2),
      );

      final statuses = <InternetConnectionStatus>[];
      final subscription = stream.listen((status) {
        statuses.add(status);
      });

      await Future.delayed(Duration(milliseconds: 300));
      await subscription.cancel();

      expect(statuses, isNotEmpty);
      expect(statuses.first, InternetConnectionStatus.connected);
    }, timeout: Timeout(Duration(seconds: 5)));
  });

  group('Socket-based connectivity checks', () {
    late InternetConnectionChecker checker;

    setUp(() {
      checker = InternetConnectionChecker();
    });

    test('should return connected for valid socket connection', () async {
      final status = await checker.checkConnectivitySocket(
        host: '8.8.8.8',
        port: 53,
        timeout: Duration(seconds: 3),
      );
      expect(status, InternetConnectionStatus.connected);
    }, timeout: Timeout(Duration(seconds: 5)));

    test('should return disconnected for invalid host', () async {
      final status = await checker.checkConnectivitySocket(
        host: '192.0.2.1', // Test network address (RFC 5737)
        port: 53,
        timeout: Duration(seconds: 1),
      );
      expect(status, InternetConnectionStatus.disconnected);
    }, timeout: Timeout(Duration(seconds: 3)));

    test('hasConnectionSocket should return boolean', () async {
      final hasConnection = await checker.hasConnectionSocket(
        host: '8.8.8.8',
        port: 53,
        timeout: Duration(seconds: 2),
      );
      expect(hasConnection, isA<bool>());
    }, timeout: Timeout(Duration(seconds: 5)));

    test('should throw error for invalid port', () async {
      expect(
        () => checker.checkConnectivitySocket(host: '8.8.8.8', port: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => checker.checkConnectivitySocket(host: '8.8.8.8', port: 65536),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for empty host', () async {
      expect(
        () => checker.checkConnectivitySocket(host: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('socket timeout should work correctly', () async {
      final stopwatch = Stopwatch()..start();

      final status = await checker.checkConnectivitySocket(
        host: '8.8.8.8',
        port: 53,
        timeout: Duration(milliseconds: 1), // Very short timeout
      );

      stopwatch.stop();

      expect(status, InternetConnectionStatus.disconnected);
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    }, timeout: Timeout(Duration(seconds: 5)));

    test('onStatusChangeSocket should emit status changes', () async {
      final stream = checker.onStatusChangeSocket(
        interval: Duration(milliseconds: 100),
        host: '8.8.8.8',
        port: 53,
        timeout: Duration(seconds: 1),
      );

      final statuses = <InternetConnectionStatus>[];
      final subscription = stream.listen((status) {
        statuses.add(status);
      });

      await Future.delayed(Duration(milliseconds: 300));
      await subscription.cancel();

      expect(statuses, isNotEmpty);
      expect(statuses.first, InternetConnectionStatus.connected);
    }, timeout: Timeout(Duration(seconds: 3)));
  });
}
