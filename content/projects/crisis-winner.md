---
title: crisis-winner
layout: project
dataKey: crisis-winner
---

A comprehensive framework for backtesting trading strategies across a consistent time window (2021-01-01 to 2025-07-05) using Python Backtrader and Go for concurrent data downloading.

## Features

- **Standardized Time Window**: All strategies tested across 2021-01-01 to 2025-07-05
- **Concurrent Data Downloads**: Go-based downloader with concurrency and existence checking
- **Consistent Database Schema**: SQLite database with standardized tables
- **Strategy Management**: Allowed tickers per strategy with date ranges
- **Yearly Breakdown**: Easy viewing of results broken down by year
- **Modular Design**: Easy to extend with new strategies

## Project Structure

```
trading/
├── config.json                 # Centralized configuration
├── data_downloader.go          # Go-based concurrent data downloader
├── go.mod                      # Go module definition
├── backtest_framework.py       # Core Python backtest framework
├── example_strategy.py         # Example strategy implementation
├── setup_database.py           # Database initialization script
├── requirements.txt            # Python dependencies
├── sql/                        # SQL schema files
│   ├── create_stock_historical_data_table.sql
│   ├── create_allowed_tickers_table.sql
│   └── create_strategy_history_table.sql
└── README.md                   # This file
```

## Quick Start

### 1. Setup Environment

```bash
# Install Python dependencies
pip3 install -r requirements.txt

# Initialize Go module (if not already done)
go mod tidy
```

### 2. Initialize Database

```bash
python3 setup_database.py
```

### 3. Download Historical Data

```bash
go run data_downloader.go
```

### 4. Run Example Strategy

```bash
python3 example_strategy.py
```

## Configuration

The `config.json` file contains all standardized settings:

```json
{
  "database": {
    "main_db": "backtest_strategies.db",
    "connection_pool_size": 25,
    "wal_mode": true
  },
  "data_download": {
    "start_date": "2021-01-01",
    "end_date": "2025-07-05",
    "concurrency_limit": 10,
    "retry_attempts": 3
  },
  "backtesting": {
    "initial_cash": 100000,
    "commission": 0.001,
    "date_format": "YYYY-MM-DD"
  }
}
```

## Database Schema

### stock_historical_data
- Stores OHLCV data in YYYY-MM-DD format
- Indexed by symbol and date for fast retrieval

### allowed_tickers
- Defines which tickers each strategy can trade
- Supports date ranges and active/inactive states

### strategy_history
- Records all trades with P&L calculations
- Includes yearly breakdown support
- Tracks portfolio value and position sizes

## Creating New Strategies

1. **Create a new strategy file** following `example_strategy.py` pattern
2. **Configure strategy-specific settings** at the top of the file
3. **Inherit from `BaseStrategy`** class
4. **Implement strategy logic** in the `next()` method
5. **Setup allowed tickers** in the database

Example strategy structure:

```python
#!/usr/bin/env python3
from backtest_framework import BacktestFramework, BaseStrategy

# Strategy-specific configuration
STRATEGY_NAME = "my_strategy"
STRATEGY_SETTINGS = {
    'commission': 0.001,
    'starting_cash': 100000,
    'my_parameter': 0.5
}

class MyStrategy(BaseStrategy):
    params = (
        ('my_parameter', 0.5),
    )
    
    def next(self):
        # Your strategy logic here
        pass

if __name__ == "__main__":
    framework = BacktestFramework()
    results = framework.run_backtest(
        MyStrategy,
        STRATEGY_NAME,
        **STRATEGY_SETTINGS
    )
```

## Data Download Features

The Go data downloader includes:

- **Concurrency Control**: Configurable concurrent downloads
- **Existence Checking**: Skips already downloaded data
- **Retry Logic**: Automatic retries with exponential backoff
- **Rate Limiting**: Prevents API rate limit violations
- **Progress Tracking**: Detailed logging of download progress

## Data Quality Management

The framework includes comprehensive data quality checking and automatic gap filling:

### Check Data Completeness
```bash
# Run full data quality check
python3 data_quality_checker.py

# View missing data summary
python3 data_quality_checker.py summary
```

### Automatic Gap Filling
```bash
# Download missing data identified by quality check
go run missing_data_downloader.go
```

The data quality checker:
- Validates complete history from 2020-01-01 to 2025-07-05
- Accounts for weekends and major holidays
- Creates missing_data table with prioritized download list
- Provides detailed completeness reports by symbol

### Missing Data Table Schema
```sql
missing_data (
    symbol TEXT,           -- Stock symbol
    missing_date TEXT,     -- YYYY-MM-DD of missing date
    date_type TEXT,        -- 'single' or 'range'
    priority INTEGER,      -- 1=high, 2=medium, 3=low
    status TEXT,          -- 'pending', 'downloaded', 'failed'
    error_message TEXT    -- Details if download failed
)
```

## Yearly Breakdown

Get yearly performance breakdown for any strategy:

```python
framework = BacktestFramework()
yearly_results = framework.get_yearly_breakdown("strategy_name")

for year_data in yearly_results:
    print(f"{year_data['trade_year']}: {year_data['trades_count']} trades, "
          f"P&L: ${year_data['total_pnl']:.2f}")
```

## Common Commands

```bash
# Download data
go run data_downloader.go

# Check data quality and identify missing data
python3 data_quality_checker.py

# Download missing data
go run missing_data_downloader.go

# Check missing data summary
python3 data_quality_checker.py summary

# Run specific strategy
python3 your_strategy.py

# Setup database
python3 setup_database.py

# Check for duplicates
python3 check_duplicates.py

# Check data completeness
sqlite3 backtest_strategies.db "SELECT symbol, COUNT(*) FROM stock_historical_data GROUP BY symbol;"
```

## Best Practices

1. **Always use the standardized time window** (2021-01-01 to 2025-07-05)
2. **Configure allowed tickers** in the database before running strategies
3. **Use YYYY-MM-DD date format** consistently
4. **Test strategies with small position sizes** first
5. **Monitor database size** when adding many tickers

## Troubleshooting

- **No data loaded**: Check that tickers are in `allowed_tickers` table
- **Database locked**: Ensure no other processes are accessing the database
- **API rate limits**: Increase `rate_limit_delay_ms` in config.json
- **Memory issues**: Reduce `concurrency_limit` for data downloads

## Contributing

1. Follow the existing code structure
2. Add new strategies as separate files
3. Update documentation for new features
4. Test with the standardized time window

## License

MIT License - feel free to use and modify as needed.
