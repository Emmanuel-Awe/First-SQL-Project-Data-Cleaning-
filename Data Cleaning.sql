/* Using the database where the table is stored */
USE project_1;

/* Code to check if the table was imported correctly */
SELECT * 
FROM layoffs;

/* Duplicating the raw data to another table */
CREATE TABLE layoffs_work
LIKE layoffs;

INSERT INTO layoffs_work
SELECT * 
FROM layoffs;

/* Code to check if the table was copied correctly */
SELECT * 
FROM layoffs_work;

-- Step 1 Check for duplicates

/* To check if there are any duplications */
SELECT * , ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS RowNumber
FROM layoffs_work;

/* We use a CTE due to the fact that WHERE clause cannnot be used with partition by*/
WITH Duplication_Check AS (
SELECT * , ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS RowNumber
FROM layoffs_work
)
SELECT * 
FROM Duplication_Check 
WHERE RowNumber > 1;

SELECT * 
FROM layoffs_work
WHERE company = 'HIbob';


CREATE TABLE `layoffs_work2` (
  `company`               text,
  `location`              text,
  `industry`              text,
  `total_laid_off`        int DEFAULT NULL,
  `percentage_laid_off`   text,
  `date`                  text,
  `stage`                 text,
  `country`               text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_Number`            INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* To check if the table was created correctly */
SELECT * 
FROM layoffs_work2;

/* To insert the relevant data into the new Table */
INSERT INTO layoffs_work2
SELECT * , ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS RowNumber
FROM layoffs_work;

/* Changing the column name to make it easier for me */
ALTER TABLE layoffs_work2 CHANGE `Row_Number` RowNumber INT;

SELECT * 
FROM layoffs_work2
WHERE RowNumber > 1;

/* To delete the duplicate rows */
DELETE FROM layoffs_work2
WHERE RowNumber > 1;

-- Step 2 Standardizing the data

/* Correcting the extra spaces left in the company column*/
SELECT company, TRIM(company)
FROM layoffs_work2;

/* Making sure that corrections for the extra spaces left in the company column is permanent*/
UPDATE layoffs_work2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_work2
ORDER BY industry;

/* Correcting all the wrong spellings of Crypto */
UPDATE layoffs_work2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country
FROM layoffs_work2
ORDER BY 1;

/* Removing all trailing '.' from the country column*/
UPDATE layoffs_work2
SET country = TRIM(TRAILING '.' FROM country);

/* Changing the date colomn from string to date format*/
SELECT `date` , STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_work2; 

UPDATE layoffs_work2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_work2
MODIFY COLUMN `date` DATE;


-- Step 3 Removing null or blank values

/* To check for null or empty spaces in the industry column*/
SELECT DISTINCT industry 
FROM layoffs_work2;

/* To check if similar industry rows have values in them */
SELECT st1.company, st1.location, st1.industry, st2.company, st2.location, st2.industry
FROM layoffs_work2 st1 JOIN layoffs_work2 st2
ON st1.company = st2.company
WHERE st1.industry IS NULL OR st1.industry = ''
AND st2.industry IS NOT NULL;

/* To make changing the values of the empty spaces in industry easier */
UPDATE layoffs_work2
SET industry = NULL
WHERE industry = "";

/* To fix the null spaces in the industry column */
UPDATE layoffs_work2 st1 JOIN layoffs_work2 st2
ON st1.company = st2.company
SET st1.industry = st2.industry
WHERE st1.industry IS NULL
AND st2.industry IS NOT NULL;

/* To delete all rows that have both total_laid_off and percentage_laid_off  as NULL*/
DELETE FROM layoffs_work2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL ;

 /*To drop the RowNumber column */
 ALTER TABLE layoffs_work2
 DROP RowNumber;
 
SELECT *
FROM layoffs_work2;

 















