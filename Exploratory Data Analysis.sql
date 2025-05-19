-- Exploratory Data Analysis (EDA)

SELECT *
FROM layoffs_staging2;

-- Let's look at the Max laid off and MAX percentage

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- percentage of 1 means the entire company was laid off, ie. company went out of business

-- Let's see all the companies that went out of business
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Let's see how much money was raised by the companies that ultimately went out of business
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Let's see how many people total each company laid off over the years in the data set
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- point out the beginning and end dates of the data set
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- What was going on between 2020 & 2023 (MIN/MAX dates)?  Covid 

-- What industries had the most layoffs? Get this my summing the total and sorting by descending order
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- which country saw the most layoffs? The US :(
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- which years saw the most layoffs? 2023 and 2022 *Note only 3 months of data are from 2023 in the dataset (first 3)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- companies in which stage had most layoffs? Post IPO
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- this didn't tell us much - not helpful
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- layoffs by month

SELECT SUBSTRING(`date`, 6,2) as 'Month', SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `Month`;

	-- not that this is not showing the year

-- rolling total of layoffs based on month

SELECT SUBSTRING(`date`, 1,7) as 'Month', SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;
	-- this is the sum of layoffs each month, year

-- rolling total of layoffs by month - worldwide

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1,7) as 'Month', SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off, SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;



SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Let's look at total layoffs by company and year ranked
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- Look at the top 5 ranked total layoffs per year by company

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;


-- What industries had the most layoffs? Get this my summing the total and sorting by descending order
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Let's look at total layoffs by industy and year ranked
WITH Industry_Year (company, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- Look at the top 5 ranked total layoffs per year by industry

WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE Ranking <=5;

-- just checking what consumer companies were considered consumer or other
SELECT *
FROM layoffs_staging2
WHERE company = 'Google';
	-- Consumer
    
SELECT *
FROM layoffs_staging2
WHERE company = 'Meta';
	-- Consumer

SELECT *
FROM layoffs_staging2
WHERE industry = 'Other';

-- interesting Note that Microsoft, Ericsson, Sap & Zoom are labeled 'Other' in the data set