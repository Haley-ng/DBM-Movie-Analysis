DROP TABLE IF EXISTS 
	award, 						--1
	character, 					--2
	--creative_type, 				--3 Dropped
	director, 					--4
	rating, 					--5
	studio, 					--6
	genre, 						--7
	keyword, 					--8
	movie, 						--9
	financials,					--10
	liwc_score, 				--11
	expert_review,				--12
	user_review,				--13
	bridge_movie_award,			--14
	bridge_movie_director,		--15
	bridge_genre_movie,			--16
	bridge_movie_character,		--17
	bridge_movie_expert_review,	--18
	bridge_movie_user_review,	--19
	bridge_movie_studio,		--20
	bridge_movie_keyword		--21
CASCADE;                  		


-- 1 - create awards tbl
CREATE TABLE award (
    id_award INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 	-- id award is INTEGER, primary key, auto increment
    award_name VARCHAR(255)
);

-- 2 - create character tbl
CREATE TABLE character (
  id_character INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 	-- id character is INTEGER, primary key, auto increment
  character_name VARCHAR(100)
  -- character_lastname VARCHAR(100) -- Deleted first name and last name, only use full name
); 

-- This creative_type table is deleted
-- 3 - create creative_type tbl
--CREATE TABLE creative_type (
  --id_creative_type INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  --creative_type VARCHAR(100) 
--);

-- 4 - create director tbl
CREATE TABLE director (
  id_director INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  director_name VARCHAR(100)
  -- director_lastname VARCHAR(100) -- Deleted first name and last name, only use full name
);

-- 5 - create rating tbl
CREATE TABLE rating (
  id_rating INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  rating_code VARCHAR(50),
  rating_name VARCHAR(100) 
); 

-- 6 - create studio tbl
CREATE TABLE studio (
  id_studio INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  studio_name VARCHAR(100) 
);

-- 7 - create genre tbl
CREATE TABLE genre (
  id_genre INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  genre_name VARCHAR(100) 
); 

-- 8 - create keyword tbl
CREATE TABLE keyword (
  id_keyword INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  keyword VARCHAR(100) 
);

-- 9 - create movie tbl
CREATE TABLE movie (
  id_movie INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_rating INTEGER NOT NULL,
  id_creative_type INTEGER NOT NULL,
  title VARCHAR(100),
  runtime DECIMAL(5,2),
  summary VARCHAR(500),
  release_date DATE,
  theatre_count INTEGER,
  user_score DECIMAL(5,2),
  meta_score DECIMAL(5,2),
  creative_type VARCHAR(100), -- put creative_type directly into this table
  url VARCHAR(255), 		  -- put url colmn directly here

  CONSTRAINT fk_movie_rating					-- create id rating as FK 
  	FOREIGN KEY (id_rating) 
	REFERENCES rating (id_rating)
	
  --CONSTRAINT fk_movie_creative_type				-- Table is delected
	--FOREIGN KEY (id_creative_type) 
	--REFERENCES creative_type (id_creative_type)
	
);
CREATE INDEX idx_movie_id_rating					-- Create an index called fk_movie_rating to make searches involving movie.id_rating faster. Without an index,SQL need to check many rows. lookup structure
ON movie (id_rating);

CREATE INDEX idx_movie_id_creative_type				-- Create an index called fk_movie_creative type to make searches involving movie.id_rating faster.
ON movie (id_creative_type);

-- 10 - create financials tbl
CREATE TABLE financials (
  id_fin INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_movie INTEGER NOT NULL,
  production_budget DECIMAL(15,2),
  domestic_box_office DECIMAL(15,2),
  international_box_office DECIMAL(15,2),
  worldwide_box_office DECIMAL(15,2),
  opening_weekend DECIMAL(15,2),

  CONSTRAINT fk_financials_movie
        FOREIGN KEY (id_movie)
        REFERENCES movie (id_movie)

);
CREATE INDEX idx_financials_id_movie
ON financials (id_movie);

-- 11 - create liwc_score tbl
CREATE TABLE liwc_score (
  	id_liwc INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  	wc			DECIMAL(10,2),
	analytic	DECIMAL(10,2),
	clout		DECIMAL(10,2),
	authentic	DECIMAL(10,2),
	tone		DECIMAL(10,2),
	wps			DECIMAL(10,2),
	sixltr		DECIMAL(10,2),
	dic			DECIMAL(10,2),
	function_score	DECIMAL(10,2),
	pronoun		DECIMAL(10,2),
	ppron		DECIMAL(10,2),
	i			DECIMAL(10,2),
	we			DECIMAL(10,2),
	you			DECIMAL(10,2),
	shehe		DECIMAL(10,2),
	they		DECIMAL(10,2),
	ipron		DECIMAL(10,2),
	article		DECIMAL(10,2),
	prep		DECIMAL(10,2),
	auxverb		DECIMAL(10,2),
	adverb		DECIMAL(10,2),
	conj		DECIMAL(10,2),
	negate		DECIMAL(10,2),
	verb		DECIMAL(10,2),
	adj			DECIMAL(10,2),
	compare		DECIMAL(10,2),
	interrog	DECIMAL(10,2),
	number_score	DECIMAL(10,2),
	quant	DECIMAL(10,2),
	affect	DECIMAL(10,2),
	posemo	DECIMAL(10,2),
	negemo	DECIMAL(10,2),
	anx		DECIMAL(10,2),
	anger	DECIMAL(10,2),
	sad		DECIMAL(10,2),
	social	DECIMAL(10,2),
	family_score	DECIMAL(10,2),
	friend	DECIMAL(10,2),
	female	DECIMAL(10,2),
	male	DECIMAL(10,2),
	cogproc	DECIMAL(10,2),
	insight	DECIMAL(10,2),
	cause	DECIMAL(10,2),
	discrep	DECIMAL(10,2),
	tentat	DECIMAL(10,2),
	certain	DECIMAL(10,2),
	differ	DECIMAL(10,2),
	percept	DECIMAL(10,2),
	see		DECIMAL(10,2),
	hear	DECIMAL(10,2),
	feel	DECIMAL(10,2),
	bio		DECIMAL(10,2),
	body	DECIMAL(10,2),
	health	DECIMAL(10,2),
	sexual	DECIMAL(10,2),
	ingest	DECIMAL(10,2),
	drives	DECIMAL(10,2),
	affiliation	DECIMAL(10,2),
	achieve	DECIMAL(10,2),
	power_score	DECIMAL(10,2),
	reward	DECIMAL(10,2),
	risk	DECIMAL(10,2),
	focuspast	DECIMAL(10,2),
	focuspresent	DECIMAL(10,2),
	focusfuture	DECIMAL(10,2),
	relativ	DECIMAL(10,2),
	motion	DECIMAL(10,2),
	space_score	DECIMAL(10,2),
	time_score	DECIMAL(10,2),
	work_score	DECIMAL(10,2),
	leisure	DECIMAL(10,2),
	home	DECIMAL(10,2),
	money_score	DECIMAL(10,2),
	relig	DECIMAL(10,2),
	death	DECIMAL(10,2),
	informal	DECIMAL(10,2),
	swear	DECIMAL(10,2),
	netspeak	DECIMAL(10,2),
	assent	DECIMAL(10,2),
	nonflu	DECIMAL(10,2),
	filler	DECIMAL(10,2),
	allpunc	DECIMAL(10,2),
	period_score	DECIMAL(10,2),
	comma	DECIMAL(10,2),
	Colon	DECIMAL(10,2),
	semiC	DECIMAL(10,2),
	qMark	DECIMAL(10,2),
	exclam	DECIMAL(10,2),
	dash	DECIMAL(10,2),
	quote_score	DECIMAL(10,2),
	apostro	DECIMAL(10,2),
	parenth	DECIMAL(10,2),
	otherP	DECIMAL(10,2)
);
  

-- 12 - create expert_review tbl
CREATE TABLE expert_review (
  id_expert_review INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_liwc INTEGER NOT NULL,
  expert_firstname VARCHAR(100),
  expert_lastname VARCHAR(100),
  review_date DATE,
  idv_score DECIMAL(5,2),
  review_text VARCHAR(255),
  url VARCHAR(255),

  CONSTRAINT fk_expert_review_liwc
  	FOREIGN KEY (id_liwc) 
	REFERENCES liwc_score (id_liwc)
); 
CREATE INDEX idx_expert_review_id_liwc			
ON expert_review (id_liwc);


-- 13 - create user_review tbl
CREATE TABLE user_review (
  id_user_review INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_liwc INTEGER NOT NULL,
  user_firstname VARCHAR(100) ,
  user_lastname VARCHAR(100) ,
  review_date DATE ,
  idv_score DECIMAL(5,2) ,
  thumbs_up DECIMAL(5,2) ,
  thumbs_total DECIMAL(5,2) ,
  review_text VARCHAR(255) ,
  url VARCHAR(255),

  CONSTRAINT fk_user_review_liwc
  	FOREIGN KEY (id_liwc) 
	REFERENCES liwc_score (id_liwc)
); 
CREATE INDEX idx_user_review_id_liwc				
ON user_review (id_liwc);



-- 14 - create bridge_award_movie tbl
CREATE TABLE bridge_movie_award (
  id_movie INTEGER NOT NULL,
  id_award INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_award),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_award_movie 
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_award_award
        FOREIGN KEY (id_award) 
        REFERENCES award (id_award) 
        ON DELETE CASCADE
);

-- 15 - create bridge_director_movie tbl
CREATE TABLE bridge_movie_director (
  id_movie INTEGER NOT NULL,
  id_director INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_director),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_director_movie 
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_director_director
        FOREIGN KEY (id_director)
        REFERENCES director(id_director) 
        ON DELETE CASCADE
);

-- 16 - create bridge_genre_movie tbl
CREATE TABLE bridge_genre_movie (
  id_movie INTEGER NOT NULL,
  id_genre INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_genre),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_genre_movie_movie
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_genre_movie_genre 
        FOREIGN KEY (id_genre) 
        REFERENCES genre(id_genre) 
        ON DELETE CASCADE
);

-- 17 - create bridge_movie_character tbl
CREATE TABLE bridge_movie_character (
  id_movie INTEGER NOT NULL,
  id_character INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_character),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_character_movie
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_character_character
        FOREIGN KEY (id_character) 
        REFERENCES character (id_character) 
        ON DELETE CASCADE
);

-- 18 - create bridge_movie_expert_review tbl
CREATE TABLE bridge_movie_expert_review (
  id_movie INTEGER NOT NULL,
  id_expert_review INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_expert_review),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_expert_review_movie 
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_expert_review_review
        FOREIGN KEY (id_expert_review) 
        REFERENCES expert_review (id_expert_review) 
        ON DELETE CASCADE
);

-- 19 - create bridge_movie_user_review tbl
CREATE TABLE bridge_movie_user_review (
  id_movie INTEGER NOT NULL,
  id_user_review INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_user_review),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_user_review_movie
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_user_review_review
        FOREIGN KEY (id_user_review) 
        REFERENCES user_review (id_user_review) 
        ON DELETE CASCADE
);

-- 20 - create bridge_movie_studio tbl
CREATE TABLE bridge_movie_studio (
  id_movie INTEGER NOT NULL,
  id_studio INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_studio),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_studio_movie
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_studio_studio
        FOREIGN KEY (id_studio) 
        REFERENCES studio (id_studio) 
        ON DELETE CASCADE
);

-- 21 - create bridge_movie_keyword tbl
CREATE TABLE bridge_movie_keyword (
  id_movie INTEGER NOT NULL,
  id_keyword INTEGER NOT NULL,
  
  -- Define the Composite Primary Key (prevents duplicate pairs)
  PRIMARY KEY (id_movie, id_keyword),
    
  -- Define Foreign Key Constraints with Cascade Delete, preventing orphaned data records.
  CONSTRAINT fk_bridge_movie_keyword_movie
        FOREIGN KEY (id_movie) 
        REFERENCES movie(id_movie) 
        ON DELETE CASCADE,
        
  CONSTRAINT fk_bridge_movie_keyword_keyword
        FOREIGN KEY (id_keyword) 
        REFERENCES keyword (id_keyword) 
        ON DELETE CASCADE
);


-- 27 characters VARCHAR(50)
-- 60 characters VARCHAR(100)
-- 44 charactersVARCHAR(100)
-- ~90+ charactersVARCHAR(255)
