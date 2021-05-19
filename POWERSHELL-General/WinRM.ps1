winrm set winrm/config/winrs '@{ MaxMemoryPerShellMB = "2147483647"}'

winrm set winrm/config/winrs '@{ AllowRemoteShellAccess = "true" ; IdleTimeout = "7200000"; MaxConcurrentUsers = "2147483647" ; MaxShellRunTime = "2147483647"; MaxProcessesPerShell = "2147483647"; MaxMemoryPerShellMB = "2147483647"; MaxShellsPerUser = "2147483647" }'

winrm get winrm/config/winrs

reference
https://docs.microsoft.com/en-us/windows/win32/winrm/quotas