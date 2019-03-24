import 'dart:io';

class NetworkSocket {
  NetworkSocket._();
  static RawDatagramSocket _socket = null;
  SocketCallBack _callBack;
  static final NetworkSocket _networkSocket = NetworkSocket._();

  static NetworkSocket get networkSocket => _networkSocket;

  Future<RawDatagramSocket> get socket async
  {
    if(_socket==null) await init(null);
    return _socket;
  }
  Future<RawDatagramSocket> getInstance(SocketCallBack value) async
  {
    _callBack=value;
    if(_socket==null) await init(value);
    return _socket;
  }
  set callBack(SocketCallBack value) {
    _callBack = value;
  }

  init(SocketCallBack callBack) async{
    _callBack=callBack;
    if (_socket == null) {
      print("init");
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888)
        ..multicastHops = 10
        ..broadcastEnabled = true
        ..writeEventsEnabled = true;
      _socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagramPacket = _socket.receive();
          if (datagramPacket == null) return;

          if (String.fromCharCodes(datagramPacket.data).contains(
              "ASHAL_SERVER")) {
            print("found");
            if(_callBack!=null)
              _callBack.onFoundAddress('${datagramPacket.address.address}');
          }
          print("packet!");
          print(String.fromCharCodes(datagramPacket.data));
        }
      });
    }
  }

  dispose()
  {
    if(_socket!=null)
    {
      _socket.close();
      _socket=null;
    }
  }
}

abstract class SocketCallBack
{
  void onFoundAddress(String address);
}