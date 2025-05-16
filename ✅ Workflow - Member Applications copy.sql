Contacts.[Contact_ID], Contacts.[First_Name], Contacts.[Last_Name] AS [Last Name], 
Contacts.[__Age] AS [Age], Contacts.[Mobile_Phone], Contacts.[Email_Address],

(SELECT Participant_Record_Table_Member_Status_ID_Table.Member_Status + 
  COALESCE((SELECT ' (' + STRING_AGG(Group_Code, ', ') + ')' FROM Groups G JOIN Group_Participants GP ON GP.Group_ID=G.Group_ID 
  WHERE GP.Participant_ID=Contacts.Participant_Record AND GP.Group_ID IN (499,491,490,536) AND GP.End_Date IS Null),'')) AS [Participant],

(SELECT  '<a style="text-decoration:none;" target="_blank" href="https://mp.revival.com/mp/424/' + 
  CONVERT(varchar(10), MAX(FR.Form_Response_ID)) + N'">📝 View</a>' FROM Form_Responses FR 
 WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID IN(86,22)) AS [App],

(SELECT (CONVERT(date, max(Response_Date))) FROM Form_Responses WHERE Form_Responses.Contact_ID = Contacts.Contact_ID AND Form_ID IN (86,22)) AS [Submitted On],

N'🚩 ' + (SELECT STRING_AGG(M.Milestone_Title, ' & ') FROM Milestones M INNER JOIN Participant_Milestones PM ON PM.Milestone_ID = M.Milestone_ID 
 WHERE PM.Participant_ID = Contacts.Participant_Record AND PM.Milestone_ID IN (47, 56, 66)) AS [Flags],

(SELECT TOP 1 FORMAT(Background_Check_Started, 'MMM dd, yyyy') FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Sent],

(SELECT COALESCE((
    SELECT TOP 1 
      CASE 
        WHEN All_Clear = 'true' THEN N'✅ Clear'
        WHEN All_Clear = 'false' THEN '<a style="text-decoration:none;color:#475466;" href="https://mp.revival.com/mp/292-2753/'+ CONVERT(varchar(10), Contacts.Contact_ID) +'/511/'+ CONVERT(varchar(10), Background_Check_ID) + N'">🚩 Flags</a>' 
        WHEN All_Clear IS NULL THEN N'⏳ Processing'
      END
    FROM Background_Checks BGC 
    WHERE BGC.Contact_ID = Contacts.Contact_ID 
    ORDER BY Background_Check_ID DESC
  ), N'⚠️ Needs BGC')
) AS [BGC Status],

(SELECT (FORMAT(max(Date_Accomplished),'MMM dd, yyyy'))  FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 32) AS [(OLD) BGC Milestone],

(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 57) THEN 'Completed' ELSE NULL END) AS [1st Ref],
(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 58) THEN 'Completed' ELSE NULL END) AS [2nd Ref],
(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 59) THEN 'Completed' ELSE NULL END) AS [3rd Ref],

(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 60) THEN 'Completed' ELSE NULL END) AS [Interview],

(SELECT TOP 1 Status_Name FROM Form_Response_Statuses FRS INNER JOIN Form_Responses FR ON FR.Status_ID = FRS.Status_ID 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID IN (22,86) ORDER BY FR.Response_Date DESC) AS [App Status],

(SELECT TOP 1 Status_Notes FROM Form_Responses FR 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID IN (22,86) ORDER BY FR.Response_Date DESC) AS [Status Notes],

(CASE WHEN EXISTS(SELECT* FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 62) THEN 'YES' ELSE NULL END) AS [PCO Certified]