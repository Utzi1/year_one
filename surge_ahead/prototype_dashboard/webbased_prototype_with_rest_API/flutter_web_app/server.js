const express = require('express');
const redis = require('redis');

const app = express();
const port = 3000;

// Create a Redis client
const client = redis.createClient({
  host: 'redis', // Use the service name defined in docker-compose.yml
  port: 6379 // Default Redis port
});

// Middleware to parse JSON bodies
app.use(express.json());

// Endpoint to set a value in Redis
app.post('/set', (req, res) => {
  const { key, value } = req.body;
  client.set(key, value, (err, reply) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.send(`Set key ${key} with value ${value}`);
  });
});

// Endpoint to get a value from Redis
app.get('/get/:key', (req, res) => {
  const { key } = req.params;
  client.get(key, (err, reply) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.send(`Value for key ${key} is ${reply}`);
  });
});

// Start the server
app.listen(port, () => {
  console.log(`REST API server running at http://localhost:${port}`);
});

