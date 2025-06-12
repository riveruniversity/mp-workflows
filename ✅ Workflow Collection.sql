-- ✅ Flags
(SELECT TOP 1 
  CASE 
    WHEN PM.Milestone_ID = 47 THEN N'🚩 Denied'
    WHEN PM.Milestone_ID = 56 THEN N'🚩 On Hold'
    WHEN PM.Milestone_ID = 66 THEN N'🚩 Removed'
    ELSE NULL
  END
 FROM Participant_Milestones PM WHERE PM.Participant_ID = Contacts.Participant_Record AND PM.Milestone_ID IN (47, 56, 66)) AS [Flags],

-- ✨ Flags
(SELECT STRING_AGG(M.Milestone_Title, ',') FROM Milestones M INNER JOIN Participant_Milestones PM ON PM.Milestone_ID = M.Milestone_ID 
 WHERE PM.Participant_ID = Contacts.Participant_Record AND PM.Milestone_ID IN (47, 56, 66)) AS [Flags],

------------------------------ 

-- ✅ Members
 Participant_Record_Table_Member_Status_ID_Table.[Member_Status] + 
CASE 
  WHEN EXISTS (SELECT 1 FROM Group_Participants GP 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491))
  THEN ' (' + 
    CONCAT_WS(',', 
      CASE WHEN EXISTS(SELECT 1 FROM Group_Participants GP WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID = 499) THEN 'S' END,
      CASE WHEN EXISTS(SELECT 1 FROM Group_Participants GP WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID = 491) THEN 'C' END
    ) + ')'
  ELSE ''
END AS [Member],

-- ✨ Members
Participant_Record_Table_Member_Status_ID_Table.[Member_Status] + ' (' + (SELECT STRING_AGG(Group_Code, ',') 
  FROM Groups G INNER JOIN Group_Participants GP ON GP.Group_ID = G.Group_ID 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491,490,536)) + ')' AS [Members],

-- ✅ Participant Statuses
(SELECT CASE WHEN Participant_Record_Table.Member_Status_ID IS NOT NULL
  THEN Participant_Record_Table_Member_Status_ID_Table.Member_Status
  ELSE Participant_Record_Table_Participant_Type_ID_Table.Participant_Type END ) + ' (' + ISNULL((SELECT STRING_AGG(Group_Code, ', ') 
  FROM Groups G INNER JOIN Group_Participants GP ON GP.Group_ID = G.Group_ID 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491,490,536)), '') + ')' AS [Participant],

-- ✨ Participant Statuses v2
(SELECT CASE WHEN Participant_Record_Table.Member_Status_ID IS NOT NULL
  THEN Participant_Record_Table_Member_Status_ID_Table.Member_Status
  ELSE Participant_Record_Table_Participant_Type_ID_Table.Participant_Type END ) + ' (' + ISNULL((SELECT STRING_AGG(Group_Code, ', ') 
  FROM Groups G INNER JOIN Group_Participants GP ON GP.Group_ID = G.Group_ID 
  WHERE GP.Participant_ID = Contacts.Participant_Record AND GP.Group_ID IN (499, 491,490,536)), '') + ')' AS [Participant],

-- ✨ Participant Statuses v3
(SELECT COALESCE(Participant_Record_Table_Member_Status_ID_Table.Member_Status, Participant_Record_Table_Participant_Type_ID_Table.Participant_Type) + 
  COALESCE((SELECT ' (' + STRING_AGG(Group_Code, ', ') + ')' FROM Groups G JOIN Group_Participants GP ON GP.Group_ID=G.Group_ID 
    WHERE GP.Participant_ID=Contacts.Participant_Record AND GP.Group_ID IN (499,491,490,536)
  ),'')) AS [Participant]



-- ✅ BGC with link
(SELECT TOP 1 
  CASE 
    WHEN All_Clear = 'true' THEN N'✅ Clear' 
    WHEN All_Clear = 'false' THEN N'🚩 Flags'
    WHEN All_Clear IS NULL THEN '<a style="text-decoration:none;color:#475466;" href="https://mp.revival.com/mp/292-2739/'+ CONVERT(varchar(10), Contacts.Contact_ID) +'/511/'+ CONVERT(varchar(10), Background_Check_ID) + N'">⏳ Pending</a>' 
  END
  FROM Background_Checks BGC 
  WHERE BGC.Contact_ID = Contacts.Contact_ID 
  ORDER BY Background_Check_ID DESC) AS [BGC Status],


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


-- ✅ Form Status
(SELECT TOP 1 Status_ID FROM Form_Responses WHERE Contact_ID = Contacts.Contact_ID AND Form_ID = 95 ORDER BY Response_Date DESC ) AS [SSE],

(SELECT TOP 1 Status_Name FROM Form_Response_Statuses FRS INNER JOIN Form_Responses FR ON FR.Status_ID = FRS.Status_ID 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 95 ORDER BY FR.Response_Date DESC) AS [Form Status],


-- ✅ Participant Type (Member or Guest)
(SELECT CASE WHEN Participant_Record_Table.Member_Status_ID IS NOT NULL
  THEN Participant_Record_Table_Member_Status_ID_Table.Member_Status
  ELSE Participant_Record_Table_Participant_Type_ID_Table.Participant_Type END ) AS [Participant],


-- 🔬 TESTING




(SELECT CASE WHEN MAX(FR.Form_Response_ID) IS NOT NULL
  THEN '<a style="text-decoration:none;" target="_blank" href="https://mp.revival.com/mp/424/' + 
  CONVERT(varchar(10), MAX(FR.Form_Response_ID)) + N'">View Form</a>' END FROM Form_Responses FR 
  WHERE FR.Contact_ID = Contacts.Contact_ID AND FR.Form_ID = 95) AS [App],


