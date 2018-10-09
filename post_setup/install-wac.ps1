
Initialize-AWSDefaults

$wacport = 6516
$wacfile = 'C:\installers\wac.msi'

invoke-webrequest -uri http://aka.ms/WACDownload -OutFile $wacfile

msiexec /i $wacfile /qn /L*v log.txt SME_PORT=$wacport SSL_CERTIFICATE_OPTION=generate
