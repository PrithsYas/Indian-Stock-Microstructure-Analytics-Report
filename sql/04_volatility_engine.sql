-- Daily volatility and tail-risk metrics

INSERT INTO microstructure_features (symbol, avg_range_pct, trend_volatility, tail_risk_index, average_trend)
SELECT
    symbol,
    AVG((high - low) / NULLIF(open, 0)) * 100 AS avg_range_pct,
    STDDEV((close - open) / NULLIF(open, 0)) * 100 AS trend_volatility,
    AVG(
        CASE WHEN ABS((close - open) / NULLIF(open, 0)) > 0.02 THEN 1 ELSE 0 END
    ) AS tail_risk_index,
    AVG((close - open) / NULLIF(open, 0)) * 100 AS average_trend
FROM intraday_minute_bars
GROUP BY symbol;
