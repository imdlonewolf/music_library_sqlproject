-- senior most employee 

SELECT 
    first_name, last_name
FROM
    employee
ORDER BY levels DESC
LIMIT 1;


-- country having highest number of bills 

SELECT 
    billing_country, COUNT(invoice_id) AS inv_count
FROM
    invoice
GROUP BY billing_country
ORDER BY inv_count DESC
LIMIT 1;
-- top three  total
select total from invoice order by total desc limit 3;


-- city having highest sale 

SELECT 
    invoicecol, SUM(total) AS h
FROM
    invoice
GROUP BY invoicecol
ORDER BY h DESC
LIMIT 1;


-- customer with highest invoice (2 alternative methods) 

SELECT 
    first_name, last_name
FROM
    customer
WHERE
    customer_id = (SELECT 
            customer_id
        FROM
            invoice
        GROUP BY customer_id
        ORDER BY SUM(total) DESC
        LIMIT 1);
        
SELECT 
    c.customer_id, c.first_name, c.last_name, SUM(i.total) AS h
FROM
    customer c
        JOIN
    invoice i
WHERE
    c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY h DESC
LIMIT 1;


-- personal details and genre of rock music

SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    customer_id IN (SELECT DISTINCT
            customer_id
        FROM
            invoice
        WHERE
            invoice_id IN (SELECT 
                    invoice_id
                FROM
                    invoice_line
                WHERE
                    track_id IN (SELECT 
                            track_id
                        FROM
                            track
                        WHERE
                            genre_id = (SELECT 
                                    genre_id
                                FROM
                                    genre
                                WHERE
                                    name = 'Rock'))))
ORDER BY email ASC;


-- top ten rock band based  on number of rock song

SELECT 
    ar.name, COUNT(*) as total
FROM
    album al
        NATURAL JOIN
    artist ar
WHERE
    album_id IN (SELECT 
            album_id
        FROM
            track
        WHERE
            genre_id = (SELECT 
                    genre_id
                FROM
                    genre
                WHERE
                    name = 'Rock'))
GROUP BY al.artist_id
ORDER BY COUNT(*) DESC
LIMIT 10;


-- tracks longer than av track len

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC; 


-- artist per customer 

SELECT 
    ar.name AS artist_name,
    CONCAT(c.first_name, '  ', c.last_name) as customer_name,
    SUM(il.unit_price * il.quantity) AS total
FROM
    artist ar
        JOIN
    album al ON ar.artist_id = al.artist_id
        JOIN
    track t ON t.album_id = al.album_id
        JOIN
    invoice_line il ON t.track_id = il.track_id
        JOIN
    invoice i ON i.invoice_id = il.invoice_id
        JOIN
    customer c ON i.customer_id = c.customer_id
GROUP BY i.customer_id , ar.artist_id
ORDER BY total DESC;


-- each country top genre

WITH country_genre AS (
    SELECT
        i.billing_country AS country,
        g.name,
        COUNT(il.quantity) AS total,
        ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS ranking
    FROM
        genre g
    JOIN
        track t ON g.genre_id = t.genre_id
    JOIN
        invoice_line il ON il.track_id = t.track_id
    JOIN
        invoice i ON i.invoice_id = il.invoice_id
    GROUP BY
        i.billing_country, g.genre_id
    ORDER BY
        total DESC
)
SELECT
    country,
    name,
    total
FROM
    country_genre
WHERE
    ranking = 1;


-- top customer for each country (maybe more than 1) 

WITH country_topcustomer AS (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS name,
        i.billing_country AS country,
        SUM(il.unit_price * il.quantity) AS total,
        ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS ranking
    FROM
        invoice_line il
    JOIN
        invoice i ON il.invoice_id = i.invoice_id
    JOIN
        customer c ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id, i.billing_country
    ORDER BY
        total DESC
)
SELECT
    name,
    country,
    total
FROM
    country_topcustomer
WHERE
    ranking = 1;


