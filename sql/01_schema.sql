-- Schema definitions for intraday microstructure project

CREATE TABLE intraday_minute_bars (
    symbol text,
    ts timestamptz,
    open numeric,
    high numeric,
    low numeric,
    close numeric,
    volume numeric,
    close_trade_only numeric,
    last_traded_close numeric
);

CREATE TABLE intraday_block_liquidity (
    symbol text,
    date date,
    block text,
    total_minutes int,
    traded_minutes int,
    zero_minutes int,
    dead_fraction numeric
);

CREATE TABLE microstructure_features (
    symbol text PRIMARY KEY,
    avg_range_pct numeric,
    trend_volatility numeric,
    tail_risk_index numeric,
    average_trend numeric,
    open_dead_fraction numeric,
    midday_dead_fraction numeric,
    close_dead_fraction numeric
);

CREATE TABLE normalized_microstructure_features (
    symbol text PRIMARY KEY,
    norm_avg_range numeric,
    norm_trend_volatility numeric,
    norm_tail_risk numeric,
    norm_average_trend numeric,
    norm_open_dead numeric,
    norm_midday_dead numeric,
    norm_close_dead numeric,
    cluster_label text
);
