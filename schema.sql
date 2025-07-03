-- Users table
CREATE TABLE IF NOT EXISTS users (
  userId      INT PRIMARY KEY,
  balance     NUMERIC(10,2) NOT NULL DEFAULT 0,
  currency    VARCHAR(3) NOT NULL
);

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
  transactionId   INT PRIMARY KEY,
  transactionType VARCHAR(10) NOT NULL CHECK (transactionType IN ('deposit', 'withdrawal', 'transfer')),
  userId          INT NOT NULL REFERENCES users(userId),
  fullTimestamp   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status          VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'successful', 'failed')),
  senderAmount    NUMERIC(10,2) NOT NULL,
  receiverAmount  NUMERIC(10,2) NOT NULL,
  senderCurrency  VARCHAR(3) NOT NULL,
  receiverCurrency VARCHAR(3) NOT NULL,
  senderId        INT REFERENCES users(userId),
  receiverId      INT REFERENCES users(userId),
  CONSTRAINT valid_transaction CHECK (
    (transactionType IN ('deposit', 'withdrawal') AND senderAmount = receiverAmount 
     AND senderCurrency = receiverCurrency)
    OR
    (transactionType = 'transfer')
  )
);

-- Currency conversions table
CREATE TABLE IF NOT EXISTS currencyConversions (
  fromCurrency   VARCHAR(3) NOT NULL,
  toCurrency     VARCHAR(3) NOT NULL,
  conversionRate NUMERIC(10,6) NOT NULL,
  updatedAt      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (fromCurrency, toCurrency)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_transactions_userid ON transactions(userId);
CREATE INDEX IF NOT EXISTS idx_transactions_senderid ON transactions(senderId);
CREATE INDEX IF NOT EXISTS idx_transactions_receiverid ON transactions(receiverId);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_timestamp ON transactions(fullTimestamp);

-- Trigger to update updatedAt in currencyConversions
CREATE OR REPLACE FUNCTION update_currency_conversion_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER currency_conversion_timestamp
    BEFORE UPDATE ON currencyConversions
    FOR EACH ROW
    EXECUTE FUNCTION update_currency_conversion_timestamp(); 