CREATE TABLE tmp_UM_Cohort18_SepOctNov (
UserId int,
RegisterDate date,
CountryCode nvarchar(20)
)
--truncate table tmp_UM_Cohort1811



DECLARE @RegStartDate date = '20180901',
        @RegEndDate date = '20181130',
        @Platform int = 1114

INSERT INTO tmp_UM_Cohort18_SepOctNov

SELECT DISTINCT U.Id, U.RegisterDate, U.CountryCode FROM Users as U
JOIN DeviceClients as DC on U.Id = DC.UserId
WHERE U.RegisterDate BETWEEN @RegStartDate AND @RegEndDate
AND DC.ClientId = 1114;


select CountryCode,  cast(count(CountryCode) as decimal(10,3)) / 588000 as ddxk
from tmp_UM_Cohort18_SepOctNov
group by CountryCode
order by ddxk desc

select UserId, CountryCode
from tmp_UM_Cohort18_SepOctNov

SELECT U.UserId, COUNT(UC.Date) as NofCheckins FROM tmp_UM_Cohort18_SepOctNov as U
JOIN UserCheckins as UC on U.UserId = UC.UserId
WHERE DATEDIFF(day, U.RegisterDate, UC.Date) between 90 AND 180
GROUP BY U.UserId;

DECLARE @Days_Start int = 30,
		@Days_End int = 90

SELECT cohort.UserId
		,	UCI.UC
		,	UPI.UP
		,	DPI.DP
		,	C.CP
		,	LI.L
		,	ULI.UL
		,	PI.P
		,	OPI.OP
		,	Fol.F
		FROM tmp_UM_Cohort18_SepOctNov as cohort
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UC FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN UserCodeImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as UCI on cohort.UserId = UCI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UP FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN UserPostImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as UPI on cohort.UserId = UPI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS DP FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN DiscussionPostImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as DPI on cohort.UserId = DPI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.Statusdate) AS CP FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN ContestUsers as A on C.UserId = A.UserId
		WHERE StatusDate BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		AND (Result IN (1,2,8) OR Status IN (4,5,6))
		GROUP BY C.UserId) as C on cohort.UserId = C.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS L FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN LessonImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as LI on cohort.UserId = LI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UL FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN UserLessonImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as ULI on cohort.UserId = ULI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS P FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN ProfileImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		AND A.UserId <> A.ProfileId
		GROUP BY C.UserId) as PI on cohort.UserId = PI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS OP FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN ProfileImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		AND A.UserId = A.ProfileId
		GROUP BY C.UserId) as OPI on cohort.UserId = OPI.UserId	
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS F FROM tmp_UM_Cohort18_SepOctNov as C
		JOIN Followers as A on C.UserId = A.UserId
		WHERE A.FollowDate BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as Fol on cohort.UserId = Fol.UserId	
		;

select top(100) *
from tmp_UM_Cohort18_SepOctNov