# Polymarket Platform Overview

Polymarket is a decentralized prediction market platform built on blockchain technology (primarily Polygon) that allows users to trade on the outcomes of various events, ranging from politics and sports to cryptocurrency and entertainment. Users can buy and sell shares representing the probability of an event occurring, with prices reflecting market sentiment.

## Core Concepts

- **Events and Markets**: An event is a real-world occurrence with multiple possible outcomes. Each outcome corresponds to a market where users can trade tokens representing that outcome.
- **Tokens**: Each market outcome is represented by a token (ERC-20) that can be bought and sold. The price of a token ranges from $0.00 to $1.00, reflecting the perceived probability of that outcome.
- **Order Book**: Polymarket uses a Central Limit Order Book (CLOB) for trading, where users can place limit orders and market orders.
- **Positions**: Holding tokens represents a position in a market. The value of a position changes as token prices fluctuate.
- **Resolution**: When an event concludes, the market is resolved according to a predetermined source (e.g., official statistics, reputable reporters). Winning tokens are redeemed for $1 each; losing tokens become worthless.

## API Overview

Polymarket provides several REST APIs and WebSocket services for programmatic access:

### 1. Gamma API (`https://gamma-api.polymarket.com`)
- **Purpose**: Discover events and markets, retrieve metadata.
- **Endpoints**:
  - List markets (active, closed, etc.)
  - Get market by ID or slug
  - Get events
  - Get market prices, volume, liquidity
- **Use Case**: Browsing available markets, obtaining market information for display or analysis.

### 2. CLOB API (`https://clob.polymarket.com`)
- **Purpose**: Read live order books, place and manage orders.
- **Endpoints**:
  - Get order book for a market
  - Create, cancel, and query orders
  - Get user positions and balances
- **Use Case**: Building trading bots, executing trades, managing portfolios.

### 3. Data API v2 (`https://data-api.polymarket.com/v2`)
- **Purpose**: Access historical and analytical data (trader activity, market statistics, etc.).
- **Features**: Cursor pagination, shared response envelope.
- **Endpoints**:
  - Trader performance, volumes, fees
  - Market historical prices, volatility
  - Event and market snapshots
- **Use Case**: Analytics, research, building dashboards.

### 4. Relayer API (`https://relayer-v2.polymarket.com`)
- **Purpose**: Submit blockchain transactions on behalf of users (gas relayer) without requiring users to hold POL (Polygon's gas token) for simple actions.
- **Endpoints**:
  - Create and sign orders off-chain, then submit via relayer
  - Withdrawals, deposits
- **Use Case**: Improving user experience by abstracting gas payments.

### 5. WebSocket APIs
- Provides real-time streams for:
  - Market data (price updates, order book changes)
  - Account events (order fills, balance changes)
  - Sports scores (for sports markets)
  - RFQ (Request for Quote) for large trades
- **Endpoints** (examples):
  - `wss://ws-live-data.polymarket.com` (market data)
  - `wss://ws-auth.polymarket.com` (private account streams)
- **Use Case**: Live trading interfaces, alerts, real-time analytics.

## How Trading Works

1. **Funding**: Users deposit USDC (or other supported stablecoins) into their Polymarket wallet (on Polygon).
2. **Placing Orders**: Via the CLOB API (or SDK), users can place limit orders (specify price and amount) or market orders (execute at best available price).
3. **Order Matching**: The CLOB matches buy and sell orders; trades are executed on-chain (via the relayer or directly).
4. **Position Tracking**: After a trade, the user's token balances update, reflecting their position.
5. **Resolution**: When the event outcome is known, the market is resolved. Winning tokens are automatically redeemed for $1 each (paid in USDC). Losing tokens become worthless.
6. **Withdrawal**: Users can withdraw their USDC (or other tokens) back to their external wallet.

## Fees and Rebates

- **Trading Fees**: A small percentage fee is charged on the notional volume of trades (varies by market type; some markets may be fee-free).
- **Maker Rebates**: Users who provide liquidity (place limit orders that sit on the book) may receive rebates, reducing effective fees.
- **Details**: See the Polymarket documentation for the latest fee schedule.

## SDKs and Libraries

Polymarket offers official client libraries to simplify integration:
- **TypeScript/JavaScript**: `@polymarket/client`
- **Python**: `polymarket-py` (community-maintained, but widely used)
These SDKs wrap the Gamma, CLOB, and Data APIs, handling authentication, request signing, and WebSocket connections.

## Getting Started (Quickstart)

1. **Explore Public Data**: Use the Gamma API to list markets without authentication.
   ```bash
   curl "https://gamma-api.polymarket.com/markets?closed=false"
   ```
2. **Authenticate**: For trading, you need an API key (key ID and secret) obtained from the Polymarket website after creating an account.
3. **Place an Order**: Using the SDK or directly via the CLOB API (requires signing requests with your secret key).
4. **Track Positions**: Use the Data API or CLOB API to query your balances and open orders.
5. **Resolve and Withdraw**: After market resolution, claim winnings and withdraw funds.

## Resources

- **Documentation**: https://docs.polymarket.com
- **API Reference**: https://docs.polymarket.com/api-reference/
- **GitHub (SDKs)**: https://github.com/Polymarket (official repositories)
- **Changelog**: https://docs.polymarket.com/changelog/predictions
- **Community**: Discord, Twitter (@Polymarket)

## Conclusion

Polymarket combines the mechanics of prediction markets with blockchain infrastructure to offer a global, permissionless trading platform. Its suite of APIs enables developers to build trading bots, analytics tools, and integrations that interact seamlessly with the market's order book and data streams.
## Stability Metric for Odds Evolution

To assess how smoothly a market’s probability drifts toward its assumed eventual outcome (100 % at expiry), we propose a **Stability Metric** based on the deviation of observed probabilities from an ideal linear path. 

The metric is detailed in the companion file [`STABILITY_METRIC.md`](STABILITY_METRIC.md). In short, it computes the normalized root‑mean‑square deviation (NRMSD) between the actual probability time‑series and a reference line that increases linearly from the first observed probability to 100 % at the market’s `endDate`. A stability score of `S = 1 – NRMSD` ranges from 0 (highly erratic) to 1 (perfectly smooth drift).

This measure can be calculated from historical odds obtained via the Data API or periodic snapshots and used to rank markets by predictability of their price movement.

## Related Pipelines

- `scan_polymarket.py` populates `PMKT.MARKET_PM` and `PMKT.MARKET_PM_OPTIES`.
- `scan_kalshi.py` mirrors the same logic for Kalshi and populates
  `PMKT.MARKET_KL` and `PMKT.MARKET_KL_OPTIES`. See `about_kalshi.md` for the
  Kalshi API notes and the table definitions.

