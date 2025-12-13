-- Data ingestion and performance setup

-- \copy intraday_minute_bars FROM 'path/to/file.csv' WITH (FORMAT csv, HEADER true);

-- Indexing for performance
CREATE INDEX idx_intraday_symbol_ts
ON intraday_minute_bars(symbol, ts);
