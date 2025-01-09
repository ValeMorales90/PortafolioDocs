CREATE TABLE water_table
(
	last_load Varchar(2000)
)

SELECT * FROM water_table

INSERT INTO water_table
VALUES ('DT00000')

SELECT min(Date_ID) FROM [dbo].[source_cars_data]
