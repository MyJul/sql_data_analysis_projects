-- Data Cleaning
-- First step was importing the layoffs.csv file from  and just generally reviewing the table

SELECT *
FROM layoffs;

-- Cleaning process
-- 1. Remove Duplicates
-- 2. Standardize Data
-- 3. Null Values/Blank Values
-- 4. Remove unnecessary columns or rows

-- As a good practice, create a staging table to clean the data.  Creating a staging table allows you to retain the original data just in case

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Step 1 - Remove Dupes

-- Checking for dupes in all columns 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Verifying row is in fact a dupe
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Identify the exact dupes and deleting
-- Approach will be to create another staging table to delete dupes

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- delete rows where row_num is greater than 1 - identifying a dupe

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Verifying rows were deleted

SELECT *
FROM layoffs_staging2;

-- Step 2 - Standardizing Data

-- Removing white spaces

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- there are multiple crypto; fintech & finance(?)

-- Make all variations 'Crypto'

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE '%crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%crypto%';

-- Check country for dupes and clean

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
-- removed trailing characters which fixed all columns to say "United States" 

-- change the data type of the date column to date and update the table
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 3 - Remove Null Values/Blanks

-- check for Nulls in columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry is NULL
OR industry =  '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Use a self join to check if rows with same company name are null, and if so, replace the null with the correct industry

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL; 

-- verify this updated correctly

SELECT *
FROM layoffs_staging2
WHERE industry is NULL
OR industry =  '';

-- Step 4 - remove unnecessary columns
-- Approach - revisit the goal - goal for data in the future is not solely to identify companies that had layoffs

-- checking for null calues in total_laid_off and percentage_laid_off where there seem to be remaining null values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- these companies have no data at all so can be deleted(?); question of should we delete; for purposes of this project we will delete

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- verify this change

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;