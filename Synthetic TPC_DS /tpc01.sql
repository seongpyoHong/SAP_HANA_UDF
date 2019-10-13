/***********************************************************
This procedure is generated by the query 23_1 template 
in TPC-DS. This query is to to find frequently sold items 
that are items that were sold more than 4 times per day
in four consecutive years, to compute the maximum store 
sales made by any given customer in a period of four 
consecutive years (same as above), to compute the best 
store customers as those that are in the 5th percentile of
sales, and to compute the total sales of sales in March 
made by our best customers buying our most frequent items. 

The detail steps for generating the procedure with loops 
by transforming CTE query are as follows. Each CTE table
variable is transformed to the SQL assignment statement
Then, each query with table variables is decomposed. Finally,
we extended queries that use a year parameter to recursively
compute over several periods using while loop.

Filter(d_moy = 3) in while clause can push down to assignment statement for dd.
***********************************************************/ 
CREATE PROCEDURE "sn_1"(in min_sup integer) 
AS BEGIN
declare _year integer;
declare i integer;
declare cnt BIGINT;
_year := 1999;
i := 0;
cnt := 1000;

ss = select ss_sold_date_sk , ss_item_sk,ss_quantity,ss_sales_price , ss_customer_sk from store_sales ;
ct = select c_customer_sk from customer ;
dd = select d_year, d_date, d_date_sk, d_moy from date_dim ;
it = select i_item_desc , i_item_sk from item ;
cs = select cs_sold_date_sk ,cs_quantity, cs_list_price, cs_item_sk, cs_bill_customer_sk from catalog_sales ;
ws = select ws_bill_customer_sk , ws_quantity, ws_list_price   , ws_sold_date_sk, ws_item_sk  from web_sales ;

freq_items = select d_year, substr(i_item_desc,1,30) item_desc,i_item_sk item_sk,d_date solddate, count(*) cnt 
    		 from :ss ss, :dd dd, :it it
             where ss.ss_sold_date_sk = dd.d_date_sk
             and ss.ss_item_sk = it.i_item_sk 
 		     group by substr(i_item_desc,1,30),i_item_sk,d_date,d_year ;

mss_child = (select c_customer_sk, sum(ss.ss_quantity * ss.ss_sales_price) csales, d_year
            from :ss ss , :ct ct, :dd dd where ss.ss_customer_sk = ct.c_customer_sk 
            and ss.ss_sold_date_sk = dd.d_date_sk group by c_customer_sk, d_year) ;

mss_child_1 = (select max(csales) tpcds_cmax  from :mss_child  where d_year in (:_year, :_year+1) group by c_customer_sk) ; 
max_store_sales = select max(tpcds_cmax) from :mss_child_1 ;


best_ss_customer = select c_customer_sk, sum(ss_quantity * ss_sales_price) ssales
		           from :ss ss, :ct ct
         		   where ss.ss_customer_sk = ct.c_customer_sk 
		           group by ct.c_customer_sk 
		           having sum(ss.ss_quantity* ss.ss_sales_price) > (95/100.0) * (select * from :max_store_sales) ; 

 
WHILE (:cnt > 0) DO
 satisfied_list = select  item_sk, item_desc, solddate, sum(cnt) cnt from :freq_items  where d_year in (:_year, :_year+1)  group by item_desc,item_sk,solddate having sum(cnt) > :min_sup ;
 

 max_store_sales = select max(tpcds_cmax) from (select max(csales) tpcds_cmax from :mss_child where d_year in (:_year, :_year+1) group by c_customer_sk);
  
 best_ss_customer = select c_customer_sk, sum(ss_quantity*ss_sales_price) ssales from :ss ss, :best_ss_customer where ss_customer_sk = c_customer_sk
          group by c_customer_sk having sum(ss_quantity*ss_sales_price) > (95/100.0) * (select * from :max_store_sales );
  
 l_calc = (select cs_quantity*cs_list_price sales
       from :cs cs, :dd dd
       where d_year = :_year 
       and d_moy = 3 
       and cs_sold_date_sk = d_date_sk 
       and cs_item_sk in (select item_sk from :satisfied_list)
       and cs_bill_customer_sk in (select c_customer_sk from :best_ss_customer)
       union all
       select ws_quantity*ws_list_price sales
       from :ws ws, :dd dd
       where d_year = :_year 
       and d_moy = 3 
       and ws_sold_date_sk = d_date_sk 
       and ws_item_sk in (select item_sk from :satisfied_list)
       and ws_bill_customer_sk in (select c_customer_sk from :best_ss_customer));
 
 select ifnull(sum(sales),0) into cnt from :l_calc;
 select :cnt from dummy; -- for check cnt 
 _year = :_year+2;
 
END WHILE;
END



