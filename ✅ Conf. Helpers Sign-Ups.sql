Contacts.[First_Name], Contacts.[Last_Name], Contacts.[__Age] AS [Age], 
Contacts.[Mobile_Phone], Contacts.[Email_Address],

Participant_Record_Table_Member_Status_ID_Table.[Member_Status] + ' (' + (SELECT STRING_AGG(Group_Code, ',') 
  FROM Groups G INNER JOIN Group_Participants GP ON GP.Group_ID = G.Group_ID 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491,490,536)) + ')' AS [Statuses],

(SELECT CASE WHEN MAX(FR.Form_Response_ID) IS NOT NULL
  THEN '<a style="text-decoration:none;" target="_blank" href="https://mp.revival.com/mp/424/' + 
  CAST(MAX(FR.Form_Response_ID) AS varchar(10)) + N'">✅</a>' END FROM Form_Responses FR 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID IN(86,22)) AS [App],

N'🚩 ' + (SELECT STRING_AGG(M.Milestone_Title, ' & ') FROM Milestones M INNER JOIN Participant_Milestones PM ON PM.Milestone_ID = M.Milestone_ID 
 WHERE PM.Participant_ID = Contacts.Participant_Record AND PM.Milestone_ID IN (47, 56, 66)) AS [Flags],

(SELECT STRING_AGG(
  CASE FRA.Form_Field_ID
    WHEN 5003 THEN 'Youth' 
    WHEN 5004 THEN 'Bears' 
    WHEN 5005 THEN 'Kids'
    WHEN 5006 THEN 'Adults'
    WHEN 5007 THEN 'Nursery'
  END, ', ') 
  FROM Form_Response_Answers FRA 
  INNER JOIN Form_Responses FR ON FR.Form_Response_ID = FRA.Form_Response_ID 
  WHERE FR.Contact_ID = Contacts.Contact_ID 
  AND FRA.Form_Field_ID IN (5003, 5004, 5005, 5006, 5007)) AS [Department(s)],

(SELECT TOP 1 FRA.Response FROM Form_Response_Answers FRA INNER JOIN Form_Responses FR ON FR.Form_Response_ID = FRA.Form_Response_ID 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FRA.Form_Field_ID IN (4999) ORDER BY FR.Response_Date DESC) AS [Limitations],

(SELECT TOP 1 FORMAT(Background_Check_Started, 'MMM dd, yyyy') FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Sent],

(SELECT TOP 1 FORMAT(Background_Check_Returned, 'MMM dd, yyyy') FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Completed],

(SELECT TOP 1 
  CASE 
    WHEN All_Clear = 'true' THEN N'✅ Clear' 
    WHEN All_Clear = 'false' THEN N'🚩 Flags'
    WHEN All_Clear IS NULL THEN '<a style="text-decoration:none;color:#475466;" href="https://mp.revival.com/mp/292-2739/'+ CONVERT(varchar(10), Contacts.Contact_ID) +'/511/'+ CONVERT(varchar(10), Background_Check_ID) + N'">⏳ Pending</a>' 
  END
  FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID 
  ORDER BY Background_Check_ID DESC) AS [BGC Status],

(SELECT FORMAT(max(Date_Accomplished),'MMM dd, yyyy') FROM Participant_Milestones PM 
  WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 57) AS [1st Ref],
(SELECT FORMAT(max(Date_Accomplished),'MMM dd, yyyy') FROM Participant_Milestones PM 
  WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 58) AS [2nd Ref],
(SELECT FORMAT(max(Date_Accomplished),'MMM dd, yyyy') FROM Participant_Milestones PM 
  WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 59) AS [3rd Ref],

(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 60) THEN '✅' ELSE NULL END) AS [Interview],

(SELECT TOP 1 Status_Name FROM Form_Response_Statuses FRS INNER JOIN Form_Responses FR ON FR.Status_ID = FRS.Status_ID 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 99 ORDER BY FR.Response_Date DESC) AS [Status],

(SELECT TOP 1 Status_Notes FROM Form_Responses FR WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 99 ORDER BY FR.Response_Date DESC) AS [Status Notes],

(CASE WHEN EXISTS(SELECT* FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 62) THEN 'YES' ELSE NULL END) AS [PCO Certified]