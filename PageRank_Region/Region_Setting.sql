
--Create region table;
CREATE TABLE Region(region varchar(8));
INSERT INTO Region Values ('Region1');
INSERT INTO Region VALUES ('Region2');
INSERT INTO Region VALUES ('Region3');
INSERT INTO Region VALUES ('Region4');
INSERT INTO Region VALUES ('Region5');
INSERT INTO Region VALUES ('Region6');
INSERT INTO Region VALUES ('Region7');
INSERT INTO Region VALUES ('Region8');
INSERT INTO Region VALUES ('Region9');
INSERT INTO Region VALUES ('Region10');
INSERT INTO Region VALUES ('Region11');


CREATE TABLE Node(id int PRIMARY KEY, region nvarchar(5));
CREATE TABLE Edge(src int,dst int, PRIMARY KEY (src, dst));
CREATE TABLE OutDegree(id int PRIMARY KEY, degree int);
CREATE TABLE PageRank(id int PRIMARY KEY, rank float);
CREATE TABLE TmpRank(id int PRIMARY KEY, rank float);
CREATE TABLE NodeDate(id int PRIMARY KEY, date DATE);

drop table Node;
drop table NodeDate;
drop table OutDegree;
drop table PageRank;
drop table TmpRank;
drop table Edge;
--insert into Edge
ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'system') set ('import_export', 'enable_csv_import_path_filter') = 'false' with reconfigure;
IMPORT FROM CSV FILE '/home/dke/seongpyo/pagerank/cit-HepTh.txt' INTO Edge WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY '\t';
--insert into Node
CREATE TABLE Node AS (SELECT DISTINCT src as id from Edge);

--insert into NodeDateTable
IMPORT FROM CSV FILE '/home/dke/seongpyo/pagerank/cit-HepTh-dates.txt' INTO NodeDate WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY '\t';
select * from Edge where src = 1017;
--create node_year table
do 
begin
declare region varchar(7);
Y_Node = select Node.id, 
(case when d.date between '1992-01-01' and '1992-12-31' then 'Region1' 
	when d.date between '1993-01-01' and '1993-12-31' then 'Region2'
	when d.date between '1994-01-01' and '1994-12-31' then 'Region3'
	when d.date between '1995-01-01' and '1995-12-31' then 'Region4'
	when d.date between '1996-01-01' and '1996-12-31' then 'Region5'
	when d.date between '1997-01-01' and '1997-12-31' then 'Region6'
	when d.date between '1998-01-01' and '1998-12-31' then 'Region7'
	when d.date between '1999-01-01' and '1999-12-31' then 'Region8'
	when d.date between '2000-01-01' and '2000-12-31' then 'Region9'
	when d.date between '2001-01-01' and '2001-12-31' then 'Region10'
	when d.date between '2002-01-01' and '2002-12-31' then 'Region11'
end) as region from Node,NodeDate as d where Node.id =d.id;
CREATE TABLE Y_Node AS (SELECT * from :Y_Node);
end;

--insert into OutDegree
drop table OutDegree;
CREATE TABLE OutDegree AS 
(SELECT Y_Node.id as id, Y_Node.region as region ,COUNT(Edge.src) as degree FROM Y_Node LEFT OUTER JOIN Edge ON Y_Node.id = Edge.src GROUP BY Y_Node.id,Y_Node.region);
select count(*) from OutDegree;

drop table Region


-- Create Initial PageRank Table
DO
BEGIN
DECLARE Alpha double;  --Damping Factor
DECLARE Node_Num integer;  -- Number of Nodes 
DECLARE SCAR_REGION varchar(8) array;
DECLARE SCAR_INDEX INTEGER;   
DECLARE PageRank table(id int , region nvarchar(8),rank float);

--Intialize variable
arr_region = SELECT region as R FROM Region;
SCAR_REGION = ARRAY_AGG(:arr_region.R ORDER BY R);
Alpha := 0.85;

FOR SCAR_INDEX IN 1 .. CARDINALITY(:SCAR_REGION) DO 
select count(*) into Node_Num from Y_Node where Y_Node.region = :SCAR_REGION[:SCAR_INDEX];
select :Node_Num from dummy;
PageRank  =(select * from :PageRank) union (SELECT Y_Node.id as id, :SCAR_REGION[:SCAR_INDEX] as region , ((0.15) / :Node_Num )as rank
FROM Y_Node INNER JOIN OutDegree
ON Y_Node.id = OutDegree.id and Y_Node.region = :SCAR_REGION[:SCAR_INDEX]);
end for;
CREATE TABLE PageRank as (select * from :PageRank);
end;

drop table pageRank;
select count(*) from pageRank;
select * from pageRank order by rank desc;

--For debug
select * from Node;
select * from OutDegree order by degree desc;
select * from PageRank;
