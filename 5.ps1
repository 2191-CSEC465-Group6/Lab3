#Author: Thomas Coburn

#read in text file
$path = "C:\Users\Thomas\Documents\RIT\Fall 2019\Net Audit\sample_input.txt"
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

        #check file syntax
        if(($ports -le 0) -or ($ip -le 0))
        {
            Write-Host "Syntax error, ports must be specified. Please enter an IP address and port range in the form <IP range> <port range>`n"
            continue
        }

        #check if hosts are up
        $valid = Get-Hosts($ip)

        #check which ports are open
        Scan-Ports -ports $ports -valid $valid
    } 
}

#Check if hosts are up
function Get-Hosts($range)
{
    #test connection for start-end format ex) "10.10.1.1-10.10.2.10"
    if($range -match "-")
    {
        $range = ($range -split "-")
        $start = $range[0]
        $end = $range[1]

        #split ip address by each octet
        $start = ($start -split "\.")
        $end = ($end -split "\.")
    
        #initialize variables for loop
        $a = [int]$start[0]
        $b = [int]$end[0]

        $c = [int]$start[1]
        $d = [int]$end[1]

        $e = [int]$start[2]
        $f = [int]$end[2]

        $g = [int]$start[3]
        $h = [int]$end[3]
    
        #valid will contain list of IPs that are up
        $valid = @()

        #nested while to check each IP octet
        While($a -le $b)
        {
            $c = [int]$start[1]
            While($c -le $d)
            {
                $e = [int]$start[2]
                while($e -le $f)
                {
                    $g = [int]$start[3]
                    while($g -le $h)
                    {
                        #build current address iteration
                        $addr = ($a.ToString() + "."+ $c.ToString() + "." + $e.ToString() + "." + $g.ToString())

                        #test connection
                        if(Test-Connection $addr -count 1 -quiet)
                        {
                            #if its up, add to list of valid IPs
                            $valid+=$addr
                        }
                        $g++    
                    }
                    $e++
                }
                $c++
            }
            $a++
        }
  
    }

    #test connection for single IP format ex) "8.8.8.8"
    else
    {
        if(Test-Connection $range -count 1 -quiet)
        {
            #if IP is up, add to valid array
            $valid+=$range
        }
    }

    #return list of valid IPs
    return $valid
}

#check if ports are open
function Scan-Ports($ports,$valid)
{

    #if no IPs were up, exit
    if($valid -eq $null)
    {
        Write-Host "No hosts are up. Exiting`n"
        return
    }

    #otherwise for each ip address, scan ports
    foreach($ip in $valid)
    {
        foreach($port in $ports)
        {
            #check if ports are in start-end format ex)440-445
            if($port -match "-")
            {
                #get start and ending port
                $port = ($port -split "-")
                $begin = [int]$port[0]
                $end = [int]$port[1]
            
                #check if each port is up, add to open array
                $open = @()
                While ($begin -lt $end)
                {
                    try{
                        $conn = New-Object System.Net.Sockets.TCPClient($ip,$begin)
                    } catch { 
                        #if port is not open, continue on the loop
                        $begin++
                        continue
                    }
        
                    #check if port is open
                    if($conn.Connected)
                    {
                        #if port is open, add to list of open ports
                        $open+=$begin
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
                $open = @()
                foreach($port in $ports)
                {
                    try{
                        $conn = New-Object System.Net.Sockets.TCPClient($ip,$port)
                    } catch { 
                        #if port is not open, continue on the loop
                        $begin++
                        continue
                    }
        
                    #check if port is open
                    if($conn.Connected)
                    {
                        #add to array of open ports
                        $open+=$port
                    }
                    $begin++
                }
            }
        }

        #print out all open ports
        Write-Host "Open ports for $($ip):"

        if($open.count -le 0)
        {
            Write-Host "No ports are open`n"
        }

        foreach($p in $open)
        {
            Write-Host "$p is open`n"
        }
    }

}

Parse-File($text)