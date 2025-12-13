CREATE TABLE normalized_microstructure_features AS
WITH stats AS (
  SELECT
    MIN(avg_range_pct)      AS min_avg_range,     MAX(avg_range_pct)      AS max_avg_range,
    MIN(trend_volatility)   AS min_trend_vol,     MAX(trend_volatility)   AS max_trend_vol,
    MIN(tail_risk_index)    AS min_tail_risk,     MAX(tail_risk_index)    AS max_tail_risk,
    MIN(average_trend)      AS min_avg_trend,     MAX(average_trend)      AS max_avg_trend,
    MIN(open_dead_fraction) AS min_open_dead,     MAX(open_dead_fraction) AS max_open_dead,
    MIN(midday_dead_fraction)AS min_midday_dead,   MAX(midday_dead_fraction)AS max_midday_dead,
    MIN(close_dead_fraction) AS min_close_dead,    MAX(close_dead_fraction) AS max_close_dead
  FROM microstructure_features
)
SELECT
  m.symbol,

  -- normalized volatility features (0..1)
  ROUND( (m.avg_range_pct - s.min_avg_range) / NULLIF(s.max_avg_range - s.min_avg_range, 0), 6) AS norm_avg_range,
  ROUND( (m.trend_volatility - s.min_trend_vol) / NULLIF(s.max_trend_vol - s.min_trend_vol, 0), 6) AS norm_trend_volatility,
  ROUND( (m.tail_risk_index - s.min_tail_risk) / NULLIF(s.max_tail_risk - s.min_tail_risk, 0), 6) AS norm_tail_risk,
  ROUND( (m.average_trend - s.min_avg_trend) / NULLIF(s.max_avg_trend - s.min_avg_trend, 0), 6) AS norm_average_trend,

  -- normalized liquidity features (0..1)
  ROUND( (m.open_dead_fraction - s.min_open_dead) / NULLIF(s.max_open_dead - s.min_open_dead, 0), 6) AS norm_open_dead,
  ROUND( (m.midday_dead_fraction - s.min_midday_dead) / NULLIF(s.max_midday_dead - s.min_midday_dead, 0), 6) AS norm_midday_dead,
  ROUND( (m.close_dead_fraction - s.min_close_dead) / NULLIF(s.max_close_dead - s.min_close_dead, 0), 6) AS norm_close_dead

FROM microstructure_features m
CROSS JOIN stats s
ORDER BY m.symbol;
