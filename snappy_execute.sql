DROP TABLE IF EXISTS ORDERS;

CREATE EXTERNAL TABLE ORDERS (O_ORDERKEY BIGINT, O_CUSTKEY BIGINT NOT NULL, O_ORDERSTATUS CHAR(1), O_TOTALPRICE DECIMAL, O_ORDERDATE DATE, O_ORDERPRIORITY CHAR(15), O_CLERK CHAR(15), O_SHIPPRIORITY INTEGER, O_COMMENT VARCHAR(79)) USING csv OPTIONS(path 's3a://AKIAJJZJUB5TZZNPHWHQ:MaBNHGS7rFRbt08kkgW7YcwLwHM65+iYAvnmjjML@uwdb/tpch/skewed/10GB/order.tbl', delimiter '|');

DROP TABLE IF EXISTS SUPPLIER;

CREATE EXTERNAL TABLE SUPPLIER (S_SUPPKEY BIGINT, S_NAME CHAR(25), S_ADDRESS VARCHAR(40), S_NATIONKEY BIGINT NOT NULL, S_PHONE CHAR(15), S_ACCTBAL DECIMAL, S_COMMENT VARCHAR(101)) USING csv OPTIONS(path 's3a://AKIAJJZJUB5TZZNPHWHQ:MaBNHGS7rFRbt08kkgW7YcwLwHM65+iYAvnmjjML@uwdb/tpch/skewed/10GB/supplier.tbl', delimiter '|');

DROP TABLE IF EXISTS LINEITEM;

CREATE EXTERNAL TABLE LINEITEM (L_ORDERKEY INTEGER, L_PARTKEY INTEGER, L_SUPPKEY INTEGER, L_LINENUMBER INTEGER, L_QUANTITY DECIMAL, L_EXTENDEDPRICE DECIMAL, L_DISCOUNT DECIMAL, L_TAX DECIMAL, L_RETURNFLAG CHAR(1), L_LINESTATUS CHAR(1), L_SHIPDATE DATE, L_COMMITDATE DATE, L_RECEIPTDATE DATE, L_SHIPINSTRUCT  CHAR(25), L_SHIPMODE CHAR(10), L_COMMENT VARCHAR(44)) USING csv OPTIONS(path 's3a://AKIAJJZJUB5TZZNPHWHQ:MaBNHGS7rFRbt08kkgW7YcwLwHM65+iYAvnmjjML@uwdb/tpch/skewed/10GB/lineitem.tbl', delimiter '|');

DROP TABLE IF EXISTS ORDERS_oorderdate_sample;
CREATE SAMPLE TABLE ORDERS_oorderdate_sample ON ORDERS OPTIONS (qcs 'month(o_orderdate)', fraction '0.01') AS (SELECT * FROM ORDERS);

DROP TABLE IF EXISTS LINEITEM_lreceiptdate_sample;
CREATE SAMPLE TABLE LINEITEM_lreceiptdate_sample ON LINEITEM OPTIONS (qcs 'month(l_receiptdate)', fraction '0.01') AS (SELECT * FROM LINEITEM);

DROP TABLE IF EXISTS LINEITEM_llinestatus_sample;
CREATE SAMPLE TABLE LINEITEM_llinestatus_sample ON LINEITEM OPTIONS (qcs 'month(l_linestatus)', fraction '0.01') AS (SELECT * FROM LINEITEM);

DROP TABLE IF EXISTS LINEITEM_lreturnflag_sample;
CREATE SAMPLE TABLE LINEITEM_lreturnflag_sample ON LINEITEM OPTIONS (qcs 'month(l_returnflag)', fraction '0.01') AS (SELECT * FROM LINEITEM);

-- 1
SELECT COUNT (DISTINCT L_PARTKEY) FROM LINEITEM WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT COUNT (DISTINCT L_PARTKEY) FROM LINEITEM;

-- 2
SELECT month(L_RECEIPTDATE), COUNT(DISTINCT L_PARTKEY) FROM LINEITEM GROUP BY month(L_RECEIPTDATE) ORDER BY month(L_RECEIPTDATE) WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT month(L_RECEIPTDATE), COUNT(DISTINCT L_PARTKEY) FROM LINEITEM GROUP BY month(L_RECEIPTDATE) ORDER BY month(L_RECEIPTDATE);

-- 3
SELECT month(O_ORDERDATE) AS MONTH, COUNT(DISTINCT L_PARTKEY) FROM LINEITEM, ORDERS WHERE L_ORDERKEY = O_ORDERKEY GROUP BY month(O_ORDERDATE) ORDER BY month(O_ORDERDATE) WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT month(O_ORDERDATE) AS MONTH, COUNT(DISTINCT L_PARTKEY) FROM LINEITEM, ORDERS WHERE L_ORDERKEY = O_ORDERKEY GROUP BY month(O_ORDERDATE) ORDER BY month(O_ORDERDATE);

-- 4
SELECT NTILE (2) OVER (ORDER BY L_EXTENDEDPRICE) FROM LINEITEM WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT MEDIAN(L_EXTENDEDPRICE) FROM LINEITEM;

-- 5
SELECT month(L_RECEIPTDATE) AS MONTH, PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY L_EXTENDEDPRICE) FROM LINEITEM GROUP BY month(L_RECEIPTDATE) ORDER BY month(L_RECEIPTDATE) WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT month(L_RECEIPTDATE) AS MONTH, MEDIAN(L_EXTENDEDPRICE) FROM LINEITEM GROUP BY month(L_RECEIPTDATE) ORDER BY month(L_RECEIPTDATE);

-- 6
SELECT month(O_ORDERDATE) AS MONTH, PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY L_EXTENDEDPRICE) FROM LINEITEM, ORDERS WHERE L_ORDERKEY = O_ORDERKEY GROUP BY month(O_ORDERDATE) ORDER BY month(O_ORDERDATE) WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT month(O_ORDERDATE) AS MONTH, MEDIAN(L_EXTENDEDPRICE) FROM LINEITEM, ORDERS WHERE L_ORDERKEY = O_ORDERKEY GROUP BY month(O_ORDERDATE) ORDER BY month(O_ORDERDATE);

-- 7
SELECT COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_COST, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_COST, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM;

-- 8
SELECT COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_COST, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM  WHERE month(L_RECEIPTDATE) = 8 WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_COST, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM  WHERE month(L_RECEIPTDATE) = 8;

-- 9
SELECT month(L_RECEIPTDATE) AS MONTH, COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_QTY, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM  GROUP BY month(L_RECEIPTDATE) ORDER BY month(L_RECEIPTDATE) WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT month(L_RECEIPTDATE) AS MONTH, COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_QTY, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM  GROUP BY month(L_RECEIPTDATE) ORDER BY month(L_RECEIPTDATE);

-- 10
SELECT S_NATIONKEY AS NATION, COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_QTY, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM , SUPPLIER WHERE L_SUPPKEY = S_SUPPKEY GROUP BY S_NATIONKEY ORDER BY S_NATIONKEY WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT S_NATIONKEY AS NATION, COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_QTY, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM , SUPPLIER WHERE L_SUPPKEY = S_SUPPKEY GROUP BY S_NATIONKEY ORDER BY S_NATIONKEY;

-- 11
SELECT COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_QTY, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM , ORDERS WHERE L_ORDERKEY = O_ORDERKEY AND O_ORDERPRIORITY = '1-URGENT' WITH ERROR 0.1 BEHAVIOR 'do_nothing';

SELECT COUNT(*) AS NUM_ITEMS, SUM(L_QUANTITY) AS TOT_QTY, AVG(L_QUANTITY) AS AVG_QTY FROM LINEITEM , ORDERS WHERE L_ORDERKEY = O_ORDERKEY AND O_ORDERPRIORITY = '1-URGENT';
