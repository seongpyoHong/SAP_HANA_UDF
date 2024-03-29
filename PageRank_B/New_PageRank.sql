
DO
BEGIN
DECLARE Alpha double;  --Damping Factor
DECLARE Node_Num integer;  -- Number of Nodes 
DECLARE Iteration integer;  -- Number of Max Iteration
DECLARE Diff double;
--Intialize variable
Iteration := 0;
Alpha := 0.85;
SELECT COUNT(*) INTO Node_Num FROM Node;
N_PageRank = select * from PageRank;

WHILE :Iteration < 50 DO
--Calculate PageRank
TmpRank = SELECT Edge.dst as id, SUM(:Alpha * :N_PageRank.rank / OutDegree.degree) + (1 - :Alpha) / :Node_Num as rank
    FROM :N_PageRank
    INNER JOIN Edge ON :N_PageRank.id = Edge.src
    INNER JOIN OutDegree ON :N_PageRank.id = OutDegree.id
    GROUP BY Edge.dst;
--Calculate diff
select sum(abs(new.rank - old.rank)) into Diff from :TmpRank as new, :N_PageRank as old where new.id = old.id;
--Update Origin PageRank Table
N_PageRank = select * from :TmpRank;
Iteration = :Iteration +1;
select :Iteration from dummy;
IF :Diff <0.0001 THEN
	BREAK;
END IF;
--For checking the Diff
--select :Diff from dummy;
END WHILE;

select * from :N_PageRank order by rank desc;
end;