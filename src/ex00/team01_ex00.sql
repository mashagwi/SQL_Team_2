WITH ranked_currency AS (
    SELECT
        id,
        name,
        rate_to_usd,
        updated,
        ROW_NUMBER() OVER (PARTITION BY name ORDER BY updated DESC) AS rn
    FROM currency
), last_rate_currency AS (
	SELECT id, name, rate_to_usd FROM ranked_currency
	WHERE rn = 1
)

SELECT
	COALESCE(u.name, 'not defined') AS name,
	COALESCE(u.lastname, 'not defined') AS lastname,
	b.type AS type,
	SUM(b.money) AS volume,
	COALESCE(lrc.name, 'not defined') AS currency_name,
	COALESCE(lrc.rate_to_usd, 1) AS last_rate_to_usd,
	CAST(SUM(b.money) *  COALESCE(lrc.rate_to_usd, 1) AS REAL) AS total_sum
FROM "user" u
FULL JOIN balance b ON b.user_id = u.id
LEFT JOIN last_rate_currency lrc ON lrc.id = b.currency_id 
GROUP BY u.name, u.lastname, b.type, lrc.name, lrc.rate_to_usd
ORDER BY name DESC, lastname, type;