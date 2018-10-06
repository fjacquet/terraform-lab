# Disable IPv6 Transition Technologies
netsh int teredo Set-Variable state disabled
netsh int 6to4 Set-Variable state disabled
netsh int isatap Set-Variable state disabled
netsh interface tcp Set-Variable global autotuninglevel=disabled
