que : 1 Count the number of Movies vs TV Shows
select 
count(*) filter(where type = 'Movie') as movie
,count(1) filter(where type = 'TV Show') as tvshow
from Netflix


que : 2 Find the most common rating for movies and TV shows
select type, rating 
from 
		(select type, rating, count(1) cnt,
		 row_number() over(partition by type order by count(1) desc) rn
		from Netflix
		group by 1, 2 ) x
where x.rn =1


que:3 List all movies released in a specific year (e.g., 2020)
select title 
from Netflix
where type = 'Movie' and release_year = 2020

que :4 Find the top 5 countries with the most content on Netflix
select country, count(1) content
from 
		(select 
		unnest(string_to_array(country, ',')) country, show_id
		from Netflix) x 
group by 1
order by 2 desc
limit 5


que :5 Identify the longest movie
select title,  substring(duration, 1,position ('m' in duration)-1)::int duration
from Netflix
where type = 'Movie' and duration is not null
order by 2 desc
limit 1

que :6 Find content added in the last 5 years
select type, title, yr
from 
		(select type, title, substring(date_added, position(',' in date_added)+1)::numeric as yr
		from Netflix) x 
where yr between extract(year FROM current_date) - 5 AND extract(year FROM current_date)


que :7 Find all the movies/TV shows by director 'Rajiv Chilaka'
select type, title, director
from Netflix
where director ~ 'Rajiv Chilaka'

que :8 List all TV shows with more than 5 seasons
select * 
from
		(select type, title, substring(duration, 1, position(' ' in duration))::int season
		from Netflix
		where type = 'TV Show') 
where season > 5

que :9 Count the number of content items in each genre
select *, count(1) cnt
from 
		(select trim(unnest(string_to_array(listed_in, ','))) content
		from Netflix) 
group by 1
order by 2 desc


que :10 Find each year and the average numbers of content release in India on netflix. 
        return top 5 year with highest avg content release
with cte as 
        (select unnest(string_to_array(country, ',')) country, show_id, 
				 substring(date_added, position(',' in date_added)+1)::numeric as yr 
				 from Netflix)
select country, yr, count(1) cnt
, round((count(1)::decimal/(select count(1) from cte where country = 'India')*100),2) avg
from cte 
where country = 'India'
group by 1,2
order by avg desc 
limit 5



que:11 List all movies that are documentaries	
select * from 
	(select type, title, trim(unnest(string_to_array(listed_in, ','))) genra 
	from Netflix)
where genra = 'Documentaries'

que :12  Find all content without a director
select * from Netflix
where director is null


que :13 Find how many movies actor 'Salman Khan' appeared in last 10 years
select title, release_year, casts
from Netflix
where casts ~ 'Salman Khan'
  and  release_year >= extract(year from current_date) - 10


que :14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
select unnest(string_to_array(casts, ',')) actor, count(1) cnt
from Netflix
where type = 'Movie' and country ~ 'India'
group by 1
order by 2 desc
limit 10

que 15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
			 the description field. Label content containing these keywords as 'Bad' and all other 
			 content as 'Good'. Count how many items fall into each category.
select flag, count(1) cnt
from
		(select description,
		case when lower(description) ~ 'kill' or lower(description) ~ 'violence' then 'bad'
		else 'good' end flag
		from Netflix)
group by 1






































































