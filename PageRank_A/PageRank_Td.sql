drop function "MINER"."PAGE_RANK_TD";

create function "MINER"."PAGE_RANK_TD"()
returns table (dest bigint, score DOUBLE)
as
begin

declare iteration integer;
declare score table (dest bigint, score DOUBLE);
graph = select * from "MINER"."GRAPH";
VT = select src,score from :graph;
IT = select src,dest from :graph;
dest_count = select src,count(dest) as count from :IT group by src;

iteration := 1;
--score : destination이름이 같은 노드의 개수
--for_score = select pl_title as dest, (1/ count(pl_from)) as score from "MINER"."pagelinks" group by pl_title;
--graph = select pl.pl_from as src, pl.pl_title as dest, fs.score as score from "MINER"."pagelinks" as pl, :for_score as fs where pl.dest = fs.dest;

while :iteration<=5 DO
score = (select * from :score) union (select it.dest,sum(vt.score / cnt.count) as score 
from :VT as vt,:IT as it,:dest_count as cnt
where it.src = cnt.src and vt.src = it.src
group by it.dest);

VT = select vt.src, s.score from :VT as vt, :score as s
where vt.src = s.dest;
iteration = :iteration +1;
end while;
return
select * from :score;

end;
select * from "MINER"."PAGE_RANK_TD"() order by score desc;