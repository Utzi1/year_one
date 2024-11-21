/// This function takes a list of integers and returns a new list with each 
/// integer incremented by one.
///
/// The function iterates through the input list, increments each integer by one,
/// and adds the result to a new list, which is then returned.
///
/// Example:
/// ```dart
/// List<int> numbers = [1, 2, 3];
/// List<int> incrementedNumbers = incrementList(numbers);
/// print(incrementedNumbers); // Output: [2, 3, 4]
/// ```
///
/// - Parameter numbers: A list of integers to be incremented.
/// - Returns: A new list of integers, each incremented by one.
import 'package:flutter/material.dart';
import 'package:redis/redis.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

/// The main application widget which extends [StatelessWidget].
/// 
/// This is the entry point of the Flutter application. It sets up the 
/// application and provides the necessary configuration for the app to run.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Redis App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardPage(),
    );
  }
}

/// A stateful widget that represents the dashboard page of the application.
/// 
/// This widget is responsible for displaying the main dashboard interface,
/// including various widgets and components that provide an overview of
/// the application's key metrics and functionalities.
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

/// The `_DashboardPageState` class is a private state class for the `DashboardPage` widget.
/// It manages the state and behavior of the `DashboardPage` widget.
class _DashboardPageState extends State<DashboardPage> {
  final RedisConnection _redisConnection = RedisConnection();
  Command? _redisCommand; // Make _redisCommand nullable
  String _data = 'No data';

  @override
  void initState() {
    super.initState();
    _connectToRedis();
  }

  /// Connects to the Redis server asynchronously.
  ///
  /// This method establishes a connection to the Redis server.
  /// It is an asynchronous operation and should be awaited.
  ///
  /// Throws an exception if the connection fails.
  Future<void> _connectToRedis() async {
    try {
      final redisHost = Platform.environment['REDIS_HOST'] ?? 'localhost';
      final redisPort = int.parse(Platform.environment['REDIS_PORT'] ?? '6379');
      _redisCommand = await _redisConnection.connect(redisHost, redisPort);
      setState(() {
        _data = 'Connected to Redis';
      });
    } catch (e) {
      setState(() {
        _data = 'Failed to connect to Redis: $e';
      });
      if (e is SocketException) {
        print('SocketException: ${e.message}');
      } else if (e is OSError) {
        print('OSError: ${e.message}, errno = ${e.errorCode}');
      } else {
        print('Unexpected error: $e');
      }
    }
  }

  /// Fetches data from a Redis database asynchronously.
  ///
  /// This method connects to a Redis instance and retrieves the required data.
  /// It is an asynchronous operation and should be awaited to ensure the data
  /// is fully retrieved before proceeding.
  ///
  /// Throws:
  /// - [RedisConnectionException] if there is an issue connecting to the Redis database.
  /// - [DataRetrievalException] if there is an error during data retrieval.
  Future<void> _getDataFromRedis() async {
    if (_redisCommand == null) return;
    try {
      var result = await _redisCommand!.send_object(['GET', 'mykey']);
      setState(() {
        _data = result ?? 'No data found';
      });
    } catch (e) {
      setState(() {
        _data = 'Failed to get data: $e';
      });
    }
  }

  /// Sets data to Redis asynchronously.
  ///
  /// This method performs an asynchronous operation to store data in a Redis database.
  /// It does not return any value.
  ///
  /// Usage:
  /// ```dart
  /// await _setDataToRedis();
  /// ```
  ///
  /// Throws:
  /// - [SomeSpecificException] if the operation fails.
  ///
  /// Note: Ensure that the Redis server is running and accessible before calling this method.
  Future<void> _setDataToRedis() async {
    if (_redisCommand == null) return;
    try {
      await _redisCommand!.send_object(['SET', 'mykey', 'Hello, Redis!']);
      setState(() {
        _data = 'Data set to Redis';
      });
    } catch (e) {
      setState(() {
        _data = 'Failed to set data: $e';
      });
    }
  }

  /// Overrides a method in the superclass.
  ///
  /// This annotation indicates that the method is intended to override a method
  /// in a superclass. It helps to catch errors if the method does not actually
  /// override anything.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Redis App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_data),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getDataFromRedis,
              child: Text('Get Data from Redis'),
            ),
            ElevatedButton(
              onPressed: _setDataToRedis,
              child: Text('Set Data to Redis'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _redisConnection.close();
    super.dispose();
  }
}
