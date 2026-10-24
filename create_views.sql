-- Convenience views joining each market's static row with its observations.
--
-- Grain: one row per market per observation (extraction_date). Markets without
-- any observations still appear once, with NULL observation columns.
--
-- Run with:  python3 create_views.py   (or execute this file in SQL*Plus)

CREATE OR REPLACE VIEW PMKT.V_KL_MARKETS AS
SELECT
    k.market_id,
    k.market_name,
    k.close_date,
    k.event_label,
    k.outcome_label,
    k.category,
    o.optie_id,
    o.prob_pct,
    o.extraction_date,
    o.stability,
    o.liquidity
FROM PMKT.MARKET_KL k
LEFT JOIN PMKT.MARKET_KL_OPTIES o ON o.market_id = k.market_id;

CREATE OR REPLACE VIEW PMKT.V_PM_MARKETS AS
SELECT
    m.market_id,
    m.market_name,
    m.close_date,
    m.event_label,
    m.outcome_label,
    m.category_id,
    c.name AS category,
    p.name AS parent_category,
    o.optie_id,
    o.prob_pct,
    o.extraction_date,
    o.stability,
    o.liquidity
FROM PMKT.MARKET_PM m
LEFT JOIN PMKT.MARKET_PM_OPTIES o ON o.market_id = m.market_id
LEFT JOIN PMKT.MARKET_CATEGORY c ON c.category_id = m.category_id
LEFT JOIN PMKT.MARKET_CATEGORY p ON p.category_id = c.parent_id;
