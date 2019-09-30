create function "MINER"."PAGE_RANK"()
returns table "MINER"."SCORE_TYPE"
as
begin
declare dist float;
dist := 1.0;
--score : destination이름이 같은 노드의 개수
--for_score = select pl_title as dest, (1/ count(pl_from)) as score from "MINER"."pagelinks" group by pl_title;
--graph = select pl.pl_from as src, pl.pl_title as dest, fs.score as score from "MINER"."pagelinks" as pl, :for_score as fs where pl.dest = fs.dest;
prev_graph = select * from "MINER"."GRAPH";
dest_count = select src,count(dest) as count from :prev_graph group by src;

while :dist<0.85 DO
score = (select * from :score) union (select n.dest as dest, sum(n.score/c.count) as score from :prev_graph as n, :dest_count as c where n.src = c.src group by n.dest);
prev_graph = (select * from :prev_graph) union (select m.src, m.dest, s.score from :prev_graph as m, :score as s where m.src = s.dest);
select abs(sum(prev_graph.score-graph.score)) into dist from :prev_graph as prev, :graph as curr where prev.dest = curr.dest;
end while;

return
select * from :score;

end;