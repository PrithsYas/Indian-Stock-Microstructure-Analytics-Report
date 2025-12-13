-- Block-level liquidity measurement using dead-fraction

-- Blocks: OPEN, MIDDAY, CLOSE
-- Dead-fraction = zero-volume minutes / total minutes

INSERT INTO intraday_block_liquidity
SELECT
    symbol,
    DATE(ts) AS date,
    CASE
        WHEN EXTRACT(HOUR FROM ts) < 10 THEN 'OPEN'
        WHEN EXTRACT(HOUR FROM ts) BETWEEN 12 AND 13 THEN 'MIDDAY'
        ELSE 'CLOSE'
    END AS block,
    COUNT(*) AS total_minutes,
    COUNT(*) FILTER (WHERE volume > 0) AS traded_minutes,
    COUNT(*) FILTER (WHERE volume = 0) AS zero_minutes,
    COUNT(*) FILTER (WHERE volume = 0)::numeric / COUNT(*) AS dead_fraction
FROM intraday_minute_bars
GROUP BY symbol, DATE(ts), block;
