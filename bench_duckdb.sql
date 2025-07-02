
--  Database:\home\hetoku\data\work\nyse-taq-analysis\bench_duckdb.sql

-- Press F7 on the comment line below to use AI to generate queries
-- Generate 5 example queries. Include a simple select, a count and 3 more advanced queries.
CREATE OR REPLACE TABLE trade AS SELECT * FROM read_csv('/home/hetoku/data/work/nyse-taq-analysis/EQY_US_ALL_TRADE_20250402', delim = '|', header = true);
ALTER TABLE trade ADD COLUMN ttime TIME;
UPDATE trade SET ttime=TRY_CAST(SUBSTRING("Time", 1, 2)||':'||SUBSTRING("Time", 3, 2)||':'||SUBSTRING("Time", 5, 2)||'.'||SUBSTRING("Time", 7) AS TIME);

SELECT COUNT(*) FROM trade;

SELECT Symbol,COUNT(*) AS numTrade,max("Trade Price") AS maxPrice FROM trade GROUP BY Symbol ORDER BY Symbol;

CREATE OR REPLACE MACRO xbarTime(n,x) AS n*(((date_part('hour', x::Time)*60) + date_part('minute', x::Time))//n);

SELECT MIN("ttime") AS earliest, SUM("Trade Volume") as total_trade_volume FROM trade WHERE "Symbol" = 'AAPL' GROUP BY xbarTime(5, "ttime") ORDER BY earliest;

SELECT *,sum(total_trade_volume) over (ORDER BY earliest) AS sums FROM (SELECT MIN("ttime") AS earliest, SUM("Trade Volume") as total_trade_volume FROM trade WHERE "Symbol" = 'AAPL' GROUP BY xbarTime(5, "ttime") ORDER BY earliest);

select Symbol, wavg("Trade Volume", "Trade Price") AS wavg FROM trade GROUP BY ALL ORDER BY Symbol;

select min("ttime") AS ttime, last("Trade Price") as LastPrice, wavg("Trade Volume", "Trade Price") AS WeightedPrice FROM trade WHERE Symbol='IBM' GROUP BY xbarTime(15,ttime) ORDER BY ttime;


