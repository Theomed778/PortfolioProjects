# Data Cleaning

Select *
From layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove Any Columns

Create Table layoffs_staging
Like layoffs;

Select *
From layoffs_staging;

Insert layoffs_staging
Select *
From layoffs;

#assigning unique row number to find duplicates
Select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) As row_num
From layoffs_staging;

# finding duplicates
With duplicate_cte As
(
Select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) As row_num
From layoffs_staging
)
Select *
From Duplicate_cte
Where row_num > 1;


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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select *
From layoffs_staging2;

Insert Into layoffs_staging2
Select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) As row_num
From layoffs_staging;

Delete
From layoffs_staging2
Where row_num > 1;

Select *
From layoffs_staging2
Where row_num = 2;

-- Standardizing data

Select company, Trim(company)
From layoffs_staging2;

Update layoffs_staging2
Set company = Trim(company);

Select Distinct location
From layoffs_staging2;

Update layoffs_staging2
Set industry = 'Crypto'
Where industry Like 'Crypto%';

Select Distinct country, trim(Trailing '.' From country)
From layoffs_staging2
Order By 1;

Update layoffs_staging2
Set country = trim(Trailing '.' From country)
Where country Like 'United States%';

Select `date`
From layoffs_staging2
;

Update layoffs_staging2
Set `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER Table layoffs_staging2
Modify Column `date` DATE;

#Nulls
#have to set blank to null
UPDATE layoffs_staging2
SET industry = null
Where industry = ''
;

Select *
From layoffs_staging2
Where industry Is Null
OR industry = ''
;

Select *
From layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
Where (t1.industry Is Null Or t1.industry = '')
And t2.industry Is Not Null ;

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
Set t1.industry = t2.industry
Where ( t1.industry Is Null)
And t2.industry IS NOT NULL;

#Remove Columns and Rows

Select *
From layoffs_staging2
Where total_laid_off Is Null
And percentage_laid_off is Null;

DELETE
From layoffs_staging2
Where total_laid_off Is Null
And percentage_laid_off Is Null;

Alter Table layoffs_staging2
Drop Column row_num;

Select *
From layoffs_staging2;
