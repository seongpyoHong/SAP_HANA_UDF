drop table "MINER"."GRAPH";

CREATE TABLE "MINER"."GRAPH" AS (select pl.src as src, pl.dst as dest,
 (1.0/(select count(*) from "MINER"."PAGE_LINKS")) as score from "MINER"."PAGE_LINKS" as pl);

drop function "MINER"."PAGE_RANK_TD";

create function "MINER"."PAGE_RANK_TD"()
returns table (dest bigint, score DOUBLE)
as
begin
declare dist double;
declare iteration integer;
declare score table (dest bigint, score DOUBLE);
graph = select * from "MINER"."GRAPH";
new_graph = select * from "MINER"."GRAPH";
dest_count = select src,count(dest) as count from :new_graph group by src;
iteration := 1;
--prev_score = select dest, score from "MINER"."GRAPH";
while :iteration<10 DO
score = (select * from :score) union (select n.dest as dest, sum(n.score/c.count) as score 
from :new_graph as n, :dest_count as c where n.src = c.src group by n.dest);

new_graph = (select * from :new_graph) union (select m.src, m.dest, s.score 
from :new_graph as m, :score as s where m.src = s.dest);
iteration = :iteration +1;
--prev_score = select * from :score;
--select max(prev.score - cur.score) into dist from :prev_score as prev, :score as cur where prev.dest = cur.dest;
end while;
return
select * from :score;
end;
select * from "MINER"."PAGE_RANK_TD"() order by score desc;