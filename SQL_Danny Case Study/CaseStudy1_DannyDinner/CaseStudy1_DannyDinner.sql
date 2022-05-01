 /* --------------------
   Create tables
   --------------------*/

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  




 /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
	-- join sales and menu on product_id
	-- select customer_id and sum of price
	-- group by customer_id

		select
			s.customer_id as customers,
			sum(m.price) as total_spend
		from
			sales as s
			inner join menu as m
				on s.product_id = m.product_id
		group by s.customer_id;
	
	
-- 2. How many days has each customer visited the restaurant?
	-- select customer_id and count of distinct order_date 
	-- group by customer_id

		select 
			customer_id as customers,
			COUNT(DISTINCT order_date) AS days_visitted
		from sales
		group by customer_id;
	
	
-- 3. What was the first item from the menu purchased by each customer?
	-- join sales and menu by product_id 
	-- partition by customer_id
	-- order by order_date
	-- select index 1
	
	
	-- Step 0: 
		drop if exists
	
	-- Step 1: join sales and menu by product_id and save as #temp table
		select 
			s.customer_id, s.order_date, m.product_name
		into #temp -- save into a tempt table
		from sales as s
			right join menu as m
			on s.product_id = m.product_id
		order by customer_id
	
	-- Step 2: create #temp1 table with three columns: customer_id, product_name, customer_id_index
		select 
			customer_id,
			product_name,
			row_number() over -- partion #temp by customer_id and order by order_date, 
				(
				partition by customer_id
				order by order_date
				)
				as customer_id_index
		into #temp1
		from #temp

	-- Step 3: select index 1
		select * from #temp1 where customer_id_index = 1
	
	
	
	-- COMBINATIon
	
		drop table if exists #temp;
		
		select 							-- join sales and menu by product_id and save as #temp table
			s.customer_id, s.order_date, m.product_name
		into #temp 						-- save into a tempt table
		from sales as s
			right join menu as m
			on s.product_id = m.product_id
		order by customer_id

		select 
			customer_id,
			product_name
		from (
			select -- 
				customer_id,	
				product_name,
				row_number() over -- partion #temp by customer_id and order by order_date, 
					(
					partition by customer_id
					order by order_date
					)
					
					as customer_id_index
			from #temp
			)
			as temp1
		where customer_id_index = 1
	

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
	-- join sales and menu
	-- save into #temp three columns: customer_id, product_name, times each product bought
	-- sum up times each product bought by all customer
	-- sorting times bought in descending order
	-- select top 1

	-- Step 1:
		drop table if exists #temp
		select
			s.customer_id as customers,
			m.product_name as product_name,
			count(m.product_name) as times_bought   -- sum up times each product bought
		into #temp									-- save into #temp three columns
		from
			sales as s
			inner join menu as m
				on s.product_id = m.product_id
		group by s.customer_id, m.product_name
		order by times_bought desc
	-- Step 2:
		select top(1)								 -- select top 1
			product_name as product_name,
			sum(times_bought) as total_bought		 -- sum up times each product bought by all customer
		from #temp
		group by product_name
		order by total_bought desc					 -- sorting times bought in descending order
	

-- 5. Which item was the most popular for each customer?
	-- join sales and menu
	-- add count product_name group by customer
	-- add index on times bought for each oproduct
	-- select index 1 for each partition on customers
	
	-- answer 1
		drop table if exists #temp					-- clear 
		select
			s.customer_id as customers,
			m.product_name as product_name,
			count(m.product_name) as times_bought   -- join sales with menu, add count 
		into #temp									-- save into temp table
		from
			sales as s
			inner join menu as m
				on s.product_id = m.product_id
		group by s.customer_id, m.product_name
		order by customers asc, times_bought desc	-- sorting

		drop table if exists #temp1					-- clear 
		select 
			customers,
			product_name,
			--times_bought,
			row_number() over						-- add index based on times_bought
				(
				partition by customers
				order by times_bought
				)
				as index_
		into #temp1
		from #temp
		
		select 
			customers,
			product_name
		from #temp1
		where index_ = 1

	-- answer 2:
	-- Step 1:
		drop table if exists #temp
		select
			s.customer_id as customers,
			m.product_name as product_name,
			count(m.product_name) as times_bought
		into #temp
		from
			sales as s
			inner join menu as m
				on s.product_id = m.product_id
		group by s.customer_id, m.product_name
		order by times_bought desc
	-- Step 2:		
		select 
			customers,
			product_name
		from (
			select 
			customers,
			product_name,
			--times_bought,
			row_number() over
				(
				partition by customers
				order by times_bought
				)
				as index_
			from #temp
			) as abc_name
		where index_ = 1

	
-- 6. Which item was purchased first by the customer after they became a member?
	-- Join sales and members on customer_id and order_date >= join_date
	--  group by 
	-- sort by increasing order of order_date
	-- select top 1 for each group of customer_id
	
		drop table if exists #temp;
			
		select 
			s.customer_id, 
			m.join_date, 
			s.order_date,
			menu.product_name
			-- count(s.customer_id)
		into #temp
		from sales as s 
			join members as m 
			on  s.customer_id = m.customer_id and 
				s.order_date >= m.join_date
			join menu on s.product_id = menu.product_id
			group by	s.customer_id, 
						m.join_date, 
						s.order_date,
						menu.product_name
		select *
		from (
			select row_number() over (
				partition by customer_id 
				order by order_date) 
				AS index_, * 
			from #temp) 
			dummies_name
		WHERE Index_ = 1		

-- 7. Which item was purchased just before the customer became a member?
	-- join sales with member on customer_id
	-- join with menu on product_id
	-- select order_date < join_date
	-- sorting by order_date descending
	-- insert index_ column partition by customers, order by order_date
	-- select index_ = 1

	-- answer 1:
		drop table if exists #temp
		drop table if exists #temp1

		select 
			s.customer_id customers,
			s.order_date, 
			m.join_date,
			menu.product_name
		into #temp
		from sales as s
			join members as m on s.customer_id = m.customer_id
			join menu on menu.product_id = s.product_id
		where order_date < join_date
		order by customers asc, order_date desc

		select 
			customers,
			product_name,
			row_number() over
				(
				partition by customers
				order by order_date desc		
				) 
				as index_
		into #temp1
		from #temp

		select 
			customers,
			product_name
		from #temp1
		where index_ = 1

	-- answer 2
	--  Step 1
		select 
			s.customer_id customers,
			s.order_date, 
			m.join_date,
			menu.product_name
		into #temp
		from sales as s
			join members as m on s.customer_id = m.customer_id
			join menu on menu.product_id = s.product_id
		where order_date < join_date
		order by customers asc, order_date desc
	-- Step 2
		select 
			customers,
			product_name
		from 
			(select 
			customers,
			product_name,
			row_number() over
				(
				partition by customers
				order by order_date desc		
				) 
				as index_
			from #temp)
			as temp1
		where index_ = 1



-- 8. What is the total items and amount spent for each member before they became a member?

	-- Step 1:  join three tables into #temp table with order_date < join_date

		select 
			s.customer_id customers,
			s.order_date, 
			m.join_date,
			menu.product_name,
			menu.price
		into #temp
		from sales as s
			join members as m on s.customer_id = m.customer_id
			join menu on menu.product_id = s.product_id
		where order_date < join_date
		order by customers asc, order_date desc
		
	-- Step 2: count by customers and sum by price group by customers
		select
			customers,
			count(customers) as total_items,
			sum(price) as amount_spent
		from #temp
		group by customers
		
		

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?
	
	-- add column multiplier 
	-- calculate points for each product
	-- sum of points for each customer
	
	
	-- Step 1: generate #temp table with customers, price, multiplier
		select 
			s.customer_id as customers,
			-- m.product_name products,
			m.price,
			case m.product_name	
				when 'sushi' then 2
				else 1
			end as multiplier
		into #tempt
		from sales as s
			join menu as m
			on s.product_id = m.product_id

	-- Step 2: generate table #temp1 with column points
		select 
			customers,
			price*multiplier*10 as points
		into #tempt1
		from #tempt
	-- Step 3: calculate sum of points for each customers
		select 
			customers,
			sum(points) as total_points
		from #tempt1
		group by customers

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

		drop table if exists #tempt
		drop table if exists #tempt1
		
	-- Step 1: generate #temp table with customers, price, multiplier
		select 
			s.customer_id as customers,
			members.join_date,
			s.order_date,
			m.product_name products,
			m.price,
			case
				when join_date <= order_date and order_date <= DATEADD(day, 7, join_date) then 2
				when product_name = 'sushi' then 2
				else 1
			end as multiplier
		into #tempt
		from sales as s
			join menu as m
			on s.product_id = m.product_id
			join members
			on s.customer_id = members.customer_id
			
		-- select * from #tempt

	-- Step 2: generate table #temp1 with column points
		select 
			customers,
			price*multiplier*10 as points
		into #tempt1
		from #tempt

	    -- select * from #tempt1

	-- Step 3: calculate sum of points for each customers
		select 
			customers,
			sum(points) as total_points
		from #tempt1
		group by customers
