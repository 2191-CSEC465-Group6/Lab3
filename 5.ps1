$path = "C:\Users\Thomas\Documents\RIT\Fall 2019\Net Audit\ports.txt"
#$text = Get-Content $path

$range = "8.8.8.8"

function Get-Hosts($range)
{
  
  if(Test-Connection $range -count 1 -quiet)
  {
       Write-Host "$range is up"
  }
  $begin++
}

function Scan-Ports($ports)
{
    $ip = "8.8.8.8"
    
    foreach($port in $ports)
    {
        if($port -match "-")
        {
            $port = ($port -split "-")
            $begin = [int]$port[0]
            $end = [int]$port[1]
        }

        if($port -match ",")
        {
            
        }
    }

    Write-Host "ip: $ip"
    Write-Host "begin: $begin"
    Write-Host "end: $end"
    
    While ($begin -lt $end)
    {
        try{
            $conn = New-Object System.Net.Sockets.TCPClient($ip,$begin)
        } catch { 
        Write-Host "Port $begin is closed"
        $begin++
        continue
        }
        
        if($conn.Connected)
        {
            Write-Host "Port $begin is open"
        }
        $begin++
    }
}

$ports = Get-Content $path
Get-Hosts($range)
$open = Scan-Ports($ports)