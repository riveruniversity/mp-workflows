Contacts.[Nickname] AS [First Name], Contacts.[Last_Name], Contacts.[__Age] AS [Age], 
Household_ID_Table_Address_ID_Table.[City] + ', ' + Household_ID_Table_Address_ID_Table.[State/Region] AS [City State],
Household_ID_Table_Address_ID_Table.[Country_Code] AS [Country],

(SELECT COALESCE(Participant_Record_Table_Member_Status_ID_Table.Member_Status, Participant_Record_Table_Participant_Type_ID_Table.Participant_Type) + 
  COALESCE((SELECT ' (' + STRING_AGG(Group_Code, ', ') + ')' FROM Groups G JOIN Group_Participants GP ON GP.Group_ID=G.Group_ID 
    WHERE GP.Participant_ID=Contacts.Participant_Record AND GP.Group_ID IN (499,491,490,536)
  ),'')) AS [Participant],

(SELECT CASE WHEN MAX(FR.Form_Response_ID) IS NOT NULL
  THEN '<a style="text-decoration:none;" target="_blank" href="https://mp.revival.com/mp/424/' + 
  CONVERT(varchar(10), MAX(FR.Form_Response_ID)) + N'">View Form</a>' END FROM Form_Responses FR 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 95) AS [App],

(SELECT (CONVERT(date, max(Response_Date))) FROM Form_Responses WHERE Form_Responses.Contact_ID = Contacts.Contact_ID AND Form_ID=22) AS [Submitted On],

N'🚩 ' + (SELECT STRING_AGG(M.Milestone_Title, ' & ') FROM Milestones M INNER JOIN Participant_Milestones PM ON PM.Milestone_ID = M.Milestone_ID 
 WHERE PM.Participant_ID = Contacts.Participant_Record AND PM.Milestone_ID IN (47, 56, 66)) AS [Flags],

(SELECT TOP 1 FORMAT(Background_Check_Started, 'MMM dd, yyyy') FROM Background_Checks BGC WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Sent],

(SELECT TOP 1 FORMAT(Background_Check_Returned, 'MMM dd, yyyy') FROM Background_Checks BGC WHERE BGC.Contact_ID = Contacts.Contact_ID ORDER BY Background_Check_ID DESC) AS [BGC Completed],

(SELECT COALESCE((
    SELECT TOP 1 
      CASE 
        WHEN All_Clear = 'true' THEN N'✅ Clear'
        WHEN All_Clear = 'false' THEN '<a style="text-decoration:none;color:#475466;" href="https://mp.revival.com/mp/292-2739/'+ CONVERT(varchar(10), Contacts.Contact_ID) +'/511/'+ CONVERT(varchar(10), Background_Check_ID) + N'">🚩 Flags</a>' 
        WHEN All_Clear IS NULL THEN N'⏳ Processing'
      END
    FROM Background_Checks BGC 
    WHERE BGC.Contact_ID = Contacts.Contact_ID 
    ORDER BY Background_Check_ID DESC
  ), N'⚠️ Needs BGC')
) AS [BGC Status],

(SELECT TOP 1 Status_Name FROM Form_Response_Statuses FRS INNER JOIN Form_Responses FR ON FR.Status_ID = FRS.Status_ID 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 95 ORDER BY FR.Response_Date DESC) AS [App Status]