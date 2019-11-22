# PowerShell DropBox Backup Script

Backup folders onto DropBox using PowerShell.

## How to get a Token

The script needs a OAuth access token in order to be able to upload files to a DropBox account. This can be done by going into the [App Console](https://www.dropbox.com/developers/apps) and clicking "Create App". 

After it is created click on "Generate" under Generated access token and a token will be presented.


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

```-ProxyCredentialPassword``` parameter takes a secure string as input in the form of a encrypted standard string, this is what ```ConvertFrom-SecureString``` provides as output. This was done so the string can be saved on disk so no user input will be needed.

```powershell
PS C:\> "password" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File -FilePath mypassword.txt
PS C:\> .\PowerBacker.ps1 -AccessToken "TOKEN" -BackupPath "C:\TargetBackupLocation" -BackupPrefix "DailyBackup" -ProxyAddress "http://10.0.0.2:3128" -ProxyCredentialUsername "user" -ProxyCredentialPassword (Get-Content -Path .\mypassword.txt)
```
