import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multicast_lock/multicast_lock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var socket=null;
  final multicastLock = new MulticastLock();

  String _packets='';
  
  void _initListener () async {

    multicastLock.acquire();

    // example listener code
    if(socket==null) {
       socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888)
        ..multicastHops = 10
        ..broadcastEnabled = true
        ..writeEventsEnabled = true;

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagramPacket = socket.receive();
          if (datagramPacket == null) return;

          setState(() {
            if (String.fromCharCodes(datagramPacket.data).contains(
                "ASHAL_SERVER"))
              _packets = '$_packets\n${datagramPacket.address.address}';
          });

          print("packet!");
          print(datagramPacket);
        }
      });
    }
    socket.send("Where-are-you-ashal?".codeUnits, InternetAddress("255.255.255.255"), 8888);
  }


  @override
  void dispose() {
    multicastLock.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Listening to packets: ',
            ),
            Text(
              '$_packets',
              style: Theme.of(context).textTheme.display1.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){_initListener();},
        tooltip: 'Listen',
        child: Icon(Icons.hearing),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
