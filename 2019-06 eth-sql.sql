-- PGPASSWORD=<password> pgcli -h sql.eth.events -p 45432 ethereum_ethereum_mainnet username
-- psql

-- tables: contract, event, token, trace, tx

-- views:
--   mv_erc20_transfers
--   mv_call_block_hash mv_tx_block_hash


-- INSPECT token names
-- let's inspect DAI coins

SELECT * FROM token WHERE symbol ilike 'dai' ;
-- real one: 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359
-- https://etherscan.io/token/0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359


SELECT symbol, count(*) as count
 FROM token
 GROUP BY symbol
 ORDER BY count desc
 LIMIT 100;


-- '0xB8c77482e45F1F44dE1745F52C74426C631bDD52'
-- maker: '0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2'


-- Find the latest 10 BNB Transfers the sender
-- Find the latest 10 BNB Transfer events and extract sender, receiver and value from JSON

SELECT
  *,
  args->0->>'hex' as "from",
  args->1->>'hex' as "to",
  CAST(args->2->'scaled' AS NUMERIC) AS "value"
	FROM event
 WHERE address = '0x96c645D3D3706f793Ef52C19bBACe441900eD47D'
	 AND event = 'Transfer'
 ORDER BY value DESC
 LIMIT 10;

-- CryptoKitties: 0x06012c8cf97bead5deae237070f9587f8e7a266d
-- https://etherscan.io/token/0x06012c8cf97bead5deae237070f9587f8e7a266d

SELECT * FROM mv_erc20_transfers
 WHERE address = '0xd26114cd6EE289AccF82350c8d8487fedB8A0C07' -- OMG Token
 ORDER BY timestamp DESC LIMIT 10;





-- balance per address

SELECT
  "address",
  SUM(value) AS balance
  FROM (
    SELECT
      "from" as address,
      -value as "value"
      FROM mv_erc20_transfers
     WHERE address = '0xcAFE27178308351a12ffFffDeb161d9d730DA082'
		 UNION
    SELECT
      "to" as address,
      value
      FROM mv_erc20_transfers
     WHERE address = '0xcAFE27178308351a12ffFffDeb161d9d730DA082'
  ) AS "values"
  GROUP BY "address"
  HAVING SUM(value) > 0
  ORDER BY SUM(value) DESC
  LIMIT 50;






-- running balance (tokens in circulation) for a token

SELECT
   "day",
   balance,
   SUM(balance) OVER (ORDER BY "day" ASC) AS running_balance
FROM (
   SELECT
     "day",
     SUM(balance) AS balance
   FROM (
     SELECT
        "address",
        "day",
        SUM(value) AS balance
     FROM (
        SELECT
           "from" as address,
           date_trunc('day', "timestamp") AS "day",
           -value as "value"
        FROM mv_erc20_transfers
        WHERE address = '0xcAFE27178308351a12ffFffDeb161d9d730DA082'
     UNION
        SELECT
            "to" as address,
            date_trunc('day', "timestamp") AS "day",
            value
          FROM mv_erc20_transfers
          WHERE address = '0xcAFE27178308351a12ffFffDeb161d9d730DA082'
     ) AS "values"
     GROUP BY "address", "day"
     -- HAVING SUM(value) != 0
   ) AS "balances"
   GROUP BY "day"
) AS "days"
ORDER BY "day" ASC;



---
select sum(gas * gas_price) from tx join mv_erc20_transfers on (tx.contract_address = mv_erc20_transfers.address) where mv_erc20_transfers.address = '0x58b6A8A3302369DAEc383334672404Ee733aB239';
