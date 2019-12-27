
CREATE TABLE tmp_UM_Cohort1811 (
UserId int,
RegisterDate date
)
--truncate table tmp_UM_Cohort1811

DECLARE @RegStartDate date = '20181101',
		@RegEndDate date = '20181130',
		@Platform int = 1114

INSERT INTO tmp_UM_Cohort1811

SELECT DISTINCT U.Id, U.RegisterDate FROM Users as U
JOIN DeviceClients as DC on U.Id = DC.UserId
WHERE U.RegisterDate BETWEEN @RegStartDate AND @RegEndDate
AND DC.ClientId = 1114;





DECLARE @Days_Start int = 30,
		@Days_End int = 60

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

		FROM tmp_UM_Cohort1811 as cohort
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UC FROM tmp_UM_Cohort1811 as C
		JOIN UserCodeImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as UCI on cohort.UserId = UCI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UP FROM tmp_UM_Cohort1811 as C
		JOIN UserPostImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as UPI on cohort.UserId = UPI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS DP FROM tmp_UM_Cohort1811 as C
		JOIN DiscussionPostImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as DPI on cohort.UserId = DPI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.Statusdate) AS CP FROM tmp_UM_Cohort1811 as C
		JOIN ContestUsers as A on C.UserId = A.UserId
		WHERE StatusDate BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		AND (Result IN (1,2,8) OR Status IN (4,5,6))
		GROUP BY C.UserId) as C on cohort.UserId = C.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS L FROM tmp_UM_Cohort1811 as C
		JOIN LessonImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as LI on cohort.UserId = LI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UL FROM tmp_UM_Cohort1811 as C
		JOIN UserLessonImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as ULI on cohort.UserId = ULI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS P FROM tmp_UM_Cohort1811 as C
		JOIN ProfileImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		AND A.UserId <> A.ProfileId
		GROUP BY C.UserId) as PI on cohort.UserId = PI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS OP FROM tmp_UM_Cohort1811 as C
		JOIN ProfileImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		AND A.UserId = A.ProfileId
		GROUP BY C.UserId) as OPI on cohort.UserId = OPI.UserId	
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS F FROM tmp_UM_Cohort1811 as C
		JOIN Followers as A on C.UserId = A.UserId
		WHERE A.FollowDate BETWEEN DATEADD(day, @Days_Start, C.RegisterDate) AND DATEADD(day, @Days_End, C.RegisterDate)
		GROUP BY C.UserId) as Fol on cohort.UserId = Fol.UserId	
		;
