-- =================================

--------- Experiment 1 -------------

-- =================================

--11111111111111111111111111111111111111111111111111111111111111111111111111
--------- Field study --------------

--------------------- Users who have at least 1 LessonImpression
select cast(Date as Date) as Date, count(DISTINCT UserId) as UserNumber from LessonImpressions
where date between '2019-02-01' and '2019-03-01'
group by cast(Date as Date)
order by cast(Date as Date)
option (maxdop 3);

--------------------- Users who have seen at least 1 Ad in lessons
select cast(AIAP.Date as Date) as Date, Count(DISTINCT AIAP.UserId) as UserNumber from 
(select * from AdImpressions as AI
left join AdPlacements as AP on AI.PlacementId = AP.Id) as AIAP
left join AdDimensions as AD on AIAP.DimensionId = AD.Id
where AIAP.Date between '2019-02-01' and '2019-03-01' AND AIAP.PlacementId = 4 AND AD.Id = 1
group by cast(AIAP.Date as Date)
order by cast(AIAP.Date as Date)
option (maxdop 3);

--------------------- Users who have seen at least 2 Ads in lessons
select Date, count(N) as UserNumber from 
(select cast(AIAP.Date as Date) as Date, Count(AIAP.DimensionId) as N from 
(select * from AdImpressions as AI
left join AdPlacements as AP on AI.PlacementId = AP.Id) as AIAP
left join AdDimensions as AD on AIAP.DimensionId = AD.Id
where AIAP.Date between '2019-02-01' and '2019-03-01' AND AIAP.PlacementId = 4 AND AD.Id = 1
group by cast(AIAP.Date as Date), AIAP.UserId
having Count(AIAP.UserId)>2) as temp
group by temp.Date
order by Date
option (maxdop 3);

--------------------- Users who have seen at least 2 Ads in lessons, in one day and the number of Ads they have seen
select cast(AIAP.Date as Date) as Date, UserId, count(AdSetId) as N from 
(select * from AdImpressions as AI
left join AdPlacements as AP on AI.PlacementId = AP.Id) as AIAP
left join AdDimensions as AD on AIAP.DimensionId = AD.Id
where AIAP.Date between '2019-02-01' and '2019-02-02' AND AIAP.PlacementId = 4 AND AD.Id = 1
group by cast(AIAP.Date as Date), AIAP.UserId
having Count(AIAP.UserId)>1
option (maxdop 3);

--------------------- Checking the randomness of user ids
select top 1000 id, RegisterDate from users
where registerdate between '2019-02-01' and '2019-02-03'
order by RegisterDate
option (maxdop 3);

--22222222222222222222222222222222222222222222222222222222222222222222222222
--------- Gerenal info--------------

--------------------- Start of the experiment: first banner shown on '2019-03-13 10:48:57.753' UTC
select top 10 * from AdImpressions
where adsetid in (6,8,9) and date > '2019-03-13'
order by date asc
option (maxdop 3);

--3333333333333333333333333333333333333333333333333333333333333333333333333
--------- Intermediate results of the experiment --------------

------------ AdImpressions for groups
-- Group 1: Adset 6
-- Group 2: Adset 8
-- Group 3: Adset 9

select Userid%8 as Treatmnent_group, AdSetId, count(PlacementId) as AdCount, count(DISTINCT UserId) as UserCount from AdImpressions
where date > '2019-03-13' and PlacementId = 4 and AdsetId in (6,8,9)
group by Userid%8, AdSetId
having Userid%8 in(0,1,2,3)
option (maxdop 3);

------------ Users who have seen 2+ Ads
select Userid%8 as Variant,  count(temp) as UsersWith2Ads from
(select UserId, count(PlacementId) as temp from Adimpressions
			where Date > '2019-03-13 10:45:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as  A
group by Userid%8
order by Userid%8
option (maxdop 3);

------------ Subsciptions of users who have seen the banners
-- intermezzo
select * from Subscriptions
where CreatedDate > '2019-03-13'
option (maxdop 3);

-- Subscribed users for Control Group: Counts
select VersionUsers.Userid%8 as Controls, Count(Id) as Subs from 
			(select UserId from Adimpressions
			where Date > '2019-03-13 10:45:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-13') as S on VersionUsers.UserId = S.UserId
group by VersionUsers.Userid%8
option (maxdop 3);

-- Subscribed users for Control Group: User info
select * from 
			(select UserId from Adimpressions
			where Date > '2019-03-13 10:45:00' and PlacementId = 4  -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
			INNER JOIN (select * from Subscriptions
						where CreatedDate > '2019-03-13') as S on VersionUsers.UserId = S.UserId
LEFT JOIN Users on VersionUsers.UserId=Users.Id
option (maxdop 3);

-- Subscribed users per Variant: Counts
select AI.AdsetId, count(DISTINCT AI.UserId) as SubscriptionCount from
(select DISTINCT UserId
from AdImpressions
where Date>'2019-03-13' and AdSetId in (6,8,9)) as VersionUsers
INNER JOIN (select * from AdImpressions 
			where Date>'2019-03-13' and AdSetId in (6,8,9)) as AI on VersionUsers.UserId = AI.UserId
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-13') as S on VersionUsers.UserId = S.UserId
group by AI.AdsetId
option (maxdop 3);

-- Subscribed users per Variant: User info
select AI.UserId, AI.AdSetId, 
		S.SubscriptionId, S.Platform, 
		S.CreatedDate, S.IsActive, S.StartDate, S.EndDate, 
		S.CancelReason, S.CancelDate
 from
(select DISTINCT UserId
from AdImpressions
where Date>'2019-03-13' and AdSetId in (6,8,9)) as VersionUsers
INNER JOIN (select DISTINCT UserId, AdSetId, PlacementId from AdImpressions 
			where Date>'2019-03-13' and AdSetId in (6,8,9)) as AI on VersionUsers.UserId = AI.UserId
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-13') as S on VersionUsers.UserId = S.UserId
order by S.CreatedDate
option (maxdop 3);

-- Subscribed users per Variant: User info from Users Table
select * from
		(select Id as UserId, RegisterDate, Level, Xp, CountryCode, Badge, IsPro from users
		where id in (11992705, 13190009, 11397418, 13186482, 13192290, 13191299, 9997161, 13128065)) as UsersInfo
LEFT JOIN Subscriptions on UsersInfo.UserId = Subscriptions.UserId
option (maxdop 3);


-- testo user: 3345201
select * from AdImpressions
where userid = 3345201 and placementid = 4
order by date
option (maxdop 3);

select * from Subscriptions
where userid = 3345201
option (maxdop 3);



--444444444444444444444444444444444444444444444444444444444444444444444444444444
--------- Final results of the experiment --------------
-- Ads VS Subscriptions
-- Country list
select DISTINCT Users.CountryCode from
		(select DISTINCT UserId from AdImpressions
		where date > '2019-03-13 09:48:57.753' and PlacementId = 4) as UI
		LEFT JOIN Users on UI.UserId = Users.Id
option (maxdop 3);


--5555555555555555555555555555555555555555555555555555555555555555555
--------- Intermediate results of the Experiment 1.2 --------------

------------ AdImpressions for groups
-- Group 1: Adset 6
-- Group 2: Adset 8
-- Group 3: Adset 9

select Userid%4 as Treatment_group, AdSetId, count(PlacementId) as AdCount, count(DISTINCT UserId) as UserCount from AdImpressions
where date > '2019-03-18 13:10:00' and PlacementId = 4 and AdsetId in (6,8,9) -- date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00'
group by Userid%4, AdSetId
having Userid%4 in(0,1,2,3)
option (maxdop 3);

------------ Users who have seen 2+ Ads
select Userid%4 as Variant,  count(temp) as UsersWith2Ads from
(select UserId, count(PlacementId) as temp from Adimpressions
			where Date > '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as  A
group by Userid%4
order by Userid%4
option (maxdop 3);

------------ Subsciptions of users who have seen the banners
-- intermezzo
select * from Subscriptions
where CreatedDate > '2019-03-13'
option (maxdop 3);

-- Subscribed users for Control Group: Counts
select VersionUsers.Userid%4 as Controls, Count(Id) as Subs from 
			(select DISTINCT UserId from Adimpressions
			where Date > '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
group by VersionUsers.Userid%4
option (maxdop 3);

-- Subscribed users for Control Group: User info
select * from 
			(select UserId from Adimpressions
			where Date > '2019-03-18 13:10:00' and PlacementId = 4  -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
			INNER JOIN (select * from Subscriptions
						where CreatedDate > '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
LEFT JOIN Users on VersionUsers.UserId=Users.Id
option (maxdop 3);

-- Subscribed users per Variant: Counts
select AI.AdsetId, count(DISTINCT AI.UserId) as SubscriptionCount from
(select DISTINCT UserId
from AdImpressions
where Date>'2019-03-18 13:10:00' and AdSetId in (6,8,9)) as VersionUsers -- date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' -- Date>'2019-03-18 13:10:00'
INNER JOIN (select * from AdImpressions 
			where Date>'2019-03-18 13:10:00' and AdSetId in (6,8,9)) as AI on VersionUsers.UserId = AI.UserId
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
group by AI.AdsetId
option (maxdop 3);

-- Subscribed users per Variant: User info
select AI.UserId, AI.AdSetId, 
		S.SubscriptionId, S.Platform, 
		S.CreatedDate, S.IsActive, S.StartDate, S.EndDate, 
		S.CancelReason, S.CancelDate
 from
(select DISTINCT UserId
from AdImpressions
where Date>'2019-03-18 13:10:00' and AdSetId in (6,8,9)) as VersionUsers
INNER JOIN (select DISTINCT UserId, AdSetId, PlacementId from AdImpressions 
			where Date>'2019-03-18 13:10:00' and AdSetId in (6,8,9)) as AI on VersionUsers.UserId = AI.UserId
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
order by S.CreatedDate
option (maxdop 3);

-- Subscribed users per Variant: User info from Users Table
select * from
		(select Id as UserId, RegisterDate, Level, Xp, CountryCode, Badge, IsPro from users
		where id in (11992705, 13190009, 11397418, 13186482, 13192290, 13191299, 9997161, 13128065)) as UsersInfo
LEFT JOIN Subscriptions on UsersInfo.UserId = Subscriptions.UserId
option (maxdop 3);



--66666666666666666666666666666666666666666666666666666666666666666666666666

--66666666666666666666666666666666666666666666666666666666666666666666666666

--66666666666666666666666666666666666666666666666666666666666666666666666666

--------- Final results of the Experiment 1.2 --------------

------------ AdImpressions for groups
-- Group 1: Adset 6
-- Group 2: Adset 8
-- Group 3: Adset 9

--old
select Userid%8 as Treatment_group, AdSetId, count(PlacementId) as AdCount, count(DISTINCT UserId) as UserCount from AdImpressions
where date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' and PlacementId = 4 and AdsetId in (6,8,9) -- date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00'
group by Userid%8, AdSetId
having Userid%8 in(0,1,2,3)
option (maxdop 3);

--new
select Userid%4 as Treatment_group, AdSetId, count(PlacementId) as AdCount, count(DISTINCT UserId) as UserCount from AdImpressions
where date > '2019-03-18 13:10:00' and PlacementId = 4 and AdsetId in (6,8,9) -- date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00'
group by Userid%4, AdSetId
having Userid%4 in(0,1,2,3)
option (maxdop 3);

------------ Users who have seen 2+ Ads
--old
select Userid%8 as Variant,  count(temp) as UsersWith2Ads from
(select UserId, count(PlacementId) as temp from Adimpressions
			where date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as  A
group by Userid%8
order by Userid%8
option (maxdop 3);

--new
select Userid%4 as Variant,  count(temp) as UsersWith2Ads from
(select UserId, count(PlacementId) as temp from Adimpressions
			where Date > '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as  A
group by Userid%4
order by Userid%4
option (maxdop 3);

-- Subscribed users for Control Group: Counts
--old
select VersionUsers.Userid%8 as Controls, Count(Id) as Subs from 
			(select DISTINCT UserId from Adimpressions
			where date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
INNER JOIN (select * from Subscriptions
			where CreatedDate between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
group by VersionUsers.Userid%8
option (maxdop 3);

--new
select VersionUsers.Userid%4 as Controls, Count(Id) as Subs from 
			(select DISTINCT UserId from Adimpressions
			where Date > '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
group by VersionUsers.Userid%4
option (maxdop 3);

-- Subscribed users from PopUps
--old
select VersionUsers.Userid%8 as Controls, count(PUI.UserId) as SeenPopUp from -- // date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' // Date > '2019-03-18 13:10:00'
( select DISTINCT UserId from Adimpressions
			where date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
INNER JOIN (select UserId, SubscriptionId, CreatedDate from Subscriptions
			where CreatedDate between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
INNER JOIN (select * from PopupImpressions
			where date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' and PopupId = 3) as PUI on VersionUsers.UserId = PUI.UserId
where S.CreatedDate between PUI.Date and dateadd(minute,10,PUI.Date)
group by VersionUsers.Userid%8
option (maxdop 3);

--new
select VersionUsers.Userid%4 as Controls, count(PUI.UserId) as SeenPopUp from -- // date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00' // Date > '2019-03-18 13:10:00'
( select DISTINCT UserId from Adimpressions
			where date > '2019-03-18 13:10:00' and PlacementId = 4 -- Userid%8 IN (1,2,3) and
			group by UserId
			having count(PlacementId)>2) as VersionUsers
INNER JOIN (select UserId, SubscriptionId, CreatedDate from Subscriptions
			where CreatedDate > '2019-03-18 13:10:00') as S on VersionUsers.UserId = S.UserId
INNER JOIN (select * from PopupImpressions
			where date > '2019-03-18 13:10:00' and PopupId = 3) as PUI on VersionUsers.UserId = PUI.UserId
where S.CreatedDate between PUI.Date and dateadd(minute,10,PUI.Date)
group by VersionUsers.Userid%4
option (maxdop 3);


-- ProPage impressions // First ProPage impression is on 2019-03-27 22:28:07.367
-- Banners seen
select AdImpressions.Userid%4 as Treatment_group, AdImpressions.AdSetId, count(AdImpressions.UserId) as AdCount, count(DISTINCT AdImpressions.UserId) as UserCount 
from AdImpressions
join DeviceClients on AdImpressions.UserId = DeviceClients.UserId
where date > '2019-03-27 22:25' and PlacementId = 4 and AdsetId in (6,8,9) -- date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00'
and ClientID = 1114
and AppVersion = '2.5.3'
group by AdImpressions.Userid%4, AdSetId
option (maxdop 3);


-- Banners clicked
select AdSetId, count(PlacementId) as AdCount from 
		(select * from AdImpressions where date > '2019-03-27 22:25' and PlacementId = 4 and AdsetId in (6,8,9)) as AI
JOIN (select * from PageImpressions where Date > '2019-03-27 22:25') as PI on AI.UserId = PI.UserId
join DeviceClients on AI.UserId = DeviceClients.UserId
where DateDiff(second, AI.Date, PI.Date) between 0 and 30
and DeviceClients.ClientID = 1114
and DeviceClients.AppVersion = '2.5.3'
group by AdSetId
option (maxdop 3);

-- Banners clicked & subscribed
select AdSetId, 
		Count(AI.UserId) as ProPageViewed, 
		Count(DISTINCT PI.UserId) as UsersWhoViewedProPage,
		Count(DISTINCT S.UserId) as SubscribedUsers from 
		(select * from AdImpressions where date > '2019-03-27 22:25' and PlacementId = 4 and AdsetId in (6,8,9)) as AI
JOIN (select * from PageImpressions where Date > '2019-03-27 22:25' and page = 'get-pro') as PI on AI.UserId = PI.UserId
LEFT JOIN (select UserId, CreatedDate from Subscriptions where CreatedDate > '2019-03-27 22:25') as S on AI.UserId = S.UserId
join DeviceClients on AI.UserId = DeviceClients.UserId
where DateDiff(second, AI.Date, PI.Date) between 0 and 30  and DateDiff(minute, PI.Date, S.CreatedDate) between 0 and 60
and DeviceClients.ClientID = 1114
and DeviceClients.AppVersion = '2.5.3'
group by AdSetId
option (maxdop 3);


-- Banners seen, by countries
select DC.CountryCode, DC.Country, DC.ClientID, count(AI.UserId) as BannerCount from
	(select UserId from AdImpressions
	where date > '2019-03-13' and  placementid = 4 and adsetid in (6,8,9)) as AI
LEFT join (select DISTINCT UserId, ClientId, CountryCode, Country from DeviceClients) as DC on AI.userid = DC.UserId
where DC.ClientID in (1114, 1122)
group by DC.CountryCode, DC.Country, DC.ClientID
order by DC.CountryCode, DC.Country, DC.ClientID
option (maxdop 3);

--Revenue comparison
select * from
	(select DISTINCT UserId from AdImpressions
	where date > '2019-03-13 10:45:00' and  placementid = 4 and adsetid = 8) as AI
INNER JOIN (select * from Subscriptions
			where CreatedDate > '2019-03-13 10:45:00') as S on AI.UserId = S.UserId
INNER JOIN (select Id, CountryCode from Users) as U on U.Id = AI.UserId
option (maxdop 3);


--77777777777777777777777777777777777777777777777777777777777777777777777777

--77777777777777777777777777777777777777777777777777777777777777777777777777

--77777777777777777777777777777777777777777777777777777777777777777777777777

--------- Final results of the Experiment 1.3 --------------

------------ AdImpressions for groups // first adset=16 impression is on 2019-04-04 10:19:20.293
-- Group 1: Adset 16
-- Group 2: Adset 8
-- Group 3: Adset 9

-- ProPage impressions // First ProPage impression is on 2019-03-27 22:28:07.367
-- Banners seen
select AdImpressions.Userid%4 as Treatment_group, AdImpressions.AdSetId, count(AdImpressions.UserId) as AdCount, count(DISTINCT AdImpressions.UserId) as UserCount 
from AdImpressions
join DeviceClients on AdImpressions.UserId = DeviceClients.UserId
where date > '2019-04-04 10:19' and PlacementId = 4 and AdsetId in (16,8,9) -- date between '2019-03-13 10:45:00' AND '2019-03-18 13:10:00'
and ClientID = 1114
and AppVersion in ('2.5.3', '2.5.4')
group by AdImpressions.Userid%4, AdSetId
order by AdImpressions.Userid%4
option (maxdop 3);


-- Banners clicked
select AdSetId, count(PlacementId) as AdCount from 
		(select * from AdImpressions where date > '2019-04-04 10:19' and PlacementId = 4 and AdsetId in (16,8,9)) as AI
JOIN (select * from PageImpressions where Date > '2019-04-04 10:19') as PI on AI.UserId = PI.UserId
join DeviceClients on AI.UserId = DeviceClients.UserId
where DateDiff(second, AI.Date, PI.Date) between 0 and 30
and DeviceClients.ClientID = 1114
and DeviceClients.AppVersion in ('2.5.3', '2.5.4')
group by AdSetId
order by AdSetId desc
option (maxdop 3)

-- Banners clicked & subscribed
select AdSetId, 
		Count(AI.UserId) as ProPageViewed, 
		Count(DISTINCT PI.UserId) as UsersWhoViewedProPage,
		Count(DISTINCT S.UserId) as SubscribedUsers from 
		(select * from AdImpressions where date > '2019-04-04 10:19' and PlacementId = 4 and AdsetId in (16,8,9)) as AI
JOIN (select * from PageImpressions where Date > '2019-04-04 10:19' and page = 'get-pro') as PI on AI.UserId = PI.UserId
LEFT JOIN (select UserId, CreatedDate from Subscriptions where CreatedDate > '2019-04-04 10:19') as S on AI.UserId = S.UserId
join DeviceClients on AI.UserId = DeviceClients.UserId
where DateDiff(second, AI.Date, PI.Date) between 0 and 30  and DateDiff(minute, PI.Date, S.CreatedDate) between 0 and 60
and DeviceClients.ClientID = 1114
and DeviceClients.AppVersion in ('2.5.3', '2.5.4')
group by AdSetId
option (maxdop 3);

--testo 
select top 10 * from AdImpressions
where adsetid = 16
option (maxdop 3);
