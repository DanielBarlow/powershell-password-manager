function Convert-SecureStringToPlainText($secureString){ return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))}
function Get-SHA256HashBytes($string){return [System.Security.Cryptography.sha256]::create().ComputeHash(([system.Text.Encoding]::UTF8).GetBytes($string))}
function Prompt-256BitKey(){Get-SHA256HashBytes(Convert-SecureStringToPlainText((read-host -AsSecureString -Prompt "What is your encryption key?")))}
function Add-Secret($file){
((Read-Host -Prompt "What will I call this secret?") -replace ':',';actuallyacolon;')+":"+(ConvertFrom-SecureString -SecureString (read-host -AsSecureString -Prompt "Tell me your secrets...") -key (Prompt-256BitKey)) | Out-File -Append $file
Compress-7Zip -ArchiveFileName ($file+'.7z') -password (Convert-SecureStringToPlainText (Read-Host -AsSecureString -Prompt "7z Password")) -Path $file
}
function Get-Secret($file,$secretid){
if($file -like "*.7z"){Expand-7Zip -Password (Convert-SecureStringToPlainText (Read-Host -AsSecureString -Prompt "7z Password")) -ArchiveFileName $file -TargetPath ((($file -split '\\' | select -SkipLast 1) -join '\')+'\') ; $file = $file -replace '.7z'}
if($secretid -eq $null){$secretid = read-host -Prompt "What did we call this secret?"}
Convert-SecureStringToPlainText((Get-Content $file | Select-String -SimpleMatch $secretid | select -Last 1) -split ':' | select -Last 1 | Convertto-SecureString -Key (Prompt-256BitKey)) | Set-Clipboard
}