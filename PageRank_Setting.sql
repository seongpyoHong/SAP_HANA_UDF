---Create Schema
CREATE SCHEMA "MINER";
---Create Type
CREATE TYPE "MINER"."GRAPH_TYPE" AS TABLE (src BIGINT, dest nvarchar(255), score DOUBLE);
CREATE TYPE "MINER"."COUNT_TYPE" AS TABLE (src BIGINT, count BIGINT);
CREATE TYPE "MINER"."SCORE_TYPE" AS TABLE (dest nvarchar(255), score DOUBLE);
---Create Table
--CREATE TABLE "MINER"."GRAPH" (src BIGINT, dest nvarchar(255), score DOUBLE);
--CREATE TABLE "MINER"."COUNT" (src nvarchar(255), count BIGINT);
--CREATE TABLE "MINER"."SCORE" (dest nvarchar(255), score DOUBLE);
CREATE TABLE "MINER"."pagelinks"(pl_from BIGINT, pl_namespace BIGINT, pl_title nvarchar(255),pl_from_namespace BIGINT);

--CREATE GRAPH TABLE
CREATE TABLE "MINER"."FOR_SCORE" AS (select pl_title as dest, (1/ count(pl_from)) as score from "MINER"."pagelinks" group by pl_title);
CREATE TABLE "MINER"."GRAPH" AS (select pl.pl_from as src, pl.pl_title as dest, fs.score as score from "MINER"."pagelinks" as pl, "MINER"."FOR_SCORE" as fs where pl.dest = fs.dest);


