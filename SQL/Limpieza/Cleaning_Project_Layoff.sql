-- Proyecto Limpieza de datos | Data Cleaning Project

SELECT *
FROM portafolio.layoffs;

-- Crearemos una copia de tabla de trabajo, donde trabajaremos los datos limpios. La tabla actual se quedará como back-up
-- We will create a copy of the actual table, that way we can work with clean data. The old table will be our back-up table.

CREATE TABLE portafolio.layoffs_staging 
LIKE portafolio.layoffs;

INSERT portafolio.layoffs_staging 
SELECT * FROM portafolio.layoffs;

SELECT *
FROM portafolio.layoffs_staging;


-- Con nuestra tabla realizaremos los siguientes procedimientos | Now we will do the following steps:
-- 1. Chequear si hay duplicados y eliminarlos | Check for duplicates and remove any (no ID)
-- 2. Estandarizar datos y arreglar errores | Standardize data and fix errors
-- 3. Buscar campos vacios y ver si es posible poblar | Look at null values and see what we can do
-- 4. Eliminar columnas que nos sean necesarias | Remove any columns and rows that are not necessary 

-- 1. Eliminar duplicados | Remove Duplicates
SELECT *
FROM portafolio.layoffs_staging;
--
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM portafolio.layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM portafolio.layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- Testeamos a Casper para confirmar | Test Casper to confirm
SELECT *
FROM portafolio.layoffs_staging
WHERE company = 'Casper';

-- Hay 3 registros de los cuales 2 son duplicados | There are 3 entries, 2 out of them are duplicates
-- Agregaremos una columna de row number, luego crearemos una nueva tabla y eliminaremos registros de row number > 2

ALTER TABLE portafolio.layoffs_staging 
ADD row_num INT;

SELECT *
FROM portafolio.layoffs_staging;

CREATE TABLE `portafolio`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

SELECT *
FROM portafolio.layoffs_staging2;

INSERT INTO `portafolio`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		portafolio.layoffs_staging;

-- Revisamos los datos | We check data
SELECT *
FROM portafolio.layoffs_staging2
WHERE row_num > 1;

-- Revisamos nuevamente a Casper | We check Casper again
SELECT *
FROM portafolio.layoffs_staging2
WHERE row_num > 1 AND company = 'Casper';

-- Ahora eliminamos los registros mayores a 1

DELETE 
FROM portafolio.layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM portafolio.layoffs_staging2;

-- Ahora podemos eliminar la column de row num que ya no necesitamos | Now we delete the row num column we dont need anymore

ALTER TABLE portafolio.layoffs_staging2
DROP COLUMN row_num;

-- 2. Estandarizar datos y arreglar errores | Standardize data and fix errors

SELECT *
FROM portafolio.layoffs_staging2;

-- Buscamos espacios iniciales, NULLs y columnas vacias | We search for spaces at the beginning, nulls and empty rows
-- Espacios inciales (company):
SELECT DISTINCT(company)
FROM portafolio.layoffs_staging2;

SELECT company, TRIM(company)
FROM portafolio.layoffs_staging2;

UPDATE portafolio.layoffs_staging2
SET company = TRIM(company);

-- Industry:
SELECT DISTINCT(industry)
FROM portafolio.layoffs_staging2
ORDER BY industry ASC;

-- Estandarizar nombre de industria | Standarize industry name (Crypto, Crypto Currency)

SELECT *
FROM portafolio.layoffs_staging2
WHERE industry LIKE '%Crypto%';

UPDATE portafolio.layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';


-- Arreglar registro con un punto al final (United States.) | Fix an entry with a dot at the end 

SELECT distinct country
FROM portafolio.layoffs_staging2
ORDER BY 1;

SELECT distinct country
FROM portafolio.layoffs_staging2
WHERE country LIKE 'United States%';

SELECT distinct country, TRIM(TRAILING '.' FROM country)
FROM portafolio.layoffs_staging2
ORDER BY 1;

UPDATE portafolio.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Ahora revisaremos los formatos de las columnas (columna date que aparece como text, sin formato de fecha) 
-- We will look into column format (date appears as text, doesn't have a date format )

SELECT `date`
FROM portafolio.layoffs_staging2;

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM portafolio.layoffs_staging2;

UPDATE portafolio.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modificaremos el formato de la columna | We will modify the date column to date format

SELECT *
FROM portafolio.layoffs_staging2;

ALTER TABLE portafolio.layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Valores NULL: No se encuentra el tamaño de la empresa para poder calcular porcentaje de despido, ni tampoco se puede calcular fund_raised_millions. Quedan NULL
-- Null values: We don't have enough data, like size of the company to calculate perc laid off. Also we cant calculate fund_raised_millions. They stay NULL.

-- Revisamos columnas que no entregan valor, por ejemplo no tienen datos de laid off ni porcentaje ni fondos (eliminamos a final)
-- We check columns that dont provide value like null in total laid off, percentage laid off or funds (We delete at the end)

SELECT *
FROM portafolio.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
-- Revisamos algunos valores que podemos llenar en base a la informacion disponible 
-- We check values that we can populate with the information we have available

SELECT *
FROM portafolio.layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Llenamos tipo de industria para Airbnb (ya contiene registro para Travel)

SELECT *
FROM portafolio.layoffs_staging2
WHERE company LIKE 'Airbnb';

-- Generamos una estructura inicial antes de modificar

SELECT t1.industry, t2.industry
FROM portafolio.layoffs_staging2 t1
JOIN portafolio.layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;

-- No genera el update, se intentará cambiar los valores '' a null y poblar | Doesn't update, we will change '' value to null and populate

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;

SELECT *
FROM portafolio.layoffs_staging2
WHERE industry IS NULL;

-- El caso de Bally's no tiene homologacion para ingresar informacion y queda NULL | Bally's is the only entry without a pairing to populate

-- Volvemos a las columnas sin valor | We go back to the useless columns 
SELECT *
FROM portafolio.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE FROM portafolio.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM portafolio.layoffs_staging2;

SELECT *
FROM portafolio.layoffs_staging2
WHERE total_laid_off IS NULL
OR percentage_laid_off IS NULL
;

DELETE FROM portafolio.layoffs_staging2
WHERE total_laid_off IS NULL
OR percentage_laid_off IS NULL;

SELECT *
FROM portafolio.layoffs_staging2;