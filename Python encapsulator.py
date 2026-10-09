"""
movie_database.py: Python encapsulator for the moviesbro_v2 database.

The MovieDatabase class hides the database: it connects to PostgreSQL and returns
query results as pandas DataFrames, so whoever analyses the data doesn't need to
write SQL or know how the tables are connected.

"""
from getpass import getpass                       # to ask for the password in a pop-up

import pandas as pd                               # query results are returned as pandas DataFrames
from sqlalchemy import URL, create_engine, text   # SQLAlchemy talks to PostgreSQL through psycopg2


class MovieDatabase:
    """Connects to the moviesbro_v2 database and returns query results as DataFrames."""

    def __init__(self, db_name="movie", user="postgres", host="localhost", port=5432):

        password = getpass("PostgreSQL password: ")

        # The address of the database: which driver, user, password, server, port and database to use.
        url = URL.create(
            "postgresql+psycopg2",
            username=user,
            password=password,
            host=host,
            port=port,
            database=db_name,
        )

        # The engine is SQLAlchemy's connection to the database; every query goes through it.
        self.engine = create_engine(url)

    def run_query(self, sql):
        # Runs a SQL query and returns the result as a pandas DataFrame.
        with self.engine.connect() as conn:          # open a connection, closed again automatically
            return pd.read_sql(text(sql), conn)      # send the SQL, return the rows as a DataFrame

#H1
    def budget_vs_box_office(self):
        sql = """
            SELECT
                CASE
                    WHEN production_budget < 20000000  THEN 'under 20M'
                    WHEN production_budget < 100000000 THEN '20M - 100M'
                    ELSE '100M and more'
                END                                                  AS budget_group,
                COUNT(*)                                             AS films,
                ROUND(AVG(production_budget))                        AS avg_budget,
                ROUND(AVG(COALESCE(domestic_box_office, 0)))         AS avg_domestic_box_office,      -- no domestic figure = no domestic release, counted as 0
                ROUND(AVG(COALESCE(international_box_office, 0)))    AS avg_international_box_office,
                ROUND(AVG(worldwide_box_office))                     AS avg_worldwide_box_office
            FROM sales
            WHERE production_budget > 0          -- only films that have a budget...
              AND worldwide_box_office > 0       -- ...and a worldwide box office
            GROUP BY budget_group
            ORDER BY MIN(production_budget);     -- show the groups from cheapest to most expensive
        """
        return self.run_query(sql)               

#H2
    def theatres_vs_box_office(self):
        sql = """
            SELECT
                CASE
                    WHEN theatre_count < 100  THEN 'under 100'
                    WHEN theatre_count < 600  THEN '100 - 599'
                    WHEN theatre_count < 2000 THEN '600 - 1999'
                    ELSE '2000 and more'
                END                                                                       AS opening_theatres,
                COUNT(*)                                                                  AS films,
                ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY worldwide_box_office)::numeric) AS median_worldwide_box_office
            FROM sales
            WHERE theatre_count > 0              -- only films with an opening theatre count...
              AND worldwide_box_office > 0       -- ...and a worldwide box office
            GROUP BY opening_theatres
            ORDER BY MIN(theatre_count);         -- smallest openings first
        """
        return self.run_query(sql)

#H3
    def genre_ranking(self):
        sql = """
            SELECT
                g.genre_name                                                              AS genre,
                COUNT(*)                                                                  AS films,
                ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.worldwide_box_office)::numeric) AS median_worldwide_box_office
            FROM sales s
            JOIN movie m              ON m.id_movie = s.id_movie   -- movie: needed to keep only Metacritic films
            JOIN bridge_movie_genre b ON b.id_movie = s.id_movie   -- bridge: which genres each film has
            JOIN genre g              ON g.id_genre = b.id_genre   -- genre: the genre names
            WHERE s.worldwide_box_office > 0                       -- only films with a worldwide box office
              AND m.metascore IS NOT NULL                          -- only Metacritic films
            GROUP BY g.genre_name
            HAVING COUNT(*) >= 50                                  -- leave out tiny genres (e.g. News: 13 films)
            ORDER BY median_worldwide_box_office DESC;             -- highest median first
        """
        return self.run_query(sql)

    def broad_vs_niche_genres(self):
        sql = """
            SELECT
                g.genre_name                                                              AS genre,
                CASE WHEN g.genre_name IN ('Documentary', 'Drama') THEN 'niche'
                     ELSE 'broad' END                                                     AS predicted,
                COUNT(*)                                                                  AS films,
                ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.worldwide_box_office)::numeric) AS median_worldwide_box_office
            FROM sales s
            JOIN movie m              ON m.id_movie = s.id_movie
            JOIN bridge_movie_genre b ON b.id_movie = s.id_movie
            JOIN genre g              ON g.id_genre = b.id_genre
            WHERE s.worldwide_box_office > 0
              AND m.metascore IS NOT NULL
              AND g.genre_name IN ('Action', 'Adventure', 'Animation', 'Sci-Fi', 'Fantasy', 'Family',
                                   'Documentary', 'Drama')         -- only the 8 genres named in H3
            GROUP BY g.genre_name
            ORDER BY median_worldwide_box_office DESC;
        """
        return self.run_query(sql)

#H4
    def rating_vs_box_office(self):
        sql = """
            SELECT
                CASE
                    WHEN r.rating_code IN ('G', 'PG')  THEN 'G and PG'
                    WHEN r.rating_code = 'PG13'        THEN 'PG-13'
                    ELSE 'R and NC-17'
                END                                                                       AS rating_group,
                COUNT(*)                                                                  AS films,
                ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.worldwide_box_office)::numeric) AS median_worldwide_box_office
            FROM sales s
            JOIN movie m  ON m.id_movie  = s.id_movie                -- movie: links each sales record to its film
            JOIN rating r ON r.id_rating = m.id_rating               -- rating: the film's age rating
            WHERE s.worldwide_box_office > 0                         -- only films with a worldwide box office
              AND r.rating_code IN ('G', 'PG', 'PG13', 'R', 'NC17')  -- only the five ratings named in H4
            GROUP BY rating_group
            ORDER BY rating_group;                                   -- least to most restrictive
        """
        return self.run_query(sql)

#H5
    def reviews_vs_box_office(self):
        sql = """
            WITH review_counts AS (                                   -- step 1: count the reviews of every film
                SELECT
                    id_movie,
                    COUNT(*) AS reviews                               -- one row per review, so COUNT = number of reviews
                FROM (
                    SELECT id_movie FROM bridge_movie_expert_review   -- every expert review, with its film
                    UNION ALL                                         -- UNION ALL keeps every row (no duplicates removed)
                    SELECT id_movie FROM bridge_movie_user_review     -- every user review, with its film
                ) AS all_reviews
                GROUP BY id_movie
            )
            SELECT                                                    -- step 2: compare review-volume groups
                CASE
                    WHEN rc.reviews < 25  THEN 'under 25'
                    WHEN rc.reviews < 50  THEN '25 - 49'
                    WHEN rc.reviews < 100 THEN '50 - 99'
                    ELSE '100 and more'
                END                                                                       AS review_volume,
                COUNT(*)                                                                  AS films,
                ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.worldwide_box_office)::numeric) AS median_worldwide_box_office
            FROM sales s
            JOIN review_counts rc ON rc.id_movie = s.id_movie         -- keeps only films that have reviews
            WHERE s.worldwide_box_office > 0                          -- only films with a worldwide box office
            GROUP BY review_volume
            ORDER BY MIN(rc.reviews);                                 -- fewest reviews first
        """
        return self.run_query(sql)

#H6
    def review_tone_vs_box_office(self):
        sql = """
            WITH sales AS (
                SELECT id_movie,
                       MAX(worldwide_box_office) AS ww,
                       MAX(production_budget)    AS budget,
                       MAX(theatre_count)        AS theatres
                FROM sales
                GROUP BY id_movie
                HAVING COUNT(DISTINCT id_sales) = 1
            ),
            films AS (
                SELECT m.id_movie, m.release_date::date AS release_date, s.ww
                FROM movie m
                JOIN sales s ON s.id_movie = m.id_movie
                WHERE s.ww > 0 AND m.release_date IS NOT NULL AND m.metascore IS NOT NULL
                  AND s.budget IS NOT NULL AND s.theatres IS NOT NULL AND m.id_rating IS NOT NULL
            ),
            expert_tone AS (
                SELECT r.id_movie, AVG(l.tone) AS tone
                FROM (SELECT DISTINCT f.id_movie, e.id_expert_review, e.id_liwc
                      FROM films f
                      JOIN bridge_movie_expert_review be ON be.id_movie = f.id_movie
                      JOIN expert_review e               ON e.id_expert_review = be.id_expert_review) r
                JOIN liwc_score l ON l.id_liwc = r.id_liwc
                WHERE l.wc > 0
                GROUP BY r.id_movie
            ),
            user_tone AS (
                SELECT r.id_movie, AVG(l.tone) AS tone
                FROM (SELECT DISTINCT f.id_movie, u.id_user_review, u.id_liwc
                      FROM films f
                      JOIN bridge_movie_user_review bu ON bu.id_movie = f.id_movie
                      JOIN user_review u               ON u.id_user_review = bu.id_user_review
                      WHERE u.review_date::date - f.release_date BETWEEN -30 AND 30) r
                JOIN liwc_score l ON l.id_liwc = r.id_liwc
                WHERE l.wc > 0
                GROUP BY r.id_movie
            ),
            long AS (
                SELECT '1. expert review tone (H6a)' AS review_type, t.tone::float8 AS tone, f.ww
                FROM films f JOIN expert_tone t ON t.id_movie = f.id_movie
                UNION ALL
                SELECT '2. user review tone (H6b)', t.tone::float8, f.ww
                FROM films f JOIN user_tone t ON t.id_movie = f.id_movie
            ),
            ranked AS (
                SELECT review_type, tone, ww,
                       RANK() OVER (PARTITION BY review_type ORDER BY tone)
                         + (COUNT(*) OVER (PARTITION BY review_type, tone) - 1) / 2.0 AS rank_tone,
                       RANK() OVER (PARTITION BY review_type ORDER BY ww)
                         + (COUNT(*) OVER (PARTITION BY review_type, ww) - 1) / 2.0   AS rank_ww
                FROM long
            )
            SELECT review_type,
                   COUNT(*)                                                     AS films,
                   ROUND(AVG(tone)::numeric, 1)                                 AS avg_tone,
                   ROUND(STDDEV_SAMP(tone)::numeric, 1)                         AS sd_tone,
                   ROUND(CORR(tone, LN(ww))::numeric, 3)                        AS pearson_r_log,
                   ROUND(CORR(rank_tone, rank_ww)::numeric, 3)                  AS spearman_rho,
                   ROUND((CORR(rank_tone, rank_ww)
                          * SQRT((COUNT(*) - 2) / (1 - CORR(rank_tone, rank_ww) ^ 2)))::numeric, 1) AS t_value
            FROM ranked
            GROUP BY review_type
            ORDER BY review_type;
        """
        return self.run_query(sql)

    def review_tone_groups(self):
        sql = """
            WITH sales AS (
                SELECT id_movie,
                       MAX(worldwide_box_office) AS ww,
                       MAX(production_budget)    AS budget,
                       MAX(theatre_count)        AS theatres
                FROM sales
                GROUP BY id_movie
                HAVING COUNT(DISTINCT id_sales) = 1
            ),
            films AS (
                SELECT m.id_movie, m.release_date::date AS release_date, s.ww
                FROM movie m
                JOIN sales s ON s.id_movie = m.id_movie
                WHERE s.ww > 0 AND m.release_date IS NOT NULL AND m.metascore IS NOT NULL
                  AND s.budget IS NOT NULL AND s.theatres IS NOT NULL AND m.id_rating IS NOT NULL
            ),
            expert_tone AS (
                SELECT r.id_movie, AVG(l.tone) AS tone
                FROM (SELECT DISTINCT f.id_movie, e.id_expert_review, e.id_liwc
                      FROM films f
                      JOIN bridge_movie_expert_review be ON be.id_movie = f.id_movie
                      JOIN expert_review e               ON e.id_expert_review = be.id_expert_review) r
                JOIN liwc_score l ON l.id_liwc = r.id_liwc
                WHERE l.wc > 0
                GROUP BY r.id_movie
            ),
            user_tone AS (
                SELECT r.id_movie, AVG(l.tone) AS tone
                FROM (SELECT DISTINCT f.id_movie, u.id_user_review, u.id_liwc
                      FROM films f
                      JOIN bridge_movie_user_review bu ON bu.id_movie = f.id_movie
                      JOIN user_review u               ON u.id_user_review = bu.id_user_review
                      WHERE u.review_date::date - f.release_date BETWEEN -30 AND 30) r
                JOIN liwc_score l ON l.id_liwc = r.id_liwc
                WHERE l.wc > 0
                GROUP BY r.id_movie
            ),
            long AS (
                SELECT 'expert review tone' AS review_type, t.tone, f.ww
                FROM films f JOIN expert_tone t ON t.id_movie = f.id_movie
                UNION ALL
                SELECT 'user review tone (±30 days)', t.tone, f.ww
                FROM films f JOIN user_tone t ON t.id_movie = f.id_movie
            ),
            grouped AS (
                SELECT review_type, ww,
                       CASE WHEN tone < 40 THEN 1 WHEN tone < 60 THEN 2 WHEN tone < 80 THEN 3 ELSE 4 END AS grp_order,
                       CASE WHEN tone < 40 THEN '1 negative (<40)'
                            WHEN tone < 60 THEN '2 neutral (40-59)'
                            WHEN tone < 80 THEN '3 positive (60-79)'
                            ELSE                '4 very positive (80+)' END                         AS tone_group
                FROM long
            )
            SELECT review_type,
                   tone_group,
                   COUNT(*)                                                                    AS films,
                   ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ww) / 1e6)::numeric, 1)   AS median_ww_musd,
                   ROUND((AVG(ww) / 1e6)::numeric, 1)                                           AS mean_ww_musd
            FROM grouped
            GROUP BY review_type, grp_order, tone_group
            ORDER BY review_type, grp_order;
        """
        return self.run_query(sql)
