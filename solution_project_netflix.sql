-- Netflix Project

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

select type,
       count(*) as total_content
from netflix
group by type;


-- 2. Find the most common rating for movies and TV shows
select type,
        rating
from 			
(
   select type,
       rating,
       count(rating) as total_count,
	   rank() over (partition by type order by count(rating) desc) as ranking
from netflix
group by 1,2
order by 1,3 desc
)x
where x.ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

select title
from netflix
where type ='Movie'
      and 
	  release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

select unnest(string_to_array(country, ',')) as new_country,
       count (show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;


-- 5. Identify the longest movie

select *     
from netflix
where type = 'Movie' and duration = (select max(duration) from netflix );


-- 6. Find content added in the last 5 years

select *
from netflix
where to_date(date_added, 'Month DD, YYYY') >= CURRENT_DATE- interval '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from (
Select *,unnest(string_to_array(director, ',')) as new_director
from netflix)x
where x.new_director = 'Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons

select *
from netflix
where type = 'TV Show'
and 
split_part(duration, ' ',1) :: numeric >5 ;

-- 9. Count the number of content items in each genre

select new_genre,
      count(*) as total_content
	  from 
(select *,
        unnest(string_to_array(listed_in, ',')) as new_genre
from netflix)x
group by x.new_genre
order by 2 desc;



-- 10.Find each year and the average numbers of content release in India on netflix. 
--    return top 5 year with highest avg content release!

select 
        extract(year FROM to_date(date_added, 'Month DD YYYY')) AS year,
		count(*),
		round(count(*) :: numeric/ (select count(*) from netflix where country = 'India' )*100,2) as avg_content_per_year
from netflix
where country = 'India'
group by 1;



-- 11. List all movies that are documentaries

select *
       -- unnest(string_to_array(listed_in, ','))   as genre 
from netflix
where  listed_in ilike '%documentaries%';



-- 12. Find all content without a director

select *
from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where type='Movie'
and 
 casts ilike '%Salman Khan%'
 and release_year > extract (year from current_date) -10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
         unnest(string_to_array(casts, ',')) as actors,
		 count(*)
 from netflix
 where country ilike '%india'
 And type = 'Movie'
 group by 1
 order by 2 desc
 limit 10;
 

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

with cte as (
select  *,
case when description ilike '%kill%' 
or description ilike '%violence%' then 'bad_content'
else 'good content'
end as category
from netflix)
select 
      category,
	  count(*) as total_count
	  from cte
	  group by 1;

