# Internet Connection CS

A Flutter package to check internet connectivity using pure Dart features without external dependencies.

## Features

- ✅ **No external dependencies** - Uses only Dart's built-in features
- ✅ **DNS Lookup based checks** using `InternetAddress.lookup()`
- ✅ **Socket based checks** for faster, lightweight connectivity testing
- ✅ Configurable timeout duration
- ✅ Simple boolean and enum-based status returns
- ✅ Continuous monitoring with streams
- ✅ Singleton pattern for efficient resource usage
- ✅ Comprehensive error handling
- ✅ URL parsing and domain extraction

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  internet_connection_cs: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage (DNS Lookup)

```dart
import 'package:internet_connection_cs/internet_connection_cs.dart';

// Get the singleton instance
final connectionChecker = InternetConnectionChecker();

// Check connectivity using DNS lookup (default: google.com)
final status = await connectionChecker.checkConnectivity();
print('Status: $status'); // Status: InternetConnectionStatus.connected

// Check connectivity and get boolean result
final hasConnection = await connectionChecker.hasConnection();
print('Has connection: $hasConnection'); // Has connection: true
```

### Custom Host and Timeout

```dart
// Check with custom domain
final status = await connectionChecker.checkConnectivity(
  host: 'github.com', // Domain name only
  timeout: Duration(seconds: 5),
);

// URLs are automatically parsed to extract domain
final urlStatus = await connectionChecker.checkConnectivity(
  host: 'https://www.cloudflare.com/path', // Will use 'www.cloudflare.com'
  timeout: Duration(seconds: 3),
);

final hasConnection = await connectionChecker.hasConnection(
  host: 'api.example.com',
  timeout: Duration(seconds: 3),
);
```

### Socket-based Connectivity (Faster & Lightweight)

```dart
// Socket-based check (faster, uses less data)
final socketStatus = await connectionChecker.checkConnectivitySocket();
print('Socket status: $socketStatus');

// Socket check with boolean result
final hasSocketConnection = await connectionChecker.hasConnectionSocket();
print('Has socket connection: $hasSocketConnection');

// Custom socket parameters (IP address and port)
final customSocketStatus = await connectionChecker.checkConnectivitySocket(
  host: '1.1.1.1', // Cloudflare DNS IP
  port: 53,         // DNS port
  timeout: Duration(seconds: 2),
);
```

### Continuous Monitoring

```dart
// DNS-based monitoring
connectionChecker.onStatusChange(
  interval: Duration(seconds: 10),
  host: 'google.com',
  timeout: Duration(seconds: 3),
).listen((status) {
  if (status.isConnected) {
    print('Internet is available');
  } else {
    print('No internet connection');
  }
});

// Socket-based monitoring (faster)
connectionChecker.onStatusChangeSocket(
  interval: Duration(seconds: 5),
  host: '8.8.8.8',
  port: 53,
  timeout: Duration(seconds: 1),
).listen((status) {
  print('Socket status: $status');
});
```

### Using Status Extensions

```dart
final status = await connectionChecker.checkConnectivity();

if (status.isConnected) {
  // Internet is available
  print('Connected to internet');
} else if (status.isDisconnected) {
  // No internet connection
  print('No internet connection');
} else if (status.isUnknown) {
  // Status is unknown
  print('Connection status unknown');
}
```

## InternetConnectionStatus Enum

The package provides an enum to represent connection status:

```dart
enum InternetConnectionStatus {
  connected,    // Internet connection is available
  disconnected, // Internet connection is not available
  unknown       // Internet connection status is unknown
}
```

### Extension Methods

The enum comes with useful extension methods:

- `isConnected`: Returns `true` if connected
- `isDisconnected`: Returns `true` if disconnected
- `isUnknown`: Returns `true` if status is unknown

## API Reference

### InternetConnectionChecker

#### Methods

##### `checkConnectivity({String host, Duration timeout})`

Checks internet connectivity and returns `InternetConnectionStatus`.

**Parameters:**

- `host` (optional): The host URL to check against. Default: `'https://www.google.com'`
- `timeout` (optional): Request timeout duration. Default: `Duration(seconds: 10)`

**Returns:** `Future<InternetConnectionStatus>`

##### `hasConnection({String host, Duration timeout})`

Checks internet connectivity and returns a boolean.

**Parameters:**

- `host` (optional): The host URL to check against. Default: `'https://www.google.com'`
- `timeout` (optional): Request timeout duration. Default: `Duration(seconds: 10)`

**Returns:** `Future<bool>`

##### `onStatusChange({Duration interval, String host, Duration timeout})`

Creates a stream that periodically checks connectivity.

**Parameters:**

- `interval` (optional): How often to check. Default: `Duration(seconds: 30)`
- `host` (optional): The host URL to check against. Default: `'https://www.google.com'`
- `timeout` (optional): Request timeout duration. Default: `Duration(seconds: 10)`

**Returns:** `Stream<InternetConnectionStatus>`

## Error Handling

The package handles various error scenarios:

- **Network unreachable**: Returns `disconnected`
- **Timeout**: Returns `disconnected`
- **HTTP errors**: Returns `disconnected`
- **Invalid URL format**: Throws `ArgumentError`
- **Empty host**: Throws `ArgumentError`

## Example

See the [example](example/example.dart) file for a complete usage example.

## Testing

Run tests with:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
