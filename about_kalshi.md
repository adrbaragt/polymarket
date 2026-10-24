# Kalshi Platform Overview

Kalshi is a CFTC-regulated prediction market exchange where users trade binary
contracts on the outcome of real-world events. Prices are quoted in dollars
between `0.00` and `1.00` and correspond directly to the implied probability of
the event. A winning contract settles at `$1.00`, a losing contract at `$0.00`.

## Core Concepts

- **Series / Event / Market**: A series (e.g. `KXUKBUDGETTAX`) groups related
  events. An event (e.g. `KXUKBUDGETTAX-26OCT29`) is a specific occurrence. Each
  event contains one or more binary markets, identified by a ticker such as
  `KXUKBUDGETTAX-26OCT29-YES`.
- **Yes / No contracts**: Every market has a YES and a NO side. Buying NO at
  price `p` is economically equivalent to selling YES at `1 - p`.
- **Order book**: Resting limit orders on both sides. Depth is expressed as
  `[price, size]` pairs, where `size` is a number of contracts.
- **Open interest**: Number of outstanding contracts. Because each contract has
  a `$1` notional value, open interest multiplied by `notional_value_dollars`
  gives the capital currently at stake in USD.

## Public Trade API

Base URL: `https://external-api.kalshi.com/trade-api/v2`
(`https://api.elections.kalshi.com/trade-api/v2` is an equivalent host.)

Public market data requires no authentication.

### Endpoints used by `scan_kalshi.py`

| Endpoint | Purpose |
|---|---|
| `GET /markets?min_close_ts=&max_close_ts=&limit=1000&cursor=&mve_filter=exclude` | Paginated market discovery. `cursor` is an opaque token; an empty/missing cursor marks the last page. |
| `GET /events/{event_ticker}` | Event metadata: `title` (used as `event_label`), `series_ticker`, `category`. |
| `GET /series/{series_ticker}/markets/{ticker}/candlesticks?start_ts=&end_ts=&period_interval=60` | Hourly price history used for the stability metric. |
| `GET /markets/{ticker}/orderbook` | Order-book depth used for the liquidity metric. |

### Market fields of interest

`ticker`, `event_ticker`, `title`, `yes_sub_title`, `close_time`,
`expiration_time`, `status`, `last_price_dollars`, `yes_bid_dollars`,
`yes_ask_dollars`, `no_bid_dollars`, `no_ask_dollars`, `volume_fp`,
`open_interest_fp`, `notional_value_dollars`, `result`.

Prices are decimal strings (e.g. `"0.9200"`). Impure/count fields such as
`volume_fp` and `open_interest_fp` are also decimal strings.

### Candlestick shape

```json
{
  "end_period_ts": 1792832400,
  "open_interest_fp": "24.08",
  "volume_fp": "0.00",
  "price": {"previous_dollars": "0.8200"},
  "yes_ask": {"open_dollars": "0.9200", "close_dollars": "0.9200"},
  "yes_bid": {"open_dollars": "0.8400", "close_dollars": "0.8400"}
}
```

`price` may contain only `previous_dollars` when no trade occurred during the
bucket. In that case the scanner falls back to the midpoint of the `yes_bid` and
`yes_ask` closes.

## Metrics in `scan_kalshi.py`

- **Probability**: the current YES price is the midpoint of the best bid and
  ask (falling back to the last traded price). The stored probability is the
  higher of `p` and `1 - p`, expressed as a percentage.
- **Outcome label**: `Yes` when the YES price is at least `0.50`, otherwise
  `No`.
- **Stability**: the same 1 - NRMSD metric described in `STABILITY_METRIC.md`.
  For a `No` outcome the YES probabilities are inverted so that the chosen
  outcome's probability converges to `1.0` at expiry.
- **Liquidity**: order-book depth in USD, computed as
  `sum(price * size)` over every resting level on both sides. If the order book
  cannot be fetched, open interest in USD is used instead.

## Scan filters

The scanner reuses the Polymarket parameters: look-ahead of 5 days, exclusion of
markets closing within 60 minutes, and a probability band of 80.0 % to 99.1 %.

Kalshi publishes an extremely large number of auto-generated markets (sports
props, player thresholds, ...); a single 5-day scan can exceed 120,000 open
markets. Most of them have zero open interest. `MIN_OPEN_INTEREST_USD`
(default `10000`) therefore acts as a data-quality floor: a market must have at
least that much open interest in USD before it is stored. This keeps a run
bounded while remaining far more permissive than the ~$100k+ liquidity markets
the Polymarket scan typically selects.

## Database schema

### `PMKT.MARKET_KL`

| Column | Type | Meaning |
|---|---|---|
| `market_id` | `VARCHAR2(200)` PK | Kalshi market ticker |
| `market_name` | `VARCHAR2(4000)` | Market title |
| `close_date` | `TIMESTAMP` | Trading close time (UTC) |
| `event_label` | `VARCHAR2(1000)` | Event title |
| `outcome_label` | `VARCHAR2(100)` | `Yes` or `No` |
| `category` | `VARCHAR2(200)` | Kalshi event category |

### `PMKT.MARKET_KL_OPTIES`

| Column | Type | Meaning |
|---|---|---|
| `optie_id` | `NUMBER` identity PK | Observation id |
| `market_id` | `VARCHAR2(200)` FK | References `MARKET_KL` |
| `prob_pct` | `NUMBER(5,2)` | Probability of the chosen outcome (%) |
| `extraction_date` | `TIMESTAMP` | Observation timestamp (UTC) |
| `stability` | `NUMBER` | Stability score in `[0, 1]` |
| `liquidity` | `NUMBER` | Liquidity in USD |

## Incremental behaviour

Like the Polymarket scanner, the Kalshi scanner never truncates its tables. New
markets are inserted into `MARKET_KL` (a duplicate ticker is ignored), while
every run appends a fresh observation row per qualifying market to
`MARKET_KL_OPTIES`.

## Resources

- Documentation: <https://docs.kalshi.com>
- API reference: <https://docs.kalshi.com/api-reference>
- Historical data: <https://docs.kalshi.com/getting_started/historical_data>
