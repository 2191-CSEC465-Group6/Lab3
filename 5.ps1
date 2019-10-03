#Author: Thomas Coburn

#read in text file
$path = "C:\Users\Thomas\Documents\RIT\Fall 2019\Net Audit\ports.txt"
$text = Get-Content($path)

#parse the file line by line
function Parse-File($text)
{
    #extract the IP address and port range
    foreach($line in $text)
    {
        $line = ($line -split " ")
        $ip = $line[0]
        $ports = $line[1]

        #check if hosts are up
        #Get-Hosts($ip)

        #check which ports are open
        Scan-Ports($ports)
    } 
}

#Check if hosts are up
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

#check if ports are open
function Scan-Ports($ports)
{
    $ip = "8.8.8.8"

    foreach($port in $ports)
    {

        #check if ports are in start-end format
        if($port -match "-")
        {
            #get start and ending port
            $port = ($port -split "-")
            $begin = [int]$port[0]
            $end = [int]$port[1]
            
            #check if each port is up
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

        #check if ports are in port1,port2,port3... order
        if($port -match ",")
        {
            #split list into array
            $ports = ($ports -split ",")

            #check if ports are up
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

Parse-File($text)