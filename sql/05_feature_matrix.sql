-- Join volatility and liquidity metrics

UPDATE microstructure_features m
SET
    open_dead_fraction = l.avg_open,
    midday_dead_fraction = l.avg_midday,
    close_dead_fraction = l.avg_close
FROM (
    SELECT
        symbol,
        AVG(CASE WHEN block = 'OPEN' THEN dead_fraction END) AS avg_open,
        AVG(CASE WHEN block = 'MIDDAY' THEN dead_fraction END) AS avg_midday,
        AVG(CASE WHEN block = 'CLOSE' THEN dead_fraction END) AS avg_close
    FROM intraday_block_liquidity
    GROUP BY symbol
) l
WHERE m.symbol = l.symbol;
