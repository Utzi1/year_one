class RedisService {
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);
  static const Duration TIMEOUT = Duration(seconds: 5);
  
  String connectionStatus = 'Not connected';
  
  Future<Command?> _connectRedis({int retryCount = 0}) async {
    try {
      final conn = RedisConnection();
      // Use const for development, inject for production
      final redisHost = const String.fromEnvironment('REDIS_HOST', defaultValue: 'redis');
      
      final command = await conn.connect(redisHost, 6379)
          .timeout(TIMEOUT);
      
      connectionStatus = 'Connected to Redis at $redisHost';
      return command;
      
    } on TimeoutException catch (e) {
      connectionStatus = 'Connection timeout: $e';
      if (retryCount < MAX_RETRIES) {
        await Future.delayed(RETRY_DELAY);
        return _connectRedis(retryCount: retryCount + 1);
      }
    } catch (e) {
      connectionStatus = 'Connection error: $e';
      if (retryCount < MAX_RETRIES) {
        await Future.delayed(RETRY_DELAY);
        return _connectRedis(retryCount: retryCount + 1);
      }
    }
    return null;
  }
}
