$path = "C:\Users\Thomas\Documents\RIT\Fall 2019\Net Audit\ports.txt"
$text = Get-Content($path)

function Parse-File($text)
{
    foreach($line in $text)
    {
        $line = ($line -split " ")
        $ip = $line[0]
        $ports = $line[1]
        #Get-Hosts($ip)
        Scan-Ports($ports)
    } 
}

function Get-Hosts($range)
{
  $range ="10.10.10.1-10.10.10.10"

  if($range -match "-")
  {
    $range = ($range -split "-")
    $start = $range[0]
    $end = $range[1]

    $start = $start
    Write-Host $start

    #$end = $end -split "."
    Write-Host $end

    $range = $start..$end
  }


  #foreach($ip in $range)
  #{
  #  if(Test-Connection $start -count 1 -quiet)
  #  {
  #     Write-Host "$start is up"
  #  }
  #  $begin++
  #}

}

function Scan-Ports($ports)
{
    $ip = "8.8.8.8"
    #$ports = "442,443,444"

    if($ports -match ",")
    {
        
        
    }

    Write-Host $ports
    foreach($port in $ports)
    {
        if($port -match "-")
        {
            $port = ($port -split "-")
            $begin = [int]$port[0]
            $end = [int]$port[1]
            
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

        if($port -match ",")
        {
            $ports = ($ports -split ",")
            foreach($port in $ports)
            {
                try{
                    $conn = New-Object System.Net.Sockets.TCPClient($ip,$port)
                } catch { 
                    Write-Host "Port $port is closed"
                    $begin++
                    continue
                }
        
            
                if($conn.Connected)
                {
                    Write-Host "Port $port is open"
                }
                    $begin++
            }
        }
    }

}


#$ports = Get-Content $path
Parse-File($text)

#Get-Hosts($range)
#$open = Scan-Ports($ports)