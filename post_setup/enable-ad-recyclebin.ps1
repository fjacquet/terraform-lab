Import-Module ActiveDirectory
Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target "evlab.ch" -confirm:$false
