Future<void> _connectRedis() async {
    try {
      final conn = RedisConnection();
      final command = await conn.connect('redis', 6379)
          .timeout(const Duration(seconds: 5));
      
      // Simple test write/read
      await command.set('test_key', 'Hello Redis!');
      final result = await command.get('test_key');
      
      setState(() {
        status = 'Connected! Test value: $result';
      });
    } on TimeoutException catch (_) {
      setState(() {
        status = 'Connection timed out';
      });
    } catch (e) {
      setState(() {
        status = 'Connection failed: $e';
      });
    }
  }


