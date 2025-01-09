CREATE PROCEDURE UpdateWatermarkTable
    @lastload VARCHAR(200)
AS
BEGIN
	BEGIN TRANSACTION;
    UPDATE water_table
    SET last_load = @lastload
	COMMIT TRANSACTION;
END;