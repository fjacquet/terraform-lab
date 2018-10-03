# Disable IPv6 Transition Technologies
netsh int teredo set state disabled
netsh int 6to4 set state disabled
netsh int isatap set state disabled
netsh interface tcp set global autotuninglevel=disabled