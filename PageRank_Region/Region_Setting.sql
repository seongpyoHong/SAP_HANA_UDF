
--Create region table;
CREATE TABLE Region(region varchar(7));
INSERT INTO Region Values ('Region1');
INSERT INTO Region VALUES ('Region2');
INSERT INTO Region VALUES ('Region3');
INSERT INTO Region VALUES ('Region4');
INSERT INTO Region VALUES ('Region5');

--Create R_Node Table
do 
begin
declare region varchar(7);
R_Node = select id, 
(case when mod(id,5) = 0 then 'Region1' 
	when mod(id,5) = 1 then 'Region2'
	when mod(id,5) = 2 then 'Region3'
	when mod(id,5) = 3 then 'Region4'
	when mod(id,5) = 4 then 'Region5'
end) as region from Node;
CREATE TABLE R_Node AS (SELECT * from :R_Node);
end;

--For Debugging 
select * from R_Node;
