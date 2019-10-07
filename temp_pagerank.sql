do
begin
declare dist double;
declare iteration integer;
declare score table (dest bigint, score DOUBLE);
graph = select * from "MINER"."GRAPH";
prev_graph = select * from :graph;
prev_score = select dest,score from :graph;
dest_count = select src,count(dest) as count from :prev_graph group by src;
dist := 0.000001;
iteration := 0;
while :iteration < 7 DO
score = select n.dest as dest, sum(n.score/c.count) as score 
from :prev_graph as n, :dest_count as c where n.src = c.src group by n.dest;

new_graph =select m.src, m.dest, s.score 
from :prev_graph as m, :score as s where m.src = s.dest;

select max(prev.score - cur.score) into dist from :prev_score as prev, :score as cur where prev.dest = cur.dest;
prev_score = select * from :score;
prev_graph = select * from :new_graph;
iteration = :iteration + 1;
select * from :score;
end while;
select :dist from dummy;
select * from :score order by score desc;
end;