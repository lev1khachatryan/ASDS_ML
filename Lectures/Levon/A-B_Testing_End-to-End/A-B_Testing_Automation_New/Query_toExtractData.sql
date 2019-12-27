
DROP TABLE #dsExp;


CREATE TABLE #dsExp (
UserId int,
BaseDate nvarchar(20)
);

INSERT INTO #dsExp
SELECT UserId, '20190614' as DateAfter FROM
	(SELECT DISTINCT U.Id as UserId FROM Users as U
	JOIN DeviceClients AS DC on U.Id = DC.UserId
	WHERE U.RegisterDate > '20190614'
	AND DC.ClientId = 1114
	EXCEPT
	SELECT UserId FROM dsContentCampaignUsers) as A;

	
DECLARE @Days_Start int = 0,
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
		,	Fol.F_to
		,	Fol1.F_by
		,	CI.CK

		FROM #dsExp as cohort
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UC FROM #dsExp as C
		JOIN UserCodeImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as UCI on cohort.UserId = UCI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UP FROM #dsExp as C
		JOIN UserPostImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as UPI on cohort.UserId = UPI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS DP FROM #dsExp as C
		JOIN DiscussionPostImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as DPI on cohort.UserId = DPI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.Statusdate) AS CP FROM #dsExp as C
		JOIN ContestUsers as A on C.UserId = A.UserId
		WHERE StatusDate BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		AND (Result IN (1,2,8) OR Status IN (4,5,6))
		GROUP BY C.UserId) as C on cohort.UserId = C.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS L FROM #dsExp as C
		JOIN LessonImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as LI on cohort.UserId = LI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS UL FROM #dsExp as C
		JOIN UserLessonImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as ULI on cohort.UserId = ULI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS P FROM #dsExp as C
		JOIN ProfileImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		AND A.UserId <> A.ProfileId
		GROUP BY C.UserId) as PI on cohort.UserId = PI.UserId
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS OP FROM #dsExp as C
		JOIN ProfileImpressions as A on C.UserId = A.UserId
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		AND A.UserId = A.ProfileId
		GROUP BY C.UserId) as OPI on cohort.UserId = OPI.UserId	
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS F_to FROM #dsExp as C
		JOIN Followers as A on C.UserId = A.UserId
		WHERE A.FollowDate BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as Fol on cohort.UserId = Fol.UserId	
LEFT JOIN 
	(SELECT C.UserId, count(A.UserId) AS F_by FROM #dsExp as C
		JOIN Followers as A on C.UserId = A.FollowedUserId
		WHERE A.FollowDate BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) as Fol1 on cohort.UserId = Fol1.UserId
LEFT JOIN (SELECT C.UserId, Count(DISTINCT Cast(A.Date as Date)) AS CK FROM #dsExp AS C 
		JOIN UserCheckins AS A ON C.UserId = A.UserId 
		WHERE A.Date BETWEEN DATEADD(day, @Days_Start, C.BaseDate) AND DATEADD(day, @Days_End, C.BaseDate)
		GROUP BY C.UserId) AS CI ON cohort.UserId = CI.UserId
OPTION (MAXDOP 3);

