# Audit Trail System

A production-ready audit trail system built with Node.js, Express, and Supabase/PostgreSQL. This system tracks user balances, transactions, and provides detailed audit trails for incoming transfers.

## Live Demo
API Base URL: https://audit-trail-api.onrender.com

Test the API:
```bash
# Check API health
curl https://audit-trail-api.onrender.com/health

# Get audit trail for user 1
curl https://audit-trail-api.onrender.com/audit/1
```

## Features

- Balance history with currency conversion
- Multi-currency support
- Recursive transfer trail tracking (up to 5 hops)
- Real-time audit trail generation
- Support for various transaction types:
  - Deposits
  - Withdrawals
  - Transfers
  - Chama contributions
  - M-PESA style transfers
  - Utility payments
  - Emergency fund collections
  - School fees payments

## Tech Stack

- Node.js & Express
- PostgreSQL 15 (via Supabase)
- ES Modules
- Nodemon for development

## Setup

1. **Create a Supabase Project**
   - Go to [Supabase](https://supabase.com)
   - Create a new project
   - Get your database connection details

2. **Environment Setup**
   ```bash
   # Clone the repository
   git clone url
   cd audit-trail-system

   # Install dependencies
   npm install

   # Create .env file
   cp .env.example .env
   ```

3. **Configure Environment**
   Edit `.env` and add your Supabase database URL using the session pooler endpoint:
   ```
   DATABASE_URL=postgresql://postgres.[ref]:[password]@aws-0-eu-north-1.pooler.supabase.com:5432/postgres
   PORT=3000
   ```
   Note: Always use the session pooler endpoint (aws-0-eu-north-1.pooler.supabase.com) for better connection handling.

4. **Initialize Database**
   ```bash
   npm run db:update
   ```
   This will create all SQL functions in your Supabase database.

## Development

```bash
# Start development server with hot reload
npm run dev

# Start production server
npm start
```

## Deployment

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Deploy on Render**
   - Go to [Render.com](https://render.com)
   - Sign up/Login with GitHub
   - Create a new Web Service
   - Connect your repository
   - Configure:
     - Build Command: `npm install`
     - Start Command: `node src/index.js`
     - Add Environment Variables:
       - DATABASE_URL: Your Supabase connection string
       - PORT: 10000

3. **Verify Deployment**
   ```bash
   # Check API health
   curl https://<your-app>.onrender.com/health

   # Test with sample user
   curl https://<your-app>.onrender.com/audit/1
   ```

## API Endpoints

### GET /health
Returns API and database health status.

Response:
```json
{
  "status": "healthy",
  "database": "connected"
}
```

### GET /audit/:userId
Returns a user's complete audit trail including:
- Transaction history with running balance
- Incoming transfer trail (up to 5 hops)
- Final balance in user's base currency

Example response:
```json
{
  "userId": "1",
  "finalBalance": 5000.00,
  "history": [
    {
      "transactionid": 1,
      "transactiontype": "deposit",
      "amount": 1000.00,
      "currency": "KES",
      "timestamp": "2024-03-15T10:00:00Z",
      "running_balance": 1000.00
    }
  ],
  "incomingTrail": [
    {
      "transactionid": 2,
      "senderid": 3,
      "amount": 500.00,
      "currency": "KES",
      "timestamp": "2024-03-15T11:00:00Z",
      "hop": 1
    }
  ]
}
```

## Security Notes

1. **Environment Variables**
   - Never commit `.env` file
   - Use `.env.example` for documentation
   - Rotate credentials if ever exposed

2. **Database Connection**
   - Always use session pooler endpoint
   - Enable SSL for database connections
   - Keep connection pool size reasonable

## Error Handling

The system handles various error cases:
- Database connection issues
- Invalid user IDs
- Transaction processing errors
- Currency conversion edge cases

### Database Error Handling
The system includes robust database error handling:

1. **Pool Error Handling**
   ```javascript
   // Add error listener to prevent crashes
   pool.on('error', err => {
     console.warn('pool error (ignored):', err.message);
   });
   ```

2. **Graceful Shutdown**
   ```javascript
   try {
     await pool.query(migrations);
     console.log('Success');
   } finally {
     await pool.end();            // Close connections gracefully
     process.exit(0);             // Exit cleanly
   }
   ```

## Maintenance

To update database functions:
```bash
npm run db:update
```

The update process includes:
1. Graceful connection handling
2. Error logging
3. Clean process termination
4. Automatic retry on certain errors

## License

MIT 