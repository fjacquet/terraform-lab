
Install-RemoteAccess `
    -DAInstallType FullInstall `
    -ConnectToAddress DA.DIRECTACCESSLAB.FR `
    -ClientGPOName "DirectAccesslab.Lan\DirectAccess Clients GPO" `
    -ServerGPOName "DirectAccesslab.Lan\DirectAccess Server GPO" `
    -InternalInterface LAN `
    -InternetInterface INTERNET `
    -NLSURL https://nls.directaccesslab.lan `
    -Force
