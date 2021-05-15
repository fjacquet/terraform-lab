Install-RemoteAccess `
    -DAInstallType FullInstall `
    -ConnectToAddress da.evlab.ch `
    -ClientGPOName "evlab.ch\DirectAccess Clients GPO" `
    -ServerGPOName "evlab.ch\DirectAccess Server GPO" `
    -InternalInterface LAN `
    -InternetInterface INTERNET `
    -NLSURL https://nls.evlab.ch `
    -Force
