---Create Schema
CREATE SCHEMA "MINER";
drop table "MINER"."PAGE_LINKS";
drop table "MINER"."FOR_SCORE";
drop table "MINER"."GRAPH";
---Create Type
CREATE TYPE "MINER"."GRAPH_TYPE" AS TABLE (src BIGINT, dest bigint, score DOUBLE);
CREATE TYPE "MINER"."COUNT_TYPE" AS TABLE (src BIGINT, count BIGINT);
CREATE TYPE "MINER"."SCORE_TYPE" AS TABLE (dest bigint, score DOUBLE);
---Create Table
--CREATE TABLE "MINER"."GRAPH" (src BIGINT, dest nvarchar(255), score DOUBLE);
--CREATE TABLE "MINER"."COUNT" (src nvarchar(255), count BIGINT);
--CREATE TABLE "MINER"."SCORE" (dest nvarchar(255), score DOUBLE);
CREATE TABLE "MINER"."PAGE_LINKS"(src bigint, dst bigint);

---import data in page_links
ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'system') set ('import_export', 'enable_csv_import_path_filter') = 'false' with reconfigure;
IMPORT FROM CSV FILE '/home/dke/seongpyo/pagerank/web-Stanford.txt' INTO "MINER"."PAGE_LINKS" WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY '\t';

--CREATE GRAPH TABLE
CREATE TABLE "MINER"."FOR_SCORE" AS (select dst as dest, (1/ count(dst)) as score from "MINER"."PAGE_LINKS" group by dst);
CREATE TABLE "MINER"."GRAPH" AS (select pl.src as src, pl.dst as dest, fs.score as score from "MINER"."PAGE_LINKS" as pl, "MINER"."FOR_SCORE" as fs where pl.dst = fs.dest);



select * from "MINER"."FOR_SCORE" order by score desc;
select * from "MINER"."GRAPH";
