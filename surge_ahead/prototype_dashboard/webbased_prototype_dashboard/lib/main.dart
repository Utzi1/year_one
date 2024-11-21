import 'package:flutter/material.dart';
import 'package:redis/redis.dart';

class ConnectionStatusPage extends StatefulWidget {
  @override
  _ConnectionStatusPageState createState() => _ConnectionStatusPageState();
}

class _ConnectionStatusPageState extends State<ConnectionStatusPage> {
  String _connectionStatus = 'Disconnected';

  Future<void> _connectToServer() async {
    final conn = RedisConnection();
    try {
      final command = await conn.connect('localhost', 6379)
          .timeout(const Duration(seconds: 5));
      setState(() {
        _connectionStatus = 'Connected!';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
      });
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Status'),
      ),
      body: Center(
        child: Text(_connectionStatus),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectToServer,
        tooltip: 'Connect',
        child: Icon(Icons.wifi),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ConnectionStatusPage(),
  ));
}
import 'package:flutter/material.dart';
import 'package:redis/redis.dart';

class ConnectionStatusPage extends StatefulWidget {
  @override
  _ConnectionStatusPageState createState() => _ConnectionStatusPageState();
}

class _ConnectionStatusPageState extends State<ConnectionStatusPage> {
  String _connectionStatus = 'Disconnected';

  Future<void> _connectToServer() async {
    final conn = RedisConnection();
    try {
      final command = await conn.connect('localhost', 6379)
          .timeout(const Duration(seconds: 5));
      setState(() {
        _connectionStatus = 'Connected!';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
      });
    } finally {
      await conn.close();
    }
  }

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Status'),
      ),
      body: Center(
        child: Text(_connectionStatus),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectToServer,
        tooltip: 'Connect',
        child: Icon(Icons.wifi),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ConnectionStatusPage(),
  ));
}

