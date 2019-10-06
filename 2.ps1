#Author: Thomas Coburn

#Take in File
$path = ""
$text = Get-Content $path

# Returns IP addresses associated with domain/host name
function Get-IPAddress($hostname)
{
    #returns DNS info from target host
    $dns = $(Resolve-DnsName $hostname).IPAddress

    #regular expression for IP address matching
    $regex = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"
    
    #filter out IPv6 addresses
    $addrs = @()
    foreach($ip in $dns)
    {
        if($ip -match $regex)
        {
            $addrs+=$ip
        }
    }
    
    #return array containing only IPv4 addresses
    return $addrs
}

#save hosts from file into array
$hosts = @()
foreach($line in $text)
{
    $hosts += $line
}

#iterate through each host and return IPv4 info
foreach($hostname in $hosts)
{
    Write-Host "Host: $hostname"
    $ip = Get-IPAddress($hostname)
    
    #if multiple IPv4 addresses exist, join them into a comma delimited string
    if($ip -is [array])
    {
        $ip = $($ip -join ", ")
    }
    Write-Host "IP address: $ip`n"
}
