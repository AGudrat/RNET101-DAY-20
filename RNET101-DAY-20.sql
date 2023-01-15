--Parametre olarak verilen doğum tarihi ve yaş değerlerini alarak kişi belirtilen yaşı Yıl - Ay veya Gün olarak doldurup doldurmadığını geri dönen Function.
create or ALTER FUNCTION AgeCalculator(@birthDate DateTime, @age int)
RETURNS nvarchar(max)
BEGIN
	DECLARE @message nvarchar(max);
	SET @message = IIF((YEAR(GETDATE()) - YEAR(@birthDate)) = @age, 
						IIF((MONTH(GETDATE()) - MONTH(@birthDate)) < 0 ,
								IIF((DAY(GETDATE()) - DAY(@birthDate)) > 0, 
										CONCAT('İl və ay olaraq yaşını tamamlayıb. Gün olaraq ', DAY(@birthDate)  - DAY(GETDATE()),' gün qalıb.'),
										'İl, ay, gün olaraq yaşını tamamlayıb'
										),
								IIF((MONTH(GETDATE()) - MONTH(@birthDate)) > 0,
									CONCAT('İl olaraq yaşını tamamlayıb. Ay ve gün olaraq ', MONTH(@birthDate)  - MONTH(GETDATE()), ' ay, ',DAY(@birthDate)  - DAY(GETDATE()),' gün qalıb.'),
									IIF((DAY(GETDATE()) - DAY(@birthDate)) < 0, 
										CONCAT('İl və ay olaraq yaşını tamamlayıb. Gün olaraq ', DAY(@birthDate)  - DAY(GETDATE()),' gün qalıb.'),
										'İl, ay, gün olaraq yaşını tamamlayıb'
										)
									)
							),
						IIF((YEAR(GETDATE()) - YEAR(@birthDate)) < @age,
							CONCAT('Yaşını tamamlamasına ' , @age - (YEAR(GETDATE()) - YEAR(@birthDate)) , ' il, ', MONTH(@birthDate)  - MONTH(GETDATE()) , ' ay ' , DAY(@birthDate)  - DAY(GETDATE()),' gün qalıb.'),
							'İl, ay, gün olaraq yaşını tamamlayıb')
							) 
				
	return @message
END
			
SELECT  dbo.AgeCalculator('01-20-2002',19) AS Information

select MONTH(GETDATE()) - MONTH('01-20-2002')



-- Ikinci task

CREATE DATABASE Odev

use Odev

CREATE TABLE Country(
	Id INT IDENTITY(1,1)  PRIMARY KEY NOT NULL,
	CountryName nvarchar(100) NOT NULL,
	Code int NOT NULL,
)

CREATE TABLE City(
	Id INT IDENTITY(1,1)  PRIMARY KEY NOT NULL,
	CityName nvarchar(100) NOT NULL,
	CountryId int FOREIGN KEY REFERENCES Country(Id) NOT NULL
)

CREATE TABLE District(
	Id INT IDENTITY(1,1)  PRIMARY KEY NOT NULL,
	DistrictName nvarchar(100) NOT NULL,
	CountryId int FOREIGN KEY REFERENCES Country(Id) NOT NULL,
	CityId int FOREIGN KEY REFERENCES City(Id) NOT NULL,
	Code int NOT NULL,
)
CREATE TABLE Town(
	Id INT IDENTITY(1,1)  PRIMARY KEY NOT NULL,
	TownName nvarchar(100) NOT NULL,
	CountryId int FOREIGN KEY REFERENCES Country(Id) NOT NULL,
	CityId int FOREIGN KEY REFERENCES City(Id) NOT NULL,
	DistrictId int FOREIGN KEY REFERENCES District(Id) NOT NULL,
	Code int NOT NULL,
)

CREATE or ALTER PROC sp_StoreProcedure 
    @countryName	NVARCHAR(100),
    @cityName		NVARCHAR(100),
    @districtName   NVARCHAR(100),
    @townName		NVARCHAR(100)
AS
DECLARE @countryId int, @cityId int , @districtId int
IF EXISTS (SELECT * FROM Country as C WHERE C.CountryName = @countryName)
    BEGIN
		SET @countryId = (SELECT Id from Country as C WHERE C.CountryName = @countryName)
		IF EXISTS(SELECT * FROM City as CT WHERE CT.CityName = @cityName)
			BEGIN
				SET @cityId  = (SELECT Id from City as CT WHERE CT.CityName = @cityName)
					print 'Country added!'
				IF EXISTS (SELECT * FROM District as D WHERE D.DistrictName = @districtName)
					BEGIN
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
						UPDATE District SET [CountryId] =  @countryId, [CityId] = @cityId WHERE District.DistrictName = @districtName
						print 'District updated!'
						IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
							print 'Complated!'
						ELSE
							BEGIN
								INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
								print 'Town added'
							END
					END
				ELSE
					BEGIN
						INSERT INTO District values (@districtName,@countryId,@cityId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
							IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
								print 'Country, City, District and Town is exists'
							ELSE
								INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
					END
			END


		ELSE 
			BEGIN
				INSERT INTO City values (@cityName,@countryId)
				SET @cityId  = (SELECT Id from City as CT WHERE CT.CityName = @cityName)
				IF EXISTS (SELECT * FROM District as D WHERE D.DistrictName = @districtName)
					BEGIN
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
						UPDATE District SET [CountryId] =  @countryId, [CityId] = @cityId WHERE District.DistrictName = @districtName
						IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
							print 'Complated!'
						ELSE
							INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
					END
				ELSE
					BEGIN
						INSERT INTO District values (@districtName,@countryId,@cityId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
							IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
								print 'Complated!'
							ELSE
								BEGIN
									INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
									print 'Town added'
								END
					END
			END
    END
ELSE
		INSERT INTO Country values(@countryName,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
		SET @countryId  = (SELECT Id from Country as C WHERE C.CountryName = @countryName)
		IF EXISTS(SELECT * FROM City as CT WHERE CT.CityName = @cityName)
			BEGIN
				SET @cityId  = (SELECT Id from City as CT WHERE CT.CityName = @cityName)
				IF EXISTS (SELECT * FROM District as D WHERE D.DistrictName = @districtName)
					BEGIN
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
						UPDATE District SET [CountryId] =  @countryId, [CityId] = @cityId WHERE District.DistrictName = @districtName
						IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
							BEGIN
								UPDATE Town SET [CountryId] =  @countryId, [CityId] = @cityId, [DistrictId] = @districtId WHERE Town.TownName = @townName
								print 'Complated!'
							END
						ELSE
							INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
					END
				ELSE
					BEGIN
						INSERT INTO District values (@districtName,@countryId,@cityId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
						IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
								BEGIN
									UPDATE Town SET [CountryId] =  @countryId, [CityId] = @cityId, [DistrictId] = @districtId WHERE Town.TownName = @townName
									print 'Complated!'
								END
						ELSE
							BEGIN
								INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
								print 'Town added'
							END
					END
			END
		ELSE 
			BEGIN
				INSERT INTO City values (@cityName,@countryId)
				SET @cityId  = (SELECT Id from City as CT WHERE CT.CityName = @cityName)
				IF EXISTS (SELECT * FROM District as D WHERE D.DistrictName = @districtName)
					BEGIN
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
						UPDATE District SET [CountryId] =  @countryId, [CityId] = @cityId WHERE District.DistrictName = @districtName
						IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
							BEGIN
								UPDATE Town SET [CountryId] =  @countryId, [CityId] = @cityId, [DistrictId] = @districtId WHERE Town.TownName = @townName
								print 'Country, City, District and Town is exists'
							END
						ELSE
							BEGIN
								INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
								print 'Town added'
							END
					END
				ELSE
					BEGIN
						INSERT INTO District values (@districtName,@countryId,@cityId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
						SET @districtId = (SELECT Id from District as D WHERE  D.DistrictName = @districtName)
							IF EXISTS (SELECT * FROM Town as T WHERE T.TownName = @townName)
								BEGIN
									UPDATE Town SET [CountryId] =  @countryId, [CityId] = @cityId, [DistrictId] = @districtId WHERE Town.TownName = @townName
									print 'Country, City, District and Town is exists'
								END
							ELSE
								BEGIN
									INSERT INTO Town values (@townName,@countryId,@cityId,@districtId,FLOOR(RAND() * (1000 - 1 + 1)) + 1)
									print 'Town added'
								END
					END
END
	

EXEC sp_StoreProcedure 'CountryA', 'CityC','DistrictB','TownB'

SELECT * FROM City 
SELECT * FROM Country 
SELECT * FROM District 
SELECT * FROM Town 