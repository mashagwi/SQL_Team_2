-- INSERT INTO currency VALUES (100, 'EUR', 0.85, '2022-01-01 13:29');
-- INSERT INTO currency VALUES (100, 'EUR', 0.79, '2022-01-08 13:29');

CREATE OR REPLACE FUNCTION get_rate(pid NUMERIC, pdate timestamptz)
	RETURNS NUMERIC
AS $$
	WITH t1 AS (
		SELECT rate_to_usd
		FROM currency
		WHERE id = pid AND updated <= pdate
		ORDER BY updated DESC
		LIMIT 1
	), t2 AS (
		SELECT rate_to_usd
		FROM currency
		WHERE id = pid AND updated > pdate
		ORDER BY updated ASC
		LIMIT 1
	)
	SELECT tf.rate_to_usd
	FROM (
		SELECT * FROM t1
		UNION ALL
		SELECT * FROM t2
	) as tf
	LIMIT 1
$$ 	LANGUAGE SQL;
	
SElECT DISTINCT
	COALESCE("user".name, 'not defined') AS name,
	COALESCE("user".lastname, 'not defined') AS lastname,
	currency.name AS currency_name,
	CAST(ROUND(money * get_rate(currency_id, balance.updated), 6) AS REAL) AS currency_in_usd
FROM balance
LEFT JOIN "user" ON "user".id = balance.user_id
JOIN currency ON currency_id = currency.id
ORDER BY name DESC, lastname, currency_name, currency_in_usd;