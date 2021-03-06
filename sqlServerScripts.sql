/****** Object:  Database [trainData]    Script Date: 1.9.2020 13.11.10 ******/
CREATE DATABASE [trainData]  (EDITION = 'Basic', SERVICE_OBJECTIVE = 'Basic', MAXSIZE = 2 GB) WITH CATALOG_COLLATION = SQL_Latin1_General_CP1_CI_AS;
GO
ALTER DATABASE [trainData] SET COMPATIBILITY_LEVEL = 150
GO
ALTER DATABASE [trainData] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [trainData] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [trainData] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [trainData] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [trainData] SET ARITHABORT OFF 
GO
ALTER DATABASE [trainData] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [trainData] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [trainData] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [trainData] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [trainData] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [trainData] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [trainData] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [trainData] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [trainData] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [trainData] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [trainData] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [trainData] SET  MULTI_USER 
GO
ALTER DATABASE [trainData] SET ENCRYPTION ON
GO
ALTER DATABASE [trainData] SET QUERY_STORE = ON
GO
ALTER DATABASE [trainData] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 7), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 10, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
/****** Object:  User [user1]    Script Date: 1.9.2020 13.11.10 ******/
CREATE USER [user1] FOR LOGIN [login1] WITH DEFAULT_SCHEMA=[dbo]
GO
sys.sp_addrolemember @rolename = N'db_datareader', @membername = N'user1'
GO
/****** Object:  Schema [dw]    Script Date: 1.9.2020 13.11.11 ******/
CREATE SCHEMA [dw]
GO
/****** Object:  Schema [prep]    Script Date: 1.9.2020 13.11.11 ******/
CREATE SCHEMA [prep]
GO
/****** Object:  Schema [pub]    Script Date: 1.9.2020 13.11.11 ******/
CREATE SCHEMA [pub]
GO
/****** Object:  Schema [stg]    Script Date: 1.9.2020 13.11.11 ******/
CREATE SCHEMA [stg]
GO
/****** Object:  Table [pub].[dimDate]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[dimDate](
	[datekey] [varchar](10) NOT NULL,
	[date] [date] NULL,
	[year] [int] NULL,
	[month] [int] NULL,
	[day] [int] NULL,
	[weekday] [varchar](20) NULL,
	[firstDayOfMonth] [date] NULL,
	[lastDayOfMonth] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[datekey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[dimPhase]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[dimPhase](
	[phasekey] [int] NOT NULL,
	[phase] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[phasekey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[factTrainHistory]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[factTrainHistory](
	[phaseNumberOnTrip] [bigint] NULL,
	[trainKey] [bigint] NULL,
	[stationKeyStart] [bigint] NULL,
	[stationKeyEnd] [bigint] NULL,
	[datekey] [varchar](10) NOT NULL,
	[timeKeyScheduledTimeStart] [varchar](8) NOT NULL,
	[timeKeyScheduledTimeEnd] [varchar](8) NOT NULL,
	[timeKeyActualTimeStart] [varchar](8) NULL,
	[timeKeyActualTimeEnd] [varchar](8) NULL,
	[phasekey] [int] NOT NULL,
	[routekey] [bigint] NULL,
	[phaseTimeScheduled] [int] NULL,
	[phaseTimeActual] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[dimStation]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[dimStation](
	[stationKey] [bigint] NULL,
	[stationShortCode] [varchar](255) NULL,
	[stationUICCode] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[dimTrain]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[dimTrain](
	[trainKey] [bigint] NULL,
	[trainNumber] [varchar](255) NULL,
	[operatorUICCode] [int] NULL,
	[operatorShortCode] [varchar](255) NULL,
	[trainType] [varchar](255) MASKED WITH (FUNCTION = 'default()') NULL,
	[trainCategory] [varchar](255) MASKED WITH (FUNCTION = 'partial(3, "***MASK***", 3)') NULL
) ON [PRIMARY]
GO
/****** Object:  View [pub].[databricks_v]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [pub].[databricks_v] as
select top(20)
	dim4.trainNumber,
	dim4.trainType,
	dim4.trainCategory,
	dim2.date,
	dim3.phase,
	dim5.stationShortCode as startStation,
	dim6.stationShortCode as endStation,
	case
		when fact.phaseTimeScheduled - fact.phaseTimeActual >= 0 then 0
		else 1
	end as late
from 
	[pub].[factTrainHistory]	fact
	inner join pub.dimDate			dim2	on	dim2.datekey=fact.datekey
	inner join pub.dimPhase			dim3	on	dim3.phasekey=fact.phasekey
	inner join pub.dimTrain			dim4	on	dim4.trainKey=fact.trainKey
	inner join pub.dimStation		dim5	on	dim5.stationKey=fact.stationKeyStart
	inner join pub.dimStation		dim6	on	dim6.stationKey=fact.stationKeyEnd
where
	fact.phaseTimeActual is not null
GO
/****** Object:  Table [dw].[trainHistory]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[trainHistory](
	[trainNumber] [varchar](255) NULL,
	[departureDate] [datetime2](7) NULL,
	[operatorUICCode] [int] NULL,
	[operatorShortCode] [varchar](255) NULL,
	[trainType] [varchar](255) NULL,
	[trainCategory] [varchar](255) NULL,
	[commuterLineID] [varchar](255) NULL,
	[runningCurrently] [varchar](255) NULL,
	[cancelled] [varchar](255) NULL,
	[version] [varchar](255) NULL,
	[timetableType] [varchar](255) NULL,
	[timetableAcceptanceDate] [datetime2](7) NULL,
	[stationShortCode] [varchar](255) NULL,
	[stationUICCode] [int] NULL,
	[countryCode] [varchar](255) NULL,
	[type] [varchar](255) NULL,
	[trainStopping] [varchar](255) NULL,
	[commercialStop] [varchar](255) NULL,
	[commercialTrack] [varchar](255) NULL,
	[cancelled2] [varchar](255) NULL,
	[scheduledTime] [datetime2](7) NULL,
	[actualTime] [datetime2](7) NULL,
	[differenceInMinutes] [int] NULL,
	[causes] [varchar](255) NULL,
	[source] [varchar](255) NULL,
	[accepted] [varchar](255) NULL,
	[timestamp] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Object:  View [prep].[factTrainHistory]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [prep].[factTrainHistory] as

select
	ROW_NUMBER()					over(				
										partition by trainNumber,departureDate 
										order by scheduledTime)			as	phaseNumberOnTrip,
	trainNumber,
	cast(departureDate as date)											as	departureDate,
	case
		when type='ARRIVAL'			then 'STAGE'
		when type='DEPARTURE' and lag(stationShortCode)	
									over(
										partition by trainNumber,departureDate  
										order by scheduledTime) is null 
											then 'TRIP BEGINNING'
		when type='DEPARTURE'		then 'ON STATION'
			
	end																	as	phase,
	case
		when lag(stationShortCode)	over(
										partition by trainNumber,departureDate 
										order by scheduledTime) is null
											then stationShortCode
		else lag(stationShortCode)	over(
										partition by trainNumber 
										order by scheduledTime)
	end																	as	stationShortCodeStart,
	stationShortCode													as	stationShortCodeEnd,
	case
		when type='DEPARTURE' and lag(stationShortCode)	
									over(
										partition by trainNumber,departureDate  
										order by scheduledTime) is null 
											then scheduledTime
		else lag(scheduledTime)				
									over(
										partition by trainNumber,departureDate  
										order by scheduledTime)
	end																	as	scheduledTimeStart,
	scheduledTime														as	scheduledTimeEnd,
	case
		when type='DEPARTURE' and lag(stationShortCode)	
									over(
										partition by trainNumber,departureDate  
										order by scheduledTime) is null 
											then actualTime
		else lag(actualTime)				
									over(
										partition by trainNumber,departureDate  
										order by scheduledTime)
	end																	as	actualTimeStart,
	actualTime															as	actualTimeEnd,
	datediff(	minute,
				lag(scheduledTime)	
									over(
										partition by trainNumber,departureDate 
										order by scheduledTime),
				scheduledTime)											as	phaseTimeScheduled,
	datediff(	minute,
				lag(actualTime)	
									over(
										partition by trainNumber,departureDate 
										order by scheduledTime),
				actualTime)												as	phaseTimeActual
from
	dw.trainHistory

GO
/****** Object:  View [pub].[dimRoute_v]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [pub].[dimRoute_v] as

with route_prep as (
	select distinct
		trainNumber,
		departureDate,
		stationShortCodeEnd
	from 
		[prep].[factTrainHistory]
)

select
	ROW_NUMBER() over(order by trainNumber,departureDate)		as	routekey,
	trainNumber,
	departureDate,
	string_agg(cast(stationShortCodeEnd as varchar(max)),'-')	as	route
from 
	route_prep
group by
	trainNumber,
	departureDate


GO
/****** Object:  View [pub].[dimTrain_v]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [pub].[dimTrain_v] as

with prep_data as (
	select distinct
		trainNumber,
		operatorUICCode,
		operatorShortCode,
		trainType,
		trainCategory
	from
		dw.trainHistory
)

select 
	ROW_NUMBER() over(order by trainNumber) as trainKey,
	* 
from 
	prep_data
GO
/****** Object:  Table [pub].[dimTime]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[dimTime](
	[timekey] [varchar](8) NOT NULL,
	[time] [time](0) NULL,
	[hour] [int] NULL,
	[minute] [int] NULL,
	[second] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[timekey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [pub].[dimStation_v]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [pub].[dimStation_v] as

with prep_data as (
	select distinct
		stationShortCode,
		stationUICCode
	from
		dw.trainHistory
)

select 
	ROW_NUMBER() over(order by stationShortCode) as stationKey,
	* 
from 
	prep_data
GO
/****** Object:  View [pub].[factTrainHistory_v]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [pub].[factTrainHistory_v] as

select
	prep.phaseNumberOnTrip,
	train.trainKey,
	stat1.stationKey					as	stationKeyStart,
	stat2.stationKey					as	stationKeyEnd,
	date.datekey,
	time1.timekey						as	timeKeyScheduledTimeStart,
	time2.timekey						as	timeKeyScheduledTimeEnd,
	time3.timekey						as	timeKeyActualTimeStart,
	time4.timekey						as	timeKeyActualTimeEnd,
	pha.phasekey,
	rou.routekey,
	prep.phaseTimeScheduled,
	prep.phaseTimeActual
from
	prep.factTrainHistory			prep
	inner join	pub.dimTrain_v		train	on	prep.trainNumber=train.trainNumber
	inner join	pub.dimStation_v	stat1	on	prep.stationShortCodeStart=stat1.stationShortCode
	inner join	pub.dimStation_v	stat2	on	prep.stationShortCodeEnd=stat2.stationShortCode
	inner join	pub.dimDate			date	on	date.date=prep.departureDate
	inner join	pub.dimTime			time1	on	time1.time=cast(scheduledTimeStart as time(0))
	inner join	pub.dimTime			time2	on	time2.time=cast(scheduledTimeEnd as time(0))
	inner join	pub.dimPhase		pha		on	pha.phase=prep.phase
	inner join	pub.dimRoute_v		rou		on	rou.trainNumber=prep.trainNumber and rou.departureDate=prep.departureDate
	left join	pub.dimTime			time3	on	time3.time=cast(actualTimeStart as time(0))
	left join	pub.dimTime			time4	on	time4.time=cast(actualTimeEnd as time(0))
GO
/****** Object:  View [pub].[dimStationStart]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [pub].[dimStationStart] as
select * from pub.dimStation
GO
/****** Object:  View [pub].[dimStationEnd]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create view [pub].[dimStationEnd] as
 select * from pub.dimStation
GO
/****** Object:  View [pub].[dimTimeActualEnd]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [pub].[dimTimeActualEnd]
as select * from pub.dimTime
GO
/****** Object:  View [pub].[dimTimeActualStart]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [pub].[dimTimeActualStart]
as select * from pub.dimTime
GO
/****** Object:  View [pub].[dimTimeScheduledEnd]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [pub].[dimTimeScheduledEnd]
as select * from pub.dimTime
GO
/****** Object:  View [pub].[dimTimeScheduledStart]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [pub].[dimTimeScheduledStart]
as select * from pub.dimTime
GO
/****** Object:  Table [dbo].[test]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test](
	[a] [int] NULL,
	[b] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[databricks]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[databricks](
	[trainNumber] [varchar](255) NULL,
	[trainType] [varchar](255) NULL,
	[trainCategory] [varchar](255) NULL,
	[date] [date] NULL,
	[phase] [varchar](255) NULL,
	[startStation] [varchar](255) NULL,
	[endStation] [varchar](255) NULL,
	[late] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[databricks_results]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[databricks_results](
	[trainNumber] [varchar](255) NULL,
	[trainType] [varchar](255) NULL,
	[trainCategory] [varchar](255) NULL,
	[date] [date] NULL,
	[phase] [varchar](255) NULL,
	[startStation] [varchar](255) NULL,
	[endStation] [varchar](255) NULL,
	[late] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [pub].[dimRoute]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pub].[dimRoute](
	[routekey] [bigint] NULL,
	[trainNumber] [varchar](255) NULL,
	[departureDate] [date] NULL,
	[route] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [stg].[trainHistory]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg].[trainHistory](
	[trainNumber] [varchar](255) NULL,
	[departureDate] [datetime2](7) NULL,
	[operatorUICCode] [int] NULL,
	[operatorShortCode] [varchar](255) NULL,
	[trainType] [varchar](255) NULL,
	[trainCategory] [varchar](255) NULL,
	[commuterLineID] [varchar](255) NULL,
	[runningCurrently] [varchar](255) NULL,
	[cancelled] [varchar](255) NULL,
	[version] [varchar](255) NULL,
	[timetableType] [varchar](255) NULL,
	[timetableAcceptanceDate] [datetime2](7) NULL,
	[stationShortCode] [varchar](255) NULL,
	[stationUICCode] [int] NULL,
	[countryCode] [varchar](255) NULL,
	[type] [varchar](255) NULL,
	[trainStopping] [varchar](255) NULL,
	[commercialStop] [varchar](255) NULL,
	[commercialTrack] [varchar](255) NULL,
	[cancelled2] [varchar](255) NULL,
	[scheduledTime] [datetime2](7) NULL,
	[actualTime] [datetime2](7) NULL,
	[differenceInMinutes] [int] NULL,
	[causes] [varchar](255) NULL,
	[source] [varchar](255) NULL,
	[accepted] [varchar](255) NULL,
	[timestamp] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[populateDwTables]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[populateDwTables]

AS
BEGIN
    SET NOCOUNT ON
	insert into dw.trainHistory select * from stg.trainHistory;

END
GO
/****** Object:  StoredProcedure [dbo].[populatePubTables]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[populatePubTables]

AS
BEGIN
    SET NOCOUNT ON

	truncate table pub.dimRoute;
	truncate table pub.dimStation;
	truncate table pub.dimTrain;
	truncate table pub.factTrainHistory;

	insert into pub.dimRoute select * from  pub.dimRoute_v;
	insert into pub.dimStation select * from  pub.dimStation_v;
	insert into pub.dimTrain select * from  pub.dimTrain_v;
	insert into pub.factTrainHistory select * from  pub.factTrainHistory_v;

END
GO
/****** Object:  StoredProcedure [dbo].[truncateTrainHistory]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[truncateTrainHistory]

AS
BEGIN
    SET NOCOUNT ON
	truncate table stg.trainHistory;

END
GO
/****** Object:  StoredProcedure [prep].[populateDate]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [prep].[populateDate]

AS
BEGIN
    SET NOCOUNT ON
	begin try
		truncate table pub.dimDate;

		declare @datekey			varchar(10),
				@date				date,
				@year				int,
				@month				int,
				@day				int,
				@weekday			varchar(20),
				@firstDayOfMonth	date,
				@lastDayOfMonth		date,
				@sqlCommand			varchar(max);

		set @date = '20200101';

		while @date < '20250101'
			begin
				set @datekey			=	cast(@date as varchar(10))
				set @year				=	year(@date)
				set @month				=	month(@date)
				set @day				=	day(@date)
				set @weekday			=	datename(weekday,@date)
				set @firstDayOfMonth	=	datefromparts(year(@date),1,1)
				set @lastDayOfMonth		=	eomonth(@date)

				insert into pub.dimDate values(@datekey,@date,@year,@month,@day,@weekday,@firstDayOfMonth,@lastDayOfMonth)

				set @date = dateadd(day,1,@date)
			end
			print 'Populating pub.dimDate SUCCEEDED.'
	end try
	begin catch
		print 'Populating pub.dimDate FAILED.'
	end catch

END
GO
/****** Object:  StoredProcedure [prep].[populateTime]    Script Date: 1.9.2020 13.11.11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [prep].[populateTime]

AS
BEGIN
    SET NOCOUNT ON
	begin try
		truncate table pub.dimTime;

		declare @timekey			varchar(8),
				@time				time(0),
				@hour				int,
				@minute				int,
				@second				int;

		set @time = '00:00:00';
		print @time

		while @time <= '23:59:59'
			begin
				set @timekey			=	cast(@time as varchar(8))
				set @hour				=	datepart(hour,@time)
				set @minute				=	datepart(minute,@time)
				set @second				=	datepart(second,@time)

				insert into pub.dimTime values(@timekey,@time,@hour,@minute,@second)

				set @time = dateadd(second,1,@time)
			end
			print 'Populating pub.dimTime SUCCEEDED.'
	end try
	begin catch
		print 'Populating pub.dimTime FAILED.'
	end catch

END
GO
ALTER DATABASE [trainData] SET  READ_WRITE 
GO
