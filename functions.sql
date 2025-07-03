-- Function to get user balance and transaction history
CREATE OR REPLACE FUNCTION fn_get_user_balance_and_history(user_id INT)
RETURNS TABLE (
  transactionid INT,
  transactiontype VARCHAR(10),
  userid INT,
  fulltimestamp TIMESTAMP,
  status VARCHAR(10),
  senderamount NUMERIC(10,2),
  receiveramount NUMERIC(10,2),
  sendercurrency VARCHAR(3),
  receivercurrency VARCHAR(3),
  senderid INT,
  receiverid INT,
  amt_in_base NUMERIC,
  running_balance NUMERIC
) AS $$
WITH base AS (
  SELECT currency AS base_ccy 
  FROM users 
  WHERE userId = $1
),
fx AS (
  SELECT fromCurrency, conversionRate
  FROM currencyConversions, base
  WHERE toCurrency = base_ccy
),
norm AS (
  SELECT
    t.*,
    CASE
      WHEN transactionType='deposit'    AND userId=$1 THEN senderAmount
      WHEN transactionType='withdrawal' AND userId=$1 THEN -senderAmount
      WHEN transactionType='transfer'   AND receiverId=$1 THEN
           receiverAmount * COALESCE((SELECT conversionRate FROM fx WHERE fromCurrency=receiverCurrency),1)
      WHEN transactionType='transfer'   AND senderId=$1 THEN
           -senderAmount * COALESCE((SELECT conversionRate FROM fx WHERE fromCurrency=senderCurrency),1)
    END AS amt_in_base
  FROM transactions t
  WHERE status='successful' 
    AND (senderId=$1 OR receiverId=$1)
)
SELECT *,
       SUM(amt_in_base) OVER (ORDER BY fullTimestamp) AS running_balance
FROM norm
ORDER BY fullTimestamp;
$$ LANGUAGE sql;

-- Function to get incoming transfer audit trail
CREATE OR REPLACE FUNCTION fn_get_incoming_transfer_trail(user_id INT)
RETURNS TABLE (
  transactionid INT,
  transactiontype VARCHAR(10),
  userid INT,
  fulltimestamp TIMESTAMP,
  status VARCHAR(10),
  senderamount NUMERIC(10,2),
  receiveramount NUMERIC(10,2),
  sendercurrency VARCHAR(3),
  receivercurrency VARCHAR(3),
  senderid INT,
  receiverid INT,
  hop INT
) AS $$
WITH RECURSIVE trail AS (
  SELECT t.*, 1 AS hop
  FROM transactions t
  WHERE t.transactionType='transfer'
    AND t.status='successful'
    AND t.receiverId=$1

  UNION ALL

  SELECT t2.*, tr.hop+1
  FROM trail tr
  JOIN transactions t2 ON t2.receiverId = tr.senderId
  WHERE t2.transactionType='transfer'
    AND t2.status='successful'
    AND tr.hop < 5
)
SELECT * 
FROM trail 
ORDER BY hop, fullTimestamp;
$$ LANGUAGE sql; 