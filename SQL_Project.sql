-- Netflix Project --


CREATE TABLE  Netflix(
	
	show_id	VARCHAR(10) ,
	type VARCHAR (10) ,
	title VARCHAR(150) ,	
	director VARCHAR(208) ,
	casts VARCHAR(1000) ,
	country	VARCHAR(150) ,
	date_added VARCHAR(50),
	release_year INT ,
	rating	VARCHAR(10),
	duration VARCHAR (15),
	listed_in VARCHAR(100),
	description VARCHAR(250)

);
---------------------------------------------------------------------------

--1] COUNT the number of TV shows and Movies ;

select 
	type , 
	COUNT(type) as COUNT  
FROM netflix GROUP BY type ;

---------------------------------------------------------------------------

-- 2] Find the most common rating for movies and TV shows.

select * from netflix ; -- For checking

select type , 
	   rating  
	   from(
			select 
				type , 
				rating , 
				COUNT(rating) as Common_rating ,
				DENSE_RANK()OVER(PARTITION BY type ORDER BY COUNT(rating)  DESC) AS RANK 
				from netflix 
				group by type , rating 
			)t 
		where RANK = 1 ; 

----------------------------------------------------------------------------

--3] List all movies release in a specific year (e.g 2020)

select * from netflix ; -- For checking

select 
	* 
from netflix 
where 
	release_year = 2020 
	AND 
	type = 'Movie' ;
	
----------------------------------------------------------------------------

--4] Find the top 5 countries with the most content on netflix ;

select * from netflix ; -- For checking

select 
	country , 
	count 
	from (
			select  
				UNNEST(STRING_TO_ARRAY(country , ',')) AS country,
				count(show_id) As count ,
				DENSE_RANK()OVER (order by count(show_id) Desc) AS Rank 
			from netflix 
			group by 1 
		 ) as t 
		 where 
		 	Rank in (1,2,3,4,5)  ; 
			 
---------------------------------------------------------------------------

--5] Indentify the longest movies

select  CAST (SPLIT_PART(duration , ' ' , 1) AS INTEGER) as Minutes from netflix order by minutes DesC;-- For checking
select * from netflix ; -- For checking

select 
	type , 
	title , 
	minutes  
from (
	select 
		type ,
		title,  
		CAST (SPLIT_PART(duration , ' ' , 1) AS INTEGER) as Minutes ,
		Dense_Rank () over(order by CAST (SPLIT_PART(duration , ' ' , 1) AS INTEGER) desc ) AS Rank
	from netflix  
	where CAST (SPLIT_PART(duration , ' ' , 1) AS INTEGER) is not null and type = 'Movie'
) as t 
Where Rank = 1  ;

--------------------------------------------------------------------------

--6] Find content added in the last 5 years 

select * from netflix ; -- For checking

select 
	added_year , 
	type , 
	title 
from( 
	select  
		* , 
		CAST(SPLIT_PART(date_added , ', ' , 2) as Integer) as added_year,
		dense_Rank() over( order by (CAST(SPLIT_PART(date_added , ', ' , 2) as Integer)) desc ) as Rank 
	from netflix 
	where CAST(SPLIT_PART(date_added , ', ' , 2) as Integer) is not null 
) as t 
where Rank < 6;

--------------------------------------------------------------------------

--7] Find all the movies/Tv shows by director name "Rajiv Chilaka".

select * from netflix ; -- For checking

select 
	type , 
	title , 
	director 
from netflix 
where director like '%Rajiv Chilaka%' ;

--------------------------------------------------------------------------

--8] List all TV Shows with more than 5 seasons 

select type ,count(*) from netflix  group by type ; -- For checking

select 
	* 
from (
	select 
		type , 
		title , 	
		cast(split_part(duration , ' ' , 1) as integer) as season_number 
	from netflix 
	where type ='TV Show' 
) as t 
where season_number > 5 ;

---------------------------------------------------------------------------

--9] Count the number of content items in each genre.

select UNNEST(STRING_TO_ARRAY(listed_in , ',')) as genre from netflix  ; -- For checking

select 
	UNNEST(STRING_TO_ARRAY(listed_in , ', ')) as genre , 
	count(show_id) as count 
from netflix 
group by UNNEST(STRING_TO_ARRAY(listed_in , ', ')) 
order by count desc ;  

---------------------------------------------------------------------------

-- 10] Find each year and the average numbers of content release in each year in India on netflix. Return top 5 year with highest avg content release!

select count(*) from netflix where country ilike '%India%'; -- For checking


select 
	cast(split_part(date_added , ',' , 2) as integer) as year , 
	count(show_id) as count , 
	ROUND((count(show_id)::numeric / (select count(*) from netflix where country ilike '%India%')::numeric * 100) , 2) 
from netflix 
where country ilike '%India%' 
group by 1 
order by 2 desc;

---------------------------------------------------------------------------

-- 11] List all movies that are documentaries ;

select * from netflix; -- For checking

SELECT 
	* 
from netflix 
where listed_in ILIKE '%documentaries%' ;

--------------------------------------------------------------------------

-- 12] Find all content without a director

select * from netflix where director is null ; 

--------------------------------------------------------------------------

-- 13] Find how many movies actor 'Salman Khan' appeared in last 10 years!

select 
	release_year , 
	count(title) as count_movies 
from (
		select 
			release_year , 
			title , 
			casts 
		from netflix 
		where casts ilike '%Salman Khan%' 
		order by release_year desc 
) as t 
group by release_year 
order by 1 desc  
limit 10 ; 

--------------------------------------------------------------------------

-- 14] Find the top 10 actors who have appeared in the highest number of movies produced in India. 

select 
	unnest(STRING_TO_ARRAY(casts , ', ')) as actors , 
	count(*) 
from netflix 
where country ilike '%India%' 
group by 1 
order by 2 desc 
limit 10 ;

--------------------------------------------------------------------------

-- 15]Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--    the description field. Label content containing these keywords as 'Bad' and all other 
-- 	  content as 'Good'. Count how many items fall into each category.

with filter as (
select * ,
(case
	when description ilike '%kill%' or description ilike '%violen%'  then 'Bad'
	else 'Good'
	end
 )as filteration 		
from netflix
) 
select filteration , count(*) from filter group by filteration ;