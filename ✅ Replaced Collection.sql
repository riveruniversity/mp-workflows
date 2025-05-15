(CASE 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 61) THEN N'✅ Approved' 
  WHEN EXISTS(SELECT * FROM Participant_Milestones PM WHERE Contacts.Participant_Record = PM.Participant_ID AND PM.Milestone_ID = 124) THEN N'🚫 Denied' 
  ELSE  N'⏳ In Process' END) AS [Status],