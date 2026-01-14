-- Project: SQL Layoffs Data Cleaning & EDA
-- Database: MySQL
-- Description: Exploratory Data Analysis on cleaned layoffs data
--              to identify trends by company, industry, country,
--              funding stage, and time.

-- =====================================================
-- Dataset Overview
-- =====================================================

SELECT * FROM layoffs_staging2 ;

-- =====================================================
-- Maximum layoffs and maximum layoff percentage
-- =====================================================

SELECT MAX(total_laid_off) ,MAX(percentage_laid_off) FROM layoffs_staging2 ;


-- =====================================================
-- Companies with 100% layoffs
-- =====================================================

SELECT * FROM layoffs_staging2 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC ;

-- =====================================================
-- Total layoffs by company
-- =====================================================

SELECT company, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC ;

-- =====================================================
-- Date range of the dataset
-- =====================================================

SELECT MIN(`date`) AS start_date ,
 MAX(`date`) AS end_date
 FROM layoffs_staging2 ;


-- =====================================================
-- Total layoffs by industry
-- =====================================================

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry ORDER BY 2 DESC ;


-- =====================================================
-- Total layoffs by country
-- =====================================================

SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country ORDER BY 2 DESC ;


-- =====================================================
-- Total layoffs by year
-- =====================================================

SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`) ORDER BY 1 DESC ;

-- =====================================================
-- Total layoffs by company stage
-- =====================================================

SELECT stage, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage ORDER BY 2 DESC ;

-- =====================================================
-- Monthly layoffs trend
-- =====================================================

SELECT SUBSTRING(`date` ,1 ,7 ) AS `MONTH` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1 ,7 ) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC ;


-- =====================================================
-- Rolling total of layoffs over time
-- =====================================================

WITH rolling_total AS
(SELECT SUBSTRING(`date` ,1 ,7 ) AS `MONTH` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1 ,7 ) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC )
SELECT `MONTH` ,total_off , SUM(total_off)
OVER(ORDER BY `MONTH`) AS rolling_t
FROM rolling_total ;

-- =====================================================
-- Top 5 companies by layoffs per year
-- =====================================================

WITH Company_year (company , years , total_laid_off) AS 
(SELECT company, YEAR(`date`) , SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company ,YEAR(`date`)
ORDER BY 3 DESC
) , company_year_rank AS
(SELECT * , DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_year
WHERE years IS NOT NULL) 
SELECT * FROM company_year_rank
WHERE ranking <= 5 ;
