Param (
   [Parameter(Mandatory=$True)]
   [string] $StoreURL,
   [Parameter(Mandatory=$False)]
   $SavePathRoot="..\unisonw10"
)

if ($StoreURL.EndsWith("/"))
{
    $StoreURL=$StoreURL.Remove($StoreUrl.Length-1,1)
}

$wchttp=[System.Net.WebClient]::new()
$URI = "https://store.rg-adguard.net/api/GetFiles"
$myParameters = "type=url&url=$($StoreURL)"

$wchttp.Headers[[System.Net.HttpRequestHeader]::ContentType]="application/x-www-form-urlencoded"
$HtmlResult = $wchttp.UploadString($URI, $myParameters)

$Start=$HtmlResult.IndexOf("<p>The links were successfully received from the Microsoft Store server.</p>")

if ($Start -eq -1)
{
    write-host "Could not get the links, please check the StoreURL."
    exit
}

$TableEnd=($HtmlResult.LastIndexOf("</table>")+8)

$SemiCleaned=$HtmlResult.Substring($start,$TableEnd-$start)

$newHtml=New-Object -ComObject "HTMLFile"
try {
    # This works in PowerShell with Office installed
    $newHtml.IHTMLDocument2_write($SemiCleaned)
}
catch {
    # This works when Office is not installed    
    $src = [System.Text.Encoding]::Unicode.GetBytes($SemiCleaned)
    $newHtml.write($src)
}

$ToDownload=$newHtml.getElementsByTagName("a") | Select-Object textContent, href

$SavePathRoot=$([System.Environment]::ExpandEnvironmentVariables("$SavePathRoot"))

$LastFrontSlash=$StoreURL.LastIndexOf("/")
$ProductID=$StoreURL.Substring($LastFrontSlash+1,$StoreURL.Length-$LastFrontSlash-1)

if ([regex]::IsMatch("$SavePathRoot\$ProductID","([,!@?#$%^&*()\[\]]+|\\\.\.|\\\\\.|\.\.\\\|\.\\\|\.\.\/|\.\/|\/\.\.|\/\.|;|(?<![A-Za-z]):)|^\w+:(\w|.*:)"))
{
    write-host "Invalid characters in path"$SavePathRoot\$ProductID""
    exit
}

if (!(test-path "$SavePathRoot\$ProductID"))
{
    write-host "Creating Directory $SavePathRoot\$ProductID"

    try
    {
        New-Item -ItemType Directory "$SavePathRoot\$ProductID" -ErrorAction Stop | Out-Null
    }
    catch
    {
        write-host "Failed to create directory.$([System.environment]::NewLine)$_"
        write-host "Exiting..."
        exit
    }
}

Foreach ($Download in $ToDownload)
{
    if ($Download.href.EndsWith(".msixbundle"))
    {
        Write-host "Downloading $($Download.textContent)..."
        $wchttp.DownloadFile($Download.href, "$SavePathRoot\$ProductID\$($Download.textContent)")
    }
}
write-host "---------------------------------------"
write-host ""
Write-host "Download is complete..." 
write-host "Opening Folder"
(Start-Sleep -s 3)
(Start "$SavePathRoot\$ProductID\")
