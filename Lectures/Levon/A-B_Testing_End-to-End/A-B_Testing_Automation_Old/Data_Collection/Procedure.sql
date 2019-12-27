ALTER VIEW kpi_group 
AS 
	select Distinct U.Id as UserID, 
					U.RegisterDate as DateAfter
	from Users as U
	join DeviceClients as DC on U.Id = DC.UserId
	where U.CountryCode = 'US' and 
			DC.ClientId = 1114 and
			U.RegisterDate between '20180901' and '20191201'
GO
drop procedure DS_ExperimentData
go
create procedure DS_ExperimentData
	@StartDays int,
	@EndDays int
as
	SELECT lesson.UserId, 
	lesson.DateAfter as RegisterDate,
		lesson.countoflesson as L,
		userlesson.countofuserlesson as UL,
		code.countofcode as UC,
		post.countofpost as UP,
		discussion.countofdiscussion as DP,
		contest.countofcontest as CP,
		ownprofile.countofownprofile as OP,
		profile.countofprofile as P,
		checkin.countofcheckin as CK
	FROM   (SELECT all_users.userid, 
				all_users.DateAfter,
				Count(li.userid) AS countoflesson 
		FROM   kpi_group AS all_users 
				LEFT JOIN lessonimpressions AS li 
						ON all_users.userid = li.userid 
							AND li.date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and li.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
		GROUP  BY all_users.userid, all_users.DateAfter) AS lesson 

		LEFT JOIN (SELECT all_users.userid, 
							Count(uli.userid) AS countofUserlesson 
					FROM   kpi_group AS all_users 
							LEFT JOIN userlessonimpressions AS uli 
								ON all_users.userid = uli.userid 
									AND uli.date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and uli.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
		GROUP  BY all_users.userid) AS userlesson ON lesson.userid = userlesson.userid
				
		LEFT JOIN (SELECT all_users.userid, 
				Count(uci.userid) AS countofcode 
		FROM   kpi_group AS all_users 
				LEFT JOIN UserCodeImpressions AS uci 
						ON all_users.userid = uci.userid 
							AND uci.date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and uci.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
		GROUP  BY all_users.userid) AS code on lesson.userid = code.userid

		LEFT JOIN (SELECT all_users.userid, 
							Count(upi.userid) AS countofpost
					FROM   kpi_group AS all_users 
							LEFT JOIN UserPostImpressions AS upi 
									ON all_users.userid = upi.userid 
										AND upi.date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and upi.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
					GROUP  BY all_users.userid) AS post ON lesson.userid = post.userid

		LEFT JOIN (SELECT all_users.userid, 
							Count(dpi.userid) AS countofdiscussion
					FROM   kpi_group AS all_users 
							LEFT JOIN DiscussionPostImpressions AS dpi
									ON all_users.userid = dpi.userid 
										AND dpi.date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and dpi.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
					GROUP  BY all_users.userid) AS discussion ON lesson.userid = discussion.userid
				
		LEFT JOIN (SELECT all_users.userid, 
				Count(cu.userid) AS countofcontest 
		FROM   kpi_group AS all_users 
				LEFT JOIN ContestUsers AS cu 
						ON all_users.userid = cu.userid 
							AND cu.StatusDate <= Dateadd(day, @EndDays, all_users.DateAfter)
						and cu.StatusDate >= Dateadd(day, @StartDays, all_users.DateAfter)
		WHERE (CU.Status = 6 or CU.Result in (1,2,8) )
		GROUP  BY all_users.userid) AS contest ON lesson.UserID = contest.UserID

		LEFT JOIN (SELECT all_users.userid, 
							Count(opi.userid) AS countofownprofile
					FROM   kpi_group AS all_users 
							LEFT JOIN ProfileImpressions AS opi 
									ON all_users.userid = opi.userid 
										AND opi.Date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and opi.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
					where opi.ProfileId = opi.UserId
					GROUP  BY all_users.userid) AS ownprofile ON lesson.userid = ownprofile.userid
				
		LEFT JOIN (SELECT all_users.userid, 
							Count(pimpr.userid) AS countofprofile
					FROM   kpi_group AS all_users 
							LEFT JOIN ProfileImpressions AS pimpr 
									ON all_users.userid = pimpr.userid 
										AND pimpr.Date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and pimpr.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
					where pimpr.ProfileId <> pimpr.UserId
					GROUP  BY all_users.userid) AS profile ON lesson.userid = profile.userid

		LEFT JOIN (SELECT all_users.userid, 
							Count(DISTINCT cast(uc.Date as Date)) AS countofcheckin
					FROM   kpi_group AS all_users 
							LEFT JOIN UserCheckins AS uc
									ON all_users.userid = uc.userid 
										AND uc.Date <= Dateadd(day, @EndDays, all_users.DateAfter)
						and uc.Date >= Dateadd(day, @StartDays, all_users.DateAfter)
					GROUP  BY all_users.userid) AS checkin ON lesson.userid = checkin.userid
go

--exec DS_ExperimentData 0, 31
