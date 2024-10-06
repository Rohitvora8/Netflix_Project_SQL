# Netflix_Project_SQL

![](https://github.com/Rohitvora8/Netflix_Project_SQL/blob/main/Netflix_logo.jpg)

## Overview
This project focuses on analyzing Netflix's movie and TV show data using SQL to extract insights and address key business questions. The README outlines the project’s objectives, business challenges, solutions, key findings, and conclusions.

## Objectives

- Identifying how much content is produce and watched in all over the world.
- Analyzing the diffrent types of genre in movies and TV shows .
- Finding diffrent type of criteria based on specific key word and names.


## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select 
count(*) filter(where type = 'Movie') as movie
,count(1) filter(where type = 'TV Show') as tvshow
from Netflix;
```

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
select type, rating 
from 
		(select type, rating, count(1) cnt,
		 row_number() over(partition by type order by count(1) desc) rn
		from Netflix
		group by 1, 2 ) x
where x.rn =1;
```

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select title 
from Netflix
where type = 'Movie' and release_year = 2020;
```

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select country, count(1) content
from 
		(select 
		unnest(string_to_array(country, ',')) country, show_id
		from Netflix) x 
group by 1
order by 2 desc
limit 5;
```

### 5. Identify the Longest Movie

```sql
select title,  substring(duration, 1,position ('m' in duration)-1)::int duration
from Netflix
where type = 'Movie' and duration is not null
order by 2 desc
limit 1;
```

### 6. Find Content Added in the Last 5 Years

```sql
select type, title, yr
from 
		(select type, title, substring(date_added, position(',' in date_added)+1)::numeric as yr
		from Netflix) x 
where yr between extract(year FROM current_date) - 5 AND extract(year FROM current_date)
;
```

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select type, title, director
from Netflix
where lower(director) ~ 'rajiv chilaka';
```


### 8. List All TV Shows with More Than 5 Seasons

```sql
select * 
from
		(select type, title, substring(duration, 1, position(' ' in duration))::int season
		from Netflix
		where type = 'TV Show') 
where season > 5;
```


### 9. Count the Number of Content Items in Each Genre

```sql
select *, count(1) cnt
from 
		(select trim(unnest(string_to_array(listed_in, ','))) content
		from Netflix) 
group by 1
order by 2 desc;
```


### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
limit 5;
```


### 11. List All Movies that are Documentaries

```sql
select * from 
	(select type, title, trim(unnest(string_to_array(listed_in, ','))) genra 
	from Netflix)
where genra = 'Documentaries';
```


### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select title, release_year, casts
from Netflix
where casts ~ 'Salman Khan'
  and  release_year >= extract(year from current_date) - 10;
```


### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
select unnest(string_to_array(casts, ',')) actor, count(1) cnt
from Netflix
where type = 'Movie' and country ~ 'India'
group by 1
order by 2 desc
limit 10;
```


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
select flag, count(1) cnt
from
		(select description,
		case when lower(description) ~ 'kill' or lower(description) ~ 'violence' then 'bad'
		else 'good' end flag
		from Netflix)
group by 1;
```



## Findings and Conclusion

- **Top countrys:** providing top countrys with highest no of content create, consume, ratings.
- **Content made:** No of content is releasing every year and also added content before the netflix.
- **Content Categorization:** Categorizing content based on specific keywords, thespian, directer etc. to understand the nature of content available on Netflix.
- **Content Distribution:** The dataset contains a wide range of movies and TV shows with varying ratings and genres.

This analysis gives the information that what kind of content netflixs user like over diffrent region  of same country and diffrent country as well.



