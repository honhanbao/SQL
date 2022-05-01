
-- https://8weeksqlchallenge.com/case-study-2/

	-- CREATE SCHEMA pizza_runner;
	-- SET search_path = pizza_runner;

	DROP TABLE IF EXISTS runners;
	CREATE TABLE runners (
	  "runner_id" INTEGER,
	  "registration_date" DATE
	);
	INSERT INTO runners
	  ("runner_id", "registration_date")
	VALUES
	  (1, '2021-01-01'),
	  (2, '2021-01-03'),
	  (3, '2021-01-08'),
	  (4, '2021-01-15');
	  
	-- select * from runners;

	DROP TABLE IF EXISTS customer_orders;
	CREATE TABLE customer_orders (
	  "order_id" INTEGER,
	  "customer_id" INTEGER,
	  "pizza_id" INTEGER,
	  "exclusions" VARCHAR(4),
	  "extras" VARCHAR(4),
	  "order_time" VARCHAR(19)
	);

	INSERT INTO customer_orders
	  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
	VALUES
	  (1, 101, 1,  ' ',	' ', '2020-01-01 18:05:02'),
	  (2, 101, 1,  '',	'', '2020-01-01 19:00:52'),
	  (3, 102, 1,  '',	'', '2020-01-02 23:51:23'),
	  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
	  (4, 103, 1,  '4',	'', '2020-01-04 13:23:46'),
	  (4, 103, 1,  '4', '', '2020-01-04 13:23:46'),
	  (4, 103, 2,  '4', '', '2020-01-04 13:23:46'),
	  (5, 104, 1,  'null', '1', '2020-01-08 21:00:29'),
	  (6, 101, 2,  'null', 'null', '2020-01-08 21:03:13'),
	  (7, 105, 2,  'null', '1', '2020-01-08 21:20:29'),
	  (8, 102, 1,  'null', 'null', '2020-01-09 23:54:33'),
	  (9, 103, 1,  '4',	'1, 5', '2020-01-10 11:22:59'),
	  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
	  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

	-- select * from customer_orders;
	

	DROP TABLE IF EXISTS runner_orders;
	CREATE TABLE runner_orders (
	  "order_id" INTEGER,
	  "runner_id" INTEGER,
	  "pickup_time" VARCHAR(19),
	  "distance" VARCHAR(7),
	  "duration" VARCHAR(10),
	  "cancellation" VARCHAR(23)
	);

	INSERT INTO runner_orders
	  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
	VALUES
	  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
	  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
	  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
	  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
	  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
	  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
	  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
	  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
	  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
	  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

	-- select * from runner_orders;

	DROP TABLE IF EXISTS pizza_names;
	CREATE TABLE pizza_names (
	  "pizza_id" INTEGER,
	  "pizza_name" TEXT
	);
	INSERT INTO pizza_names
	  ("pizza_id", "pizza_name")
	VALUES
	  (1, 'Meatlovers'),
	  (2, 'Vegetarian');

	-- select * from pizza_names;

	DROP TABLE IF EXISTS pizza_recipes;
	CREATE TABLE pizza_recipes (
	  "pizza_id" INTEGER,
	  "toppings" VARCHAR(30)
	);
	INSERT INTO pizza_recipes
	  ("pizza_id", "toppings")
	VALUES
	  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
	  (2, '4, 6, 7, 9, 11, 12');

	-- select * from pizza_recipes;

	DROP TABLE IF EXISTS pizza_toppings;
	CREATE TABLE pizza_toppings (
	  "topping_id" INTEGER,
	  "topping_name" TEXT
	);
	INSERT INTO pizza_toppings
	  ("topping_id", "topping_name")
	VALUES
	  (1, 'Bacon'),
	  (2, 'BBQ Sauce'),
	  (3, 'Beef'),
	  (4, 'Cheese'),
	  (5, 'Chicken'),
	  (6, 'Mushrooms'),
	  (7, 'Onions'),
	  (8, 'Pepperoni'),
	  (9, 'Peppers'),
	  (10, 'Salami'),
	  (11, 'Tomatoes'),
	  (12, 'Tomato Sauce');
  
	-- select * from pizza_toppings;
  
/*
A. Pizza Metrics
*/

-- 1 How many pizzas were ordered?

	select 
		count(*) as total_orders
	from 
		customer_orders;
		
-- 2 How many unique customer orders were made?

	select 
		count(DISTINCT customer_id) AS total_unique_customer_orders
	from customer_orders;
	
-- 3 How many successful orders were delivered by each runner?
	
	select 
		runner_id,
		count(*) as successfully_delivered_by_runner
	from runner_orders
	where pickup_time != 'null'
	group by runner_id
	
	
-- 4 How many of each type of pizza was delivered?
	
	select 
		pizza_id,
		count(*) as successfully_delivered_by_runner
	from customer_orders
	group by pizza_id
	
-- 5 How many Vegetarian and Meatlovers were ordered by each customer?

	select
		o.customer_id,
		n.pizza_name
		-- count(*)
	from customer_orders as o
		join pizza_names as n
	on o.pizza_id = n.pizza_id

-- 7 How many pizzas were delivered that had both exclusions and extras?
	-- select those with both neither null nor ''.
	select 
		count(exclusions)
	from customer_orders
	where exclusions != '' and exclusions != 'null' and extras != '' and extras != 'null'

-- 8 What was the total volume of pizzas ordered for each hour of the day?

-- 9 What was the volume of orders for each day of the week?

/*
B. Runner and Customer Experience
*/

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

	SELECT 
		count(runner_id)
	from runners
	where registration_date >= '2021-01-01' and registration_date <= '2021-01-07';


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
	-- extract minutes with substring and cast to int
	-- use avg function

	select 
		avg(cast(SUBSTRING(duration, 1, 2) as int))
	from runner_orders
	where duration != 'null'


-- 3. What was the average distance travelled for each customer?
	-- null -> 0
	-- ab.cdkm -> ab.cd
	-- ab -> ab
	-- not yet working as varchar -. float needs more work

	select 
		CASE
			WHEN SUBSTRING(distance, len(distance)-2, len(distance)) = 'km' 
				THEN cast(SUBSTRING(distance, 1, len(distance)-2) as float)
			WHEN SUBSTRING(distance, len(distance)-2, len(distance)) = 'll'
				THEN 0
			ELSE cast(distance as float)
		END
	from runner_orders;

-- 4. What was the difference between the longest and shortest delivery times for all orders?

	-- create a tempt table for times
	drop table if exists #temp
	select 
		cast(SUBSTRING(distance, 1, 2) as int) as times
	into #temp
	from runner_orders
		where distance != 'null';

		select * from #temp;
	-- max - min of times
	select 
		max(times)- min(times)
	from #temp


-- 5. What was the average speed for each runner for each delivery and do you notice any trend for these values?

	-- drop table if exists #temp;
	-- temp table for runner_id and times
	select runner_id, cast(SUBSTRING(duration, 1, 2) as int) as times
	into #temp
	from runner_orders 
	where SUBSTRING(duration, 1, 2) != 'nu';

	-- average of times group by runner_id
	select 
		AVG(times)
	from #temp
	group by runner_id;

-- 6. What is the successful delivery percentage for each runner?
	-- extract intersection of toppings

/*
C. Ingredient Optimisation
*/

-- 1. What are the standard ingredients for each pizza?
	-- split comma in toppings for each pizza_id and store in a tempt table #id1
	-- remove space ' ' in front of each toppings and store in a tempt table #id1final
	-- same for pizza_id = 2
	-- select intersect on toppings

	-- split comma in toppings for each pizza_id and store in a tempt table #id1
	DROP TABLE IF EXISTS #id1;
	select
		pizza_id,
		VALUE toppings
	into #id1
	from 
		pizza_recipes
		CROSS APPLY STRING_SPLIT(toppings, ',')
		WHERE pizza_id = 1;

	-- split comma in toppings for each pizza_id and store in a tempt table #id2
	DROP TABLE IF EXISTS #id2;
	select
		pizza_id,
		VALUE toppings
	into #id2
	from 
		pizza_recipes
		CROSS APPLY STRING_SPLIT(toppings, ',')
		WHERE pizza_id = 2;

	-- remove space ' ' in front of each toppings in #id1 and store in a tempt table #id1final
	select 
		pizza_id,
		case 
			when SUBSTRING(toppings, 1, 1) = ' ' then SUBSTRING(toppings, 2, len(toppings))
			when SUBSTRING(toppings, 1, 1) != ' ' then toppings
		end
		as toppings
	into #id1final
	from #id1;

	-- remove space ' ' in front of each toppings in #id2 and store in a tempt table #id2final
	select 
		pizza_id,
		case 
			when SUBSTRING(toppings, 1, 1) = ' ' then SUBSTRING(toppings, 2, len(toppings))
			when SUBSTRING(toppings, 1, 1) != ' ' then toppings
		end
		as toppings
	into #id2final
	from #id2;

	-- select intersect on toppings
	select 
		fst.toppings
	from #id1final fst
		join #id2final snd
		on fst.toppings = snd.toppings;


-- 2. What was the most commonly added extra?

	-- select those extras with int and save into #temp
	select 
		extras 
	into #temp
	from 
		customer_orders 
	where SUBSTRING(extras, 1,1) != 'n' and 
	SUBSTRING(extras, 1,1) != 'N' and SUBSTRING(extras, 1,1) != ''

	-- split extrs with comma ,
	select 
		value extras
	into #temp1
	from #temp
	CROSS APPLY STRING_SPLIT(extras, ',')

	-- remove space 
	select 
		case 
			when SUBSTRING(extras, 1, 1) = ' ' then SUBSTRING(extras, 2, len(extras))
			when SUBSTRING(extras, 1, 1) != ' ' then extras
		end
		as extras
	into #temp2
	from #temp1
	
	-- count occurency and sort in descending order, limit with one row
	select Top 1
		extras,
		count(extras) as occurency
	from #temp2
	group by extras
	order by occurency desc;

/*
-- 3. Generate an order item for each record in the customers_orders table in the format of one of the following:
	Meat Lovers
	Meat Lovers - Exclude Beef
	Meat Lovers - Extra Bacon
	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
*/

	-- First list all toppings, exclusions, and extras
	select 
		c.order_id,
		c.customer_id,
		c.pizza_id,
		n.toppings,
		c.exclusions,
		c.extras
	from customer_orders c
	left join pizza_recipes n on c.pizza_id = n.pizza_id;
	
	-- Then use control structure


/*
-- 4. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
	from the customer_orders table and add a 2x in front of any relevant ingredients
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
*/     
	-- First list all toppings, exclusions, and extras
	select 
		c.order_id,
		c.customer_id,
		c.pizza_id,
		n.toppings,
		c.exclusions,
		c.extras
	from customer_orders c
	left join pizza_recipes n on c.pizza_id = n.pizza_id;
	-- Then use control structure


-- 5. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
	-- First list all toppings, exclusions, and extras
	select 
		c.order_id,
		c.customer_id,
		c.pizza_id,
		n.toppings,
		c.exclusions,
		c.extras
	from customer_orders c
	left join pizza_recipes n on c.pizza_id = n.pizza_id;
	-- Then use control structure

/*
D. Pricing and Ratings
*/

/*
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
      - how much money has Pizza Runner made so far if there are no delivery fees?
*/
	-- total of each pizza ordered
	select 
		pizza_id,
		count(pizza_id) as pizza_id_total,
		case
			when pizza_id = 1 then 12
			when pizza_id = 2 then 10
		end 
			as price
		sum(pizza_id_total*price)
	into #tempt
	from customer_orders
	group by pizza_id;

	select 
		sum(pizza_id_total*price)
	from #tempt

/*
-- 2. What if there was an additional $1 charge for any pizza extras?
	Add cheese is $1 extra
*/
	select 
		pizza_id,
		extras,
		case	
			when len(extras) = 1 then extras
			when CHARINDEX(',', extras) != 0 then LEN(extras) - LEN(REPLACE(extras, ',', ''))+1
			else 0
		end 
			AS extras_total
	into #tempt
	from customer_orders;

	select * from #tempt




/*
--3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
	how would you design an additional table for this new dataset - generate a schema for this new table and 
	insert your own data for ratings for each successful customer order between 1 to 5.
*/

/*
-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	customer_id
	order_id
	runner_id
	rating
	order_time
	pickup_time
	Time between order and pickup
	Delivery duration
	Average speed
	Total number of pizzas
*/

/*
-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
	-- how much money does Pizza Runner have left over after these deliveries?
*/

/*
E. Bonus Questions

-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
*/