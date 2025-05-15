Contacts.[Contact_ID], Contacts.[First_Name], Contacts.[Last_Name] AS [Last Name], 
Contacts.[__Age] AS [Age], Contacts.[Mobile_Phone], Contacts.[Email_Address],

Participant_Record_Table_Member_Status_ID_Table.[Member_Status] + ' (' + (SELECT STRING_AGG(Group_Code, ',') 
  FROM Groups G INNER JOIN Group_Participants GP ON GP.Group_ID = G.Group_ID 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491,490,536)) + ')' AS [Statuses],

(SELECT (CONVERT(date, max(Response_Date))) FROM Form_Responses WHERE Form_Responses.Contact_ID = Contacts.Contact_ID AND Form_ID=22) AS [Form Submitted],

N'🚩 ' + (SELECT STRING_AGG(M.Milestone_Title, ' & ') FROM Milestones M INNER JOIN Participant_Milestones PM ON PM.Milestone_ID = M.Milestone_ID 
 WHERE PM.Participant_ID = Contacts.Participant_Record AND PM.Milestone_ID IN (47, 56, 66)) AS [Flags],

(SELECT TOP 1 FORMAT(Background_Check_Started, 'MMM dd, yyyy') FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Sent],

(SELECT TOP 1 FORMAT(Background_Check_Returned, 'MMM dd, yyyy') FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Completed],

(SELECT TOP 1 
  CASE 
    WHEN All_Clear = 'true' THEN N'✅ Clear' 
    WHEN All_Clear = 'false' THEN N'🚩 Flags'
    WHEN All_Clear IS NULL THEN N'⏳ Pending' 
  END
  FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID 
  ORDER BY Background_Check_ID DESC) AS [BGC Status],

(SELECT (FORMAT(max(Date_Accomplished),'MMM dd, yyyy'))  FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 32) AS [(OLD) BGC Milestone],

(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 57) THEN 'Completed' ELSE NULL END) AS [1st Ref],
(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 58) THEN 'Completed' ELSE NULL END) AS [2nd Ref],
(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 59) THEN 'Completed' ELSE NULL END) AS [3rd Ref],

(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 60) THEN 'Completed' ELSE NULL END) AS [Interview],

(CASE WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 61) THEN 'Yes' ELSE NULL END) AS [Approved],
(SELECT (max(Notes))  FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 61) AS [Approved Notes],


(CASE WHEN EXISTS(SELECT* FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 62) THEN 'YES' ELSE NULL END) AS [PCO Certified]
