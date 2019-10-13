DO
BEGIN
DECLARE Alpha double;  --Damping Factor
DECLARE Node_Num integer;  -- Number of Nodes 
DECLARE Iteration integer;  -- Number of Max Iteration
DECLARE Diff double;
--For Itertaion by Region
DECLARE SCARR_REGION varchar(8) array;
DECLARE SCARR_INDEX INTEGER;   

--Intialize variable
arr_region = SELECT region as R FROM Region;
SCARR_REGION = ARRAY_AGG(:arr_region.R ORDER BY R);
Iteration := 0;
Alpha := 0.85;
N_PageRank = select * from PageRank;
select count(*) from PageRank;
--By region
WHILE :Iteration < 1 DO
DECLARE TmpRank table (id int , rank float); --Temp PageRank Table
FOR SCARR_INDEX IN 1 .. CARDINALITY(:SCARR_REGION) DO 
		 -- For debugging
--Calculate PageRank
SELECT COUNT(*) INTO Node_Num FROM Y_Node where Y_Node.region = :SCARR_REGION[:SCARR_INDEX];
select count(*) from :TmpRank;
TmpRank = (select * from :TmpRank) union (SELECT Edge.dst as id, SUM(:Alpha * :N_PageRank.rank / OutDegree.degree) + (1 - :Alpha) / :Node_Num as rank
    FROM :N_PageRank
    INNER JOIN OutDegree ON :N_PageRank.id = OutDegree.id and OutDegree.region = :SCARR_REGION[:SCARR_INDEX]
    INNER JOIN Edge ON :N_PageRank.id = Edge.src
    GROUP BY Edge.dst);
--Calculate diff

--Update Origin PageRank Table
--select :Iteration from dummy;
--IF :Diff <0.0001 THEN
	--BREAK;
--END IF;

END FOR;
select sum(abs(new.rank - old.rank)) into Diff from :TmpRank as new, :N_PageRank as old where new.id = old.id;
select :Diff from dummy;
N_PageRank = select * from :TmpRank;
Iteration = :Iteration +1;

END WHILE;
select * from :N_PageRank order by rank desc;
end;
