[CmdletBinding(DefaultParameterSetName='CoreOptions')]
Param( 
    # Access token for DropBox.
    # https://www.dropbox.com/developers/apps
    [Parameter(Mandatory=$true)]
    [string]$AccessToken,
    
    # Directory with files to backup.
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,
    
    # Archive prefix to use on DropBox.
    [Parameter(Mandatory=$true)]
    [string]$BackupPrefix,
    
    # Optional HTTP proxy to use.
    [Parameter(Mandatory=$false)]
    [string]$ProxyAddress,
    
    # Optional username.
    [Parameter(ParameterSetName='Authentication', Mandatory=$true)]
    [string]$ProxyCredentialUsername,
    
    # Optional password supplied as encrypted standard string (output from ConvertFrom-SecureString)
    # For example: "password" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    [Parameter(ParameterSetName='Authentication', Mandatory=$true)]
    [string]$ProxyCredentialPassword
)

function Upload-FileToDropbox { 
    <#
       .Description
       Uploads file to DropBox.
       https://markb.uk/powershell-dropbox-rolling-database-backup.html
    #>
    param(
        # File on the disk to upload.
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,

        # Location on DropBox to place file in.
        [Parameter(Mandatory=$true)]
        [string]$TargetPath,
        
        # DropBox OAuth Token
        [Parameter(Mandatory=$true)]
        [string]$AccessToken,
        
        # Optional proxy address.
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        
        # Optional proxy credentials
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
    )

    $body = '{ "path": "' + $TargetPath + '", "mode": "overwrite" }'

    $authorization = "Bearer $AccessToken"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

    $headers.Add("Authorization", $authorization)
    $headers.Add("Dropbox-API-Arg", $body)
    $headers.Add("Content-Type", 'application/octet-stream')

    $DropBoxUploadAPI = "https://content.dropboxapi.com/2/files/upload"

    # Check whether we have the proxy paramter set
    if ($PSBoundParameters.ContainsKey('Proxy')) {
        
        # Check whether we have the proxy credential paramter set
        if ($PSBoundParameters.ContainsKey('ProxyCredential')) {
            
            Invoke-RestMethod -Uri $DropBoxUploadAPI `
                                -Method Post `
                                -InFile $SourcePath `
                                -Headers $headers `
                                -Proxy $Proxy `
                                -ProxyCredential $ProxyCredential
        } else {

            Invoke-RestMethod -Uri $DropBoxUploadAPI `
                                -Method Post `
                                -InFile $SourcePath `
                                -Headers $headers `
                                -Proxy $Proxy
        }

    } else {

        Invoke-RestMethod -Uri $DropBoxUploadAPI `
                            -Method Post `
                            -InFile $SourcePath `
                            -Headers $headers
    }
}

function Convert-FolderToArchive {
    <#
       .Description
       Converts a folder and all of its contents into a ZIP archive with the specfied prefix.
       Function will return path to ZIP archive.
    #>

    param (
        # Folder with files to archive..
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        
        # Prefix to create archive with.
        [Parameter(Mandatory=$true)]
        [string]$FilePrefix

    )

    $DateStamp = (Get-Date).ToString("yyyy-MM-dd-HHmm")
    $TempFolderLocation = [System.IO.Path]::GetTempPath()
    $ArchiveName = $TempFolderLocation + $FilePrefix + '-' + $DateStamp + '.zip'

    Compress-Archive -Path $FolderPath -DestinationPath $ArchiveName
    return $ArchiveName
}

# Check if ProxyAddress parameter is set when credentails are entered, if not then prompt with error.
if ($PSBoundParameters.ContainsKey('ProxyCredentialUsername') -and (-not $PSBoundParameters.ContainsKey('ProxyAddress'))) {
    Write-Output -InputObject "You are missing the ProxyAddress parameter."
    exit
}

# Convert folder with files into a ZIP archive in TMP directory
$FileToUpload = Convert-FolderToArchive -FolderPath $BackupPath -FilePrefix $BackupPrefix
# Get the file name of the ZIP archive
$CloudFileLocation = '/' + (Split-Path -Path $FileToUpload -Leaf) 

# Upload file based on parameters set.
if ($PSBoundParameters.ContainsKey('ProxyAddress')) {

    if ($PSBoundParameters.ContainsKey('ProxyCredentialUsername')) {
        # Upload through proxy with credentials
        Upload-FileToDropbox -SourcePath $FileToUpload `
                                -TargetPath $CloudFileLocation `
                                -AccessToken $AccessToken `
                                -Proxy $ProxyAddress `
                                -ProxyCredential (New-Object -TypeName System.Management.Automation.PSCredential  -ArgumentList $ProxyCredentialUsername, ($ProxyCredentialPassword | ConvertTo-SecureString))
    } else {
        # Upload through proxy
        Upload-FileToDropbox -SourcePath $FileToUpload `
                                -TargetPath $CloudFileLocation `
                                -AccessToken $AccessToken `
                                -Proxy $ProxyAddress
    }

} else {
    # Upload directly
    Upload-FileToDropbox -SourcePath $FileToUpload `
                            -TargetPath $CloudFileLocation `
                            -AccessToken $AccessToken
}

# Remove created archive
Remove-Item -Path $FileToUpload
