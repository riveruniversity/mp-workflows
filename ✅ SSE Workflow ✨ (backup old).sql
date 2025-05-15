Contacts.[Nickname] AS [First Name], 
Contacts.[Last_Name] AS [Last Name], 
Contacts.[__Age] AS [Age], 
Household_ID_Table_Address_ID_Table.[City] + ', ' + Household_ID_Table_Address_ID_Table.[State/Region] AS [City State],
Household_ID_Table_Address_ID_Table.[Country_Code] AS [Country],

Participant_Record_Table_Member_Status_ID_Table.[Member_Status] + ' (' + (SELECT STRING_AGG(Group_Code, ',') 
  FROM Groups G INNER JOIN Group_Participants GP ON GP.Group_ID = G.Group_ID 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491,490,536)) + ')' AS [Statuses],

(SELECT (CONVERT(date, max(Response_Date))) FROM Form_Responses WHERE Form_Responses.Contact_ID = Contacts.Contact_ID AND Form_ID=95) AS [SSE Registration],

(SELECT CASE WHEN MAX(FR.Form_Response_ID) IS NOT NULL
  THEN '<a style="text-decoration:none;" target="_blank" href="https://mp.revival.com/mp/424/' + 
  CONVERT(varchar(10), MAX(FR.Form_Response_ID)) + N'">View Form</a>' END FROM Form_Responses FR 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 95) AS [App],

(SELECT (CONVERT(date, max(Response_Date))) FROM Form_Responses WHERE Form_Responses.Contact_ID = Contacts.Contact_ID AND Form_ID=22) AS [Submitted On],

(CASE 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 47) THEN N'🚩 Denied' 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 56) THEN N'🚩 On Hold' 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 66) THEN N'🚩 Removed from MOH' 
  ELSE NULL END) AS [UNITE Milestones],

(SELECT TOP 1 FORMAT(Background_Check_Started, 'MMM dd, yyyy') FROM Background_Checks BGC WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Sent],

(SELECT TOP 1 FORMAT(Background_Check_Returned, 'MMM dd, yyyy') FROM Background_Checks BGC WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Completed],

(SELECT TOP 1 
  CASE 
      WHEN All_Clear = 'true' THEN N'✅ Clear'
      WHEN All_Clear = 'false' THEN N'🚩 Flags'
      WHEN All_Clear IS NULL THEN N'⏳ Processing'
  END
  FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID 
  ORDER BY Background_Check_ID DESC) AS [BGC Status],


(CASE 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 130) THEN N'✅ Approved by Pastor' 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 133) THEN N'🚫 Declined by Pastoral' 
  ELSE NULL END) AS [Pastoral Approval],

(CASE 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 131) THEN N'✅ Accepted' ELSE NULL END) AS [Accepted to SSE]