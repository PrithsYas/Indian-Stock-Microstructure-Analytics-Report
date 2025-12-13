# save as C:\Indian_microstructure\load_all_minute_bars.py

import os
import psycopg2
from psycopg2 import sql

# -----------------------
# CONFIG - adjust paths
# -----------------------
CSV_DIR = r"C:/data/processed/clean_intraday"   # folder with your CSVs
DB_PARAMS = {
    "dbname": "indian_microstructure",
    "user": "postgres",
    "password": "prithsDB5",     # <-- replace this
    "host": "localhost",
    "port": 5432
}
# -----------------------

def ensure_processed_table(conn):
    with conn.cursor() as cur:
        cur.execute("""
        CREATE TABLE IF NOT EXISTS _processed_symbols (
            symbol TEXT PRIMARY KEY,
            loaded_at TIMESTAMP DEFAULT now()
        );
        """)
    conn.commit()

def get_already_processed(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT symbol FROM _processed_symbols;")
        rows = cur.fetchall()
    return set(r[0] for r in rows)

def list_csv_files(directory):
    files = [f for f in os.listdir(directory) if f.endswith(".csv")]
    paths = [os.path.join(directory, f) for f in files]
    return sorted(paths)

def symbol_from_filename(path):
    fn = os.path.basename(path)
    return fn.split("__")[0]

def copy_into_staging(conn, csv_path):
    with conn.cursor() as cur, open(csv_path, "r", encoding="utf-8") as f:
        copy_sql = """
        COPY intraday_minute_staging(ts, open, high, low, close, volume, close_trade_only, last_traded_close)
        FROM STDIN WITH (FORMAT csv, HEADER true)
        """
        cur.copy_expert(copy_sql, f)
    conn.commit()

def promote_to_final(conn, symbol):
    with conn.cursor() as cur:
        cur.execute(sql.SQL("""
            WITH s AS (
              SELECT
                ts,
                COALESCE(open, close_trade_only, last_traded_close) AS open_f,
                COALESCE(close, close_trade_only, last_traded_close) AS close_f,
                high,
                low,
                volume
              FROM intraday_minute_staging
            )
            INSERT INTO intraday_minute_bars(symbol, ts, open, high, low, close, volume)
            SELECT
                %s AS symbol,
                ts,
                open_f,
                COALESCE(high, GREATEST(open_f, close_f)) AS high_f,
                COALESCE(low,  LEAST(open_f, close_f))  AS low_f,
                close_f,
                CAST(COALESCE(volume, 0) AS BIGINT)
            FROM s
            WHERE ts IS NOT NULL
              AND open_f IS NOT NULL
              AND close_f IS NOT NULL
            ON CONFLICT (symbol, ts) DO NOTHING;
        """), [symbol])
        cur.execute("INSERT INTO _processed_symbols(symbol) VALUES (%s) ON CONFLICT DO NOTHING;", [symbol])
        cur.execute("TRUNCATE TABLE intraday_minute_staging;")
    conn.commit()


def main():
    csv_files = list_csv_files(CSV_DIR)
    print(f"Found {len(csv_files)} CSV files in {CSV_DIR}")

    conn = psycopg2.connect(**DB_PARAMS)
    try:
        ensure_processed_table(conn)
        processed = get_already_processed(conn)
        print("Already processed symbols:", len(processed))

        for path in csv_files:
            sym = symbol_from_filename(path)
            if sym in processed:
                print(f"[SKIP] {sym} (already done)")
                continue

            print(f"[LOAD] {sym} from {path}")
            try:
                copy_into_staging(conn, path)
                with conn.cursor() as cur:
                    cur.execute("SELECT COUNT(*) FROM intraday_minute_staging;")
                    n = cur.fetchone()[0]
                print(f"  staging rows = {n}")

                print(f"  promoting {sym} to final table...")
                promote_to_final(conn, sym)
                print(f"  done: {sym}")
                processed.add(sym)

            except Exception as e:
                conn.rollback()
                print("ERROR while processing", sym, e)
                print("Stopping run so you can inspect the issue.")
                raise

        print("All files processed.")

    finally:
        conn.close()

if __name__ == "__main__":
    main()
