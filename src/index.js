import express from 'express';
import pg from 'pg';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

const SQL_HISTORY = 'SELECT * FROM fn_get_user_balance_and_history($1)';
const SQL_TRAIL = 'SELECT * FROM fn_get_incoming_transfer_trail($1)';

app.use(express.json());

// Root endpoint with API information
app.get('/', (req, res) => {
  res.json({
    name: 'Audit Trail API',
    version: '1.0.0',
    description: 'API for tracking financial transactions and generating audit trails',
    endpoints: {
      '/': 'API information (you are here)',
      '/health': 'Check API and database health',
      '/audit/:userId': 'Get audit trail for a specific user'
    },
    documentation: 'https://github.com/craigouma/Audit-Trail-API#api-endpoints'
  });
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', database: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', database: 'disconnected', error: err.message });
  }
});

app.get('/audit/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`Processing audit request for user ${userId}`);
    
    const [history, trail] = await Promise.all([
      pool.query(SQL_HISTORY, [userId]),
      pool.query(SQL_TRAIL, [userId])
    ]);
    
    console.log(`Found ${history.rows.length} history records and ${trail.rows.length} trail records`);
    
    const finalBalance = history.rows.at(-1)?.running_balance ?? 0;
    res.json({ 
      userId, 
      finalBalance, 
      history: history.rows, 
      incomingTrail: trail.rows 
    });
  } catch (err) {
    console.error('Error processing audit request:', err);
    res.status(500).json({ 
      error: 'Internal error', 
      details: err.message 
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Audit API running on :${PORT}`)); 