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


IMPORT FROM CSV FILE '/home/dke/seongpyo/pagerank/cit-HepTh.txt' INTO O_Edge WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY ' ';
