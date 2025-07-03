import pg from 'pg';
import fs from 'fs';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Load environment variables
dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function updateDatabase() {
  const pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
      rejectUnauthorized: false
    }
  });

  pool.on('error', err => {
    console.warn('pool error (ignored):', err.message);
  });

  try {
    // Read and execute schema.sql first
    const schemaSQL = fs.readFileSync(path.join(__dirname, '..', 'schema.sql'), 'utf8');
    await pool.query(schemaSQL);
    console.log('Successfully updated database schema');

    // Then read and execute functions.sql
    const functionsSQL = fs.readFileSync(path.join(__dirname, '..', 'functions.sql'), 'utf8');
    await pool.query(functionsSQL);
    console.log('Successfully updated database functions');
  } catch (error) {
    console.error('Error updating database:', error);
    // Log more details about the error
    if (error.message) console.error('Error message:', error.message);
    if (error.code) console.error('Error code:', error.code);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

updateDatabase(); 