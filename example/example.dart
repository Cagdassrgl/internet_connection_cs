import 'package:internet_connection_cs/internet_connection_cs.dart';

void main() async {
  final connectionChecker = InternetConnectionChecker();

  print('=== DNS Lookup Based Connectivity Check ===');

  // Basit bağlantı kontrolü (DNS lookup)
  print('Checking connection with DNS lookup...');
  final status = await connectionChecker.checkConnectivity();
  print('DNS lookup status: $status');

  // Boolean değer ile kontrol
  final hasConnection = await connectionChecker.hasConnection();
  print('Has connection: $hasConnection');

  // Özel host ile kontrol (domain name)
  final customStatus = await connectionChecker.checkConnectivity(
    host: 'github.com', // Sadece domain name, protokol gereksiz
    timeout: Duration(seconds: 5),
  );
  print('GitHub DNS lookup status: $customStatus');

  // URL'den domain çıkarma testi
  final urlStatus = await connectionChecker.checkConnectivity(
    host: 'https://www.cloudflare.com/path/to/page', // URL'den domain çıkarılacak
    timeout: Duration(seconds: 3),
  );
  print('Cloudflare URL status: $urlStatus');

  print('\n=== Socket Based Connectivity Check (Faster) ===');

  // Socket ile bağlantı kontrolü (daha hızlı)
  final socketStatus = await connectionChecker.checkConnectivitySocket();
  print('Socket connection status: $socketStatus');

  // Socket ile boolean kontrol
  final hasSocketConnection = await connectionChecker.hasConnectionSocket();
  print('Has socket connection: $hasSocketConnection');

  // Özel IP ve port ile socket kontrolü
  final customSocketStatus = await connectionChecker.checkConnectivitySocket(
    host: '1.1.1.1', // Cloudflare DNS
    port: 53,
    timeout: Duration(seconds: 2),
  );
  print('Cloudflare DNS socket status: $customSocketStatus');

  print('\n=== Continuous Monitoring ===');

  // DNS tabanlı sürekli kontrol
  print('Starting DNS-based continuous monitoring...');
  connectionChecker
      .onStatusChange(
    interval: Duration(seconds: 15),
    host: 'google.com',
    timeout: Duration(seconds: 3),
  )
      .listen((status) {
    print('DNS Status changed: $status');
  });

  // Socket tabanlı sürekli kontrol (daha hızlı)
  print('Starting Socket-based continuous monitoring...');
  connectionChecker
      .onStatusChangeSocket(
    interval: Duration(seconds: 5),
    host: '8.8.8.8',
    port: 53,
    timeout: Duration(seconds: 1),
  )
      .listen((status) {
    print('Socket Status changed: $status');
  });

  // Extension kullanımı
  print('\n=== Status Extensions ===');
  final testStatus = await connectionChecker.checkConnectivity();

  if (testStatus.isConnected) {
    print('✅ Internet bağlantısı mevcut');
  } else if (testStatus.isDisconnected) {
    print('❌ Internet bağlantısı yok');
  } else if (testStatus.isUnknown) {
    print('❓ Bağlantı durumu bilinmiyor');
  }

  // Örnekte programın çalışmaya devam etmesi için bekle
  await Future.delayed(Duration(seconds: 30));
}
