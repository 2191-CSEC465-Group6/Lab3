#$path = "C:\Users\Thomas\Documents\RIT\Fall 2019\Net Audit\hosts.txt"
#$text = Get-Content $path

$ip = "8.8.8.8"
$begin = 442
$end = 445

#442..444 | % {echo ((new-object Net.Sockets.TcpClient).Connect($ip,$_)) "Port $_ is open!"} 2>$null


While ($begin -lt $end)
{
   #try
   #{
        $conn = {echo ((New-Object System.Net.Sockets.TcpClient).Connect($ip,$begin)) "Port $begin is open!"} 2>null
        
        if($conn.Connected)
        {
            Write-Host "Port $begin is open"
        }
    #} catch {

#    }
    

    $begin++
}