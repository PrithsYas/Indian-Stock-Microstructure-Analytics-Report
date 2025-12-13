# Indian Stock Market Microstructure Analysis  
### Intraday Volatility and Liquidity Structure Using Minute-Level Data

---

**Summary:**  
This study analyzes ~54 million minute-level records across 150 NSE equities to classify stocks into execution-risk regimes based on intraday liquidity and volatility microstructure.


## 1. Problem Statement

Intraday price behavior in equity markets is not driven solely by information flow or fundamentals. 
A significant portion of observed price movement arises from **market microstructure effects**, such as liquidity availability, trade clustering, and execution dynamics.

In the Indian equity market, while daily returns and end-of-day volatility are widely studied, **intraday liquidity behavior and execution risk remain underexplored**, especially at scale across a broad universe of stocks.

This project aims to answer the following core questions:

- How does liquidity vary within the trading day across Indian equities?
- Which stocks exhibit stable price formation versus execution-fragile behavior?
- Can stocks be systematically classified based on combined volatility and liquidity characteristics?
- What implications do these microstructure patterns have for traders and risk management teams?

The focus of this analysis is **execution-aware market microstructure**, not price prediction.

---

## 2. Dataset Overview

The analysis is based on minute-level OHLCV data for **150 NSE-listed equities**, covering multiple years of regular trading activity.

### Dataset characteristics:
- **Universe size**: 150 equities
- **Granularity**: 1-minute bars
- **Features**: Open, High, Low, Close, Volume
- **Time span**: Multi-year (full regular trading sessions)
- **Total observations**: ~**54 million minute records**

This scale enables statistically meaningful **cross-sectional microstructure analysis**, rather than conclusions drawn from isolated stocks or short time windows.

Due to the size of the dataset, raw and intermediate files are excluded from the repository.  
All analytical outputs are fully reproducible using the provided SQL schemas, transformation scripts, and ingestion logic.
---

## 3. Methodology Overview

The analysis follows a structured pipeline designed to transform raw intraday data into interpretable microstructure insights.

The methodology consists of five stages:

1. **Data ingestion and validation**
2. **Liquidity characterization**
3. **Volatility characterization**
4. **Feature construction and normalization**
5. **Rule-based behavioral classification**

All large-scale computation is performed using **PostgreSQL**, ensuring scalability and reproducibility. 
Python is used only for data ingestion and preliminary exploration.

The analysis is intentionally descriptive rather than predictive, with emphasis on **execution risk and price formation quality**.

---

## 4. Liquidity Measurement: Dead-Fraction

### 4.1 Motivation

Liquidity is not uniformly distributed throughout the trading day. 
Even actively traded stocks can experience periods of low or absent trading activity, during which observed price movements may not reflect true market consensus.

To capture this behavior, liquidity is measured using **dead-fraction**, defined as the proportion of intraday minutes with zero traded volume.

This metric directly reflects **execution fragility**, rather than notional turnover or average volume.

### 4.2 Method

Minute-level data is partitioned into three intraday blocks:

- **Open**: early session dominated by price discovery
- **Midday**: typically lower participation period
- **Close**: period of institutional execution and position adjustment

For each stock and trading day, the following are computed:
- total minutes
- traded minutes
- zero-volume minutes
- dead-fraction = zero-volume minutes / total minutes

Block-level dead-fractions are averaged across the dataset to produce stable liquidity signatures for each stock.

### 4.3 Interpretation

Higher dead-fraction values indicate frequent liquidity collapse and elevated execution risk.
Stocks with low dead-fraction across all blocks exhibit robust price formation and are safer for passive or large-volume execution.

---

## 5. Volatility Measurement

### 5.1 Motivation

Daily return volatility alone fails to capture **intraday execution risk**.
Two stocks with similar daily returns may have very different intraday price paths and liquidity conditions.

This analysis therefore focuses on **intraday-derived volatility metrics**.

### 5.2 Method

From minute-level OHLC data, the following daily metrics are constructed:

- **Intraday range percentage**: relative high–low movement
- **Trend volatility**: variability of intraday directional returns
- **Tail-risk index**: frequency of extreme intraday price movements
- **Average trend**: mean intraday directional bias

These metrics are aggregated across time to characterize each stock’s typical volatility behavior.

### 5.3 Interpretation

Stocks with high intraday range and tail-risk exhibit unstable price formation.
Trend volatility distinguishes smoothly trending stocks from choppy, unpredictable ones.

---

## 6. Feature Construction and Normalization

Liquidity and volatility metrics are combined to form a unified **microstructure feature set**.

Each stock is represented by features capturing:
- magnitude of intraday price movement
- directional stability
- frequency of extreme events
- liquidity availability at different times of day

To ensure comparability across features, all variables are normalized using **min–max scaling** prior to classification.

---

## 7. Rule-Based Microstructure Classification

Rather than applying opaque clustering algorithms, stocks are classified using **transparent, rule-based thresholds**.

The classification rules are designed to reflect practical trading and execution considerations, combining:
- volatility magnitude
- trend stability
- liquidity collapse risk

Each stock is assigned to exactly one behavioral category, ensuring interpretability and defensibility.

The resulting clusters are:

- **Safe & Stable**
- **Choppy Random-Walk**
- **Volatile but Liquid**
- **Quiet but Illiquid**

---

## 8. Results and Interpretation

Applying the rule-based microstructure classification to the 150-stock universe yields the following distribution:

- **Choppy Random-Walk**: **88 stocks**
- **Safe & Stable**: **53 stocks**
- **Volatile but Liquid**: **7 stocks**
- **Quiet but Illiquid**: **2 stocks**

### Interpretation

The dominant regime in the Indian equity market is **choppy, directionally unstable behavior**, accounting for nearly **60% of the universe**.  
These stocks exhibit moderate liquidity and volatility but lack consistent trend structure.

A substantial subset (**~35%**) falls into the **Safe & Stable** category, representing execution-friendly instruments with reliable liquidity and controlled intraday movement.  
These stocks form the backbone for institutional execution strategies.

Only **7 stocks (~5%)** combine high volatility with strong liquidity, making them suitable for aggressive intraday or momentum-based trading strategies.

Finally, **2 stocks (~1%)** exhibit deceptively low volatility combined with persistent liquidity gaps.  
Despite calm price behavior, these instruments pose **significant execution risk** and function as liquidity traps.

---

## 9. Implications for Traders and Risk Teams

The results demonstrate that **volatility alone is insufficient** to assess execution risk.

Low-volatility stocks may still pose significant liquidity risk, while some highly volatile stocks remain tradeable due to consistent participation.

The classification framework can inform:
- intraday execution strategy selection
- liquidity-aware risk controls
- stock universe filtering for trading strategies
- identification of execution traps

From an execution perspective, approximately **40% of stocks exhibit non-trivial intraday liquidity risk** in at least one time-of-day block, underscoring the importance of liquidity-aware trading strategies beyond volatility-based screening.


---

## 10. Limitations and Extensions

The analysis relies on OHLCV data and does not incorporate order book depth or trade-level information.
As a result, bid–ask spreads and market impact are not directly modeled.

Future extensions could include:
- regime analysis across time periods
- event-driven liquidity shocks
- integration with order book data where available
