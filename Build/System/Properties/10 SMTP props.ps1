if($SmtpServerEnableSsl -eq $null) {
    $SmtpServerEnableSsl = 'false'
}

if($SmtpServerPort -eq $null) {
    $SmtpServerPort = '25'
}

if($SmtpServerUserName -eq $null) {
    $SmtpServerUserName = ''
}

if($SmtpServerPassword -eq $null) {
    $SmtpServerPassword = ''
}