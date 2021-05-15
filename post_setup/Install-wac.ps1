$wacport = 6516
$dldir = 'C:\installers'
mkdir $dldir
$wacfile =  join-path -path $dldir -childpath 'wac.msi'

Invoke-WebRequest -Uri https://aka.ms/WACDownload -OutFile $wacfile #DevSkim: ignore DS104456

msiexec /i $wacfile /qn /L*v log.txt SME_PORT=$wacport SSL_CERTIFICATE_OPTION=generate
