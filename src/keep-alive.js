import https from 'https';
import dotenv from 'dotenv';

dotenv.config();

const PING_INTERVAL = 14 * 60 * 1000; // 14 minutes in milliseconds
const SERVICE_URL = 'https://audit-trail-api.onrender.com/health';

function pingService() {
  https.get(SERVICE_URL, (res) => {
    const { statusCode } = res;
    console.log(`[${new Date().toISOString()}] Ping status: ${statusCode}`);
  }).on('error', (err) => {
    console.error(`[${new Date().toISOString()}] Ping error:`, err.message);
  });
}

// Initial ping
pingService();

// Schedule periodic pings
setInterval(pingService, PING_INTERVAL);

console.log(`Keep-alive service started. Pinging ${SERVICE_URL} every ${PING_INTERVAL/1000/60} minutes.`); 