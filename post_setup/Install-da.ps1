Install-RemoteAccess `
    -DAInstallType FullInstall `
    -ConnectToAddress da.ez-lab.xyz `
    -ClientGPOName "ez-lab.xyz\DirectAccess Clients GPO" `
    -ServerGPOName "ez-lab.xyz\DirectAccess Server GPO" `
    -InternalInterface LAN `
    -InternetInterface INTERNET `
    -NLSURL https://nls.ez-lab.xyz `
    -Force
