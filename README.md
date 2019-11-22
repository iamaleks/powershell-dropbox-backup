# powershell-dropbox-backup

Backup folders onto DropBox using PowerShell.

## How to use

### Running without Proxy

```powershell
PS C:\> .\PowerBacker.ps1 -AccessToken "TOKEN" -BackupPath "C:\TargetBackupLocation" -BackupPrefix "DailyBackup"
```

### Running with Proxy

```powershell
PS C:\> .\PowerBacker.ps1 -AccessToken "TOKEN" -BackupPath "C:\TargetBackupLocation" -BackupPrefix "DailyBackup" -ProxyAddress "http://10.0.0.2:3128"
```

### Running with Proxy and Credentials

```-ProxyCredentialPassword``` parameter takes a secure string as input in the form of a encrypted standard string, this is what ```ConvertFrom-SecureString``` provides as output. This was done so the string can be saved on disk so no use input will be needed.

```powershell
PS C:\> "password" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File -FilePath mypassword.txt
PS C:\> .\PowerBacker.ps1 -AccessToken "TOKEN" -BackupPath "C:\TargetBackupLocation" -BackupPrefix "DailyBackup" -ProxyAddress "http://10.0.0.2:3128" -ProxyCredentialUsername "user" -ProxyCredentialPassword (Get-Content -Path .\mypassword.txt)
```
