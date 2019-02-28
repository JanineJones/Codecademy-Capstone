--1. How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?

--Count distinct campaigns
SELECT COUNT (DISTINCT utm_campaign) AS 'Campaign_count'
FROM page_visits;

--Count distinct sources
SELECT COUNT (DISTINCT utm_source) AS 'Source_count'
FROM page_visits;

--Relationship between campaigns and sources
SELECT DISTINCT utm_campaign AS 'Campaigns',
				utm_source AS 'Source'
FROM page_visits;


--2. What pages are on the CoolTShirts website?
SELECT DISTINCT page_name AS 'Pages'
FROM page_visits;

--What is the user journey?
--3. How many first touches is each campaign responsible for?
--create a temporary table (first_touch) that finds the earliest timestamp for each user id 
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) AS 'first_touch_at'
    FROM page_visits
    GROUP BY user_id),
--create another temporary table that adds source and campaign colums by joining first_touch to page_visits table on user_id and timestamp    
ft_attr AS (
SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
)
--count the rows to determine how many first touches are attributed to each campaign and source
SELECT ft_attr.utm_source AS Source,
       ft_attr.utm_campaign AS Campaign,
       COUNT(*) AS Count
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;


--4. How many last touches is each campaign responsible for?
--create a temporary table (last_touch) that finds the latest timestamp for each user id 
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) AS 'last_touch_at'
    FROM page_visits
    GROUP BY user_id),
--create another temporary table that adds source and campaign colums by joining last_touch to page_visits table on user_id and timestamp    
lt_attr AS (
SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
--count the rows to determine how many last touches are attributed to each campaign and source
SELECT lt_attr.utm_source AS Source,
       lt_attr.utm_campaign AS Campaign,
       COUNT(*) AS Count
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

--5. How many visitors make a purchase?
--count the number of users that make a purchase by counting the distinct user ids that visit the purchase page
SELECT COUNT(DISTINCT user_id) AS 'Makes Purchase'
FROM page_visits
WHERE page_name = '4 - purchase';

--6. How many last touches on the purchase page is each campaign responsible for?
--create a temporary table (last_touch) that finds the latest timestamp for each user id. Add where clause to only include last touches that were on the purchase page 
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
  WHERE page_name = '4 - purchase'
    GROUP BY user_id),  
lt_attr AS (
SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source AS Source,
       lt_attr.utm_campaign AS Campaign,
       COUNT(*) AS Count
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

