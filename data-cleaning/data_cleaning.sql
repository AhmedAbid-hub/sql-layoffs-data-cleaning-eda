-- Project: SQL Layoffs Data Cleaning & EDA
-- Database: MySQL
-- Description: Data cleaning on layoffs dataset including
--              duplicate removal, standardization, NULL handling,
--              and row/column filtering.





-- Data Cleaning 
-- 1 Remvoing Duplicates 
-- 2 Standerdize the Data
-- 3 Null values or blank values 
-- 4 Remove any Column


-- Removing Duplicates

CREATE TABLE layoffs_staging
LIKE layoffs ;

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging 
SELECT * FROM layoffs ;




WITH duplicates_cte AS 
(
SELECT * ,
 ROW_NUMBER() OVER
(PARTITION BY company ,location , industry ,total_laid_off, percentage_laid_off ,`date` ,
 stage , country , funds_raised_millions) as row_num 
FROM layoffs_staging )
SELECT * FROM duplicates_cte
WHERE row_num > 1 ;





CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL ,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO layoffs_staging2 
SELECT * ,
 ROW_NUMBER() OVER
(PARTITION BY company ,location , industry ,total_laid_off, percentage_laid_off ,`date` ,
 stage , country , funds_raised_millions ORDER BY company) as row_num 
FROM layoffs_staging ;

DELETE FROM layoffs_staging2
WHERE row_num > 1 ;


-- Standerdizing Data


SELECT company ,TRIM(company) FROM layoffs_staging2 ;

UPDATE layoffs_staging2
SET company = TRIM(company) ;


SELECT DISTINCT industry FROM layoffs_staging2
ORDER BY 1 ;

SELECT * FROM layoffs_staging2
WHERE industry LIKE 'Crypto%' ;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' ;

SELECT DISTINCT country FROM layoffs_staging2
ORDER BY 1 ;
 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%' ;


SELECT `date` , str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_staging2 ;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y') ;

SELECT `date` FROM layoffs_staging2 ;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE ;

SELECT * FROM layoffs_staging2 ;


-- Null or Blank Values 


SELECT DISTINCT industry FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE industry is NULL OR
industry = '';

SELECT * FROM layoffs_staging2
WHERE company = 'airbnb';


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT * FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
ON t1.company = t2.company 
AND t1.location = t2.location 
	WHERE t1.industry IS NULL AND
    t2.industry IS NOT NULL ;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND
    t2.industry IS NOT NULL ;
    
SELECT * FROM layoffs_staging2 ;


-- Remove any Columns OR Rows



SELECT * FROM layoffs_staging2 
WHERE total_laid_off is NULL AND 
percentage_laid_off is NULL ;


DELETE FROM layoffs_staging2 
WHERE total_laid_off is NULL AND 
percentage_laid_off is NULL ;

ALTER TABLE layoffs_staging2 
DROP COLUMN row_num ;




