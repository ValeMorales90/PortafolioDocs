-- Exploracion de analisis de datos
SELECT *
FROM layoffs_staging2;

-- Evaluamos el valor maximo de despidos en un fecha
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- Identificamos la o las empresas que desaparecieron, con los maximos % 1 o 100%)
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Identificamos la o las empresas que desaparecieron, con los maximos % 1 o 100% ordenados DESC por  fondos recaudados)
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Identificamos las empresas con mas suma de despidos en total
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company
ORDER BY 2 DESC;

-- Identificamos las industrias con mas suma de despidos en total
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  industry
ORDER BY 2 DESC;

-- Identificamos las paises con mas suma de despidos en total
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  country
ORDER BY 2 DESC;

-- Identificamos los años con mas suma de despidos en total
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Identificamos despidos en meses de cada año
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC;

-- Elaboramos un total acumulado para identificar la progresion y grandes cambios en el tiempo (CTE)
WITH total_acumulado AS 
(SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC)

SELECT dates, total_laid_off, SUM(total_laid_off) OVER(ORDER BY dates) AS total_acumulado
FROM total_acumulado;

-- Elaboramos un ranking de despidos por empresa basado en fecha y total acumulado
WITH Company_Year (Company, `Year`, Total_Off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS(
SELECT *, DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY Total_Off DESC) AS Ranking
FROM Company_Year
WHERE `Year` IS NOT NULL
ORDER BY Ranking ASC)
SELECT *
FROM Company_Year_Rank 
WHERE Ranking < 5
;





