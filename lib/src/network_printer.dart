import 'dart:io';
import 'enums.dart';

class PrinterNetworkManager {
  late String _host;
  int _port = 9100;
  bool _isConnected = false;
  Duration _timeout = const Duration(seconds: 5);
  late Socket _socket;

  PrinterNetworkManager(
    String host, {
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) {
    _host = host;
    _port = port;
    _timeout = timeout;
  }

  Future<PosPrintResult> connect(
      {Duration? timeout: const Duration(seconds: 5)}) async {
    try {
      _socket = await Socket.connect(_host, _port, timeout: _timeout);
      _isConnected = true;
      return PosPrintResult.success;
    } catch (e) {
      _isConnected = false;
      return PosPrintResult.timeout;
    }
  }

  Future<PosPrintResult> printTicket(List<int> data,
      {bool isDisconnect = true}) async {
    try {
      if (!_isConnected) {
        final r = await connect();
        if(r!=PosPrintResult.success){
          return r;
        }
      }
      _socket.add(data);
      if (isDisconnect) {
        await disconnect();
      }
      return PosPrintResult.success;
    } catch (e) {
      return PosPrintResult.timeout;
    }
  }

  Future<PosPrintResult> disconnect({Duration? timeout}) async {
    await _socket.flush();
    await _socket.close();
    _isConnected = false;
    if (timeout != null) {
      await Future.delayed(timeout, () => null);
    }
    return PosPrintResult.success;
  }
}
