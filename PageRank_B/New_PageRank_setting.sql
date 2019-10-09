CREATE TABLE Node(id int PRIMARY KEY, region nvarchar(5));
CREATE TABLE Edge(src int,dst int, PRIMARY KEY (src, dst));
CREATE TABLE OutDegree(id int PRIMARY KEY, degree int);
CREATE TABLE PageRank(id int PRIMARY KEY, rank float);
CREATE TABLE TmpRank(id int PRIMARY KEY, rank float);

drop table Node;
drop table OutDegree;
drop table PageRank;
drop table TmpRank;
--insert into Edge
ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'system') set ('import_export', 'enable_csv_import_path_filter') = 'false' with reconfigure;
IMPORT FROM CSV FILE '/home/dke/seongpyo/pagerank/web-Stanford.txt' INTO Edge WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY ' ';

--insert into Node
CREATE TABLE Node AS (SELECT DISTINCT src as id from Edge);

--insert into OutDegree
CREATE TABLE OutDegree AS 
(SELECT Node.id as id , COUNT(Edge.src) as degree FROM Node LEFT OUTER JOIN Edge ON Node.id = Edge.src GROUP BY Node.id);

-- Create Initial PageRank Table
DO
BEGIN
DECLARE Alpha double;  --Damping Factor
DECLARE Node_Num integer;  -- Number of Nodes 
Alpha := 0.85;
select count(*) into Node_Num from Node;
PageRank  = (SELECT Node.id as id, ((0.15) / :Node_Num )as rank
FROM Node INNER JOIN OutDegree
ON Node.id = OutDegree.id);
CREATE TABLE PageRank as (select * from :PageRank);
end;

--For debug
select * from Node;
select * from OutDegree order by degree desc;
select * from PageRank;
