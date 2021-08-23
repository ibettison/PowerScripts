$recipients = @('ian@bettison.me.uk', 'jeanette@bettison.me.uk', 'ian.bettison@ncl.ac.uk')
$subject = 'Test email sent directly from PowerShell'
$body = "Dear Bettisons`r`nThis is a test email sent from Powershell directly.`r`nKind regards,`r`nIan."
foreach($recipient in $recipients){
  send-mailmessage -from "ian.bettison@ncl.ac.uk" -To $recipient -Subject $subject -body $body -SmtpServer "smtp.ncl.ac.uk"
}