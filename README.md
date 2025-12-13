# Indian Stock Market Microstructure Analysis

This project analyzes intraday price formation and liquidity behavior across Indian equities using large-scale minute-level data.

## Overview
- **Universe**: 150 NSE-listed equities
- **Data scale**: ~54 million 1-minute OHLCV records
- **Focus**: Intraday liquidity, volatility, and execution risk
- **Approach**: SQL-first, rule-based microstructure analysis

The goal is to move beyond daily returns and quantify how liquidity availability and intraday volatility interact to shape execution risk.

## Key Components
- Large-scale data ingestion using Python
- PostgreSQL-based analytics for scalability
- Intraday liquidity measurement via dead-fraction
- Volatility and tail-risk characterization
- Rule-based classification of stocks into microstructure regimes

## Results Summary
Stocks are classified into four execution-relevant regimes:
- Safe & Stable
- Choppy Random-Walk
- Volatile but Liquid
- Quiet but Illiquid

The analysis highlights that volatility alone is insufficient to assess execution risk; liquidity structure plays a critical role.

## Repository Structure
Indian-Stock-Microstructure/
├── sql/ # SQL schemas and analytics logic
├── python/ # Data ingestion scripts
├── notebooks/ # Exploratory data analysis
├── report/ # Final analytical report
└── data/ # Data folders (ignored in Git)

## Tools
Python, Pandas, PostgreSQL, SQL

## Notes
Raw and processed datasets are excluded due to size constraints.  
All results can be reproduced using the scripts provided.
