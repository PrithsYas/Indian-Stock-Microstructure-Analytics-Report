-- Rule-based microstructure clustering

UPDATE normalized_microstructure_features
SET cluster_label = 'Hyper-Volatile & Illiquid'
WHERE norm_avg_range > 0.6
  AND (norm_midday_dead > 0.5 OR norm_close_dead > 0.5);

UPDATE normalized_microstructure_features
SET cluster_label = 'Volatile but Liquid'
WHERE cluster_label IS NULL
  AND norm_avg_range > 0.6
  AND norm_midday_dead < 0.2
  AND norm_open_dead < 0.1;

UPDATE normalized_microstructure_features
SET cluster_label = 'Quiet but Illiquid'
WHERE cluster_label IS NULL
  AND norm_avg_range < 0.3
  AND (norm_midday_dead > 0.4 OR norm_open_dead > 0.4);

UPDATE normalized_microstructure_features
SET cluster_label = 'Safe & Stable'
WHERE cluster_label IS NULL
  AND norm_avg_range < 0.3
  AND norm_midday_dead < 0.1
  AND norm_trend_volatility < 0.3;

UPDATE normalized_microstructure_features
SET cluster_label = 'Choppy Random-Walk'
WHERE cluster_label IS NULL;
