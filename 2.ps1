$path = "C:\Users\Thomas\Documents\RIT\Fall 2019\Net Audit\hosts.txt"
$text = Get-Content $path

function Get-IPAddress($hostname)
{
    $dns = $(Resolve-DnsName $hostname).IPAddress
    $regex = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"
    
    $addrs = @()
    foreach($ip in $dns)
    {
        if($ip -match $regex)
        {
            $addrs+=$ip
        }
    }
    #Write-Host $addrs
    return $addrs
}

$hosts = @()
foreach($line in $text)
{
    $hosts += $line
}

foreach($hostname in $hosts)
{
    Write-Host "Host: $hostname"
    $ip = Get-IPAddress($hostname)
    if($ip -is [array])
    {
        $ip = $($ip -join ", ")
    }
    Write-Host "IP address: $ip`n"
}