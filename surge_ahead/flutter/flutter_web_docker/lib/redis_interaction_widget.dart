import 'package:flutter/material.dart';
import 'package:redis/redis.dart';

class RedisInteractionWidget extends StatefulWidget {
  const RedisInteractionWidget({Key? key}) : super(key: key);

  @override
  _RedisInteractionWidgetState createState() => _RedisInteractionWidgetState();
}

class _RedisInteractionWidgetState extends State<RedisInteractionWidget> {
  final TextEditingController _controller = TextEditingController();
  late RedisConnection _redisConnection;
  Command? _command;
  String _retrievedValue = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _connectToRedis();
  }

  Future<void> _connectToRedis() async {
    try {
      _redisConnection = RedisConnection();
      await _redisConnection.connect('redis', 6379);
      _command = _redisConnection.send_object;
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to Redis: $e';
      });
    }
  }

  Future<void> _writeToRedis(String value) async {
    try {
      await _command?.send_object(['SET', 'my_key', value]);
      final retrievedValue = await _command?.send_object(['GET', 'my_key']);
      setState(() {
        _retrievedValue = retrievedValue ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to write to Redis: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: 'Enter value to store in Redis'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _writeToRedis(_controller.text);
          },
          child: Text('Write to Redis'),
        ),
        SizedBox(height: 20),
        Text('Retrieved value from Redis: $_retrievedValue'),
      ],
    );
  }
}
