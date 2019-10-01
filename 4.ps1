#Kyle Smith
#9-30-19
#Lab 3 Question 4
#Find OS given a file with list of IPs

#Clear Screen
CLS

#Set Values for the Windos and Linux default TTL values
$LinuxTTL = 64
$WindowsTTL = 128

#File is the command line arguement
$file= $Args[0]

#Go through file line by line
foreach($line in Get-Content $file) {

	#test the connection of each IP
	if(Test-connection $line -count 1 -quiet){
		
		#Find line in Ping with "Reply"
		$Ping_results= ping -n 1 $line | FINDSTR "Reply"
		
		#Parse the "Reply" line by spaces
		$Reply_array = $Ping_results.split(" ")
		
		#Parse the final element in the Reply_array by the "="
		$TTL_array = $Reply_array[-1].split("=")
		
		#Perform a tracert and then parse results into an array
		$Tracert_results = tracert $line
		$Tracert_array = $Tracert_results.split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
		
		#Write-Host "Tracert results: " $Tracert_Array[-11]
		
		#find the number of hops
		$numHops = [int]$Tracert_Array[-11] - 1
		
		#add the number of hops to the TTL found in the ping and that will
		#equal the system's default TTL
		$IP_TTL = [int]$TTL_array[1] + $numHops
		
		#Write-Host "TTL = $IP_TTL"
		
		#Check if the TTL value is either the Windows or Linux Default value
		if ( $IP_TTL -eq $LinuxTTL) {
			Write-Host "IP $line is Linux"
		} elseif ( $IP_TTL -eq $WindowsTTL) {
			Write-Host "IP $line is Windows"
			
		#if the TTL value is neither Windows nor Linux, print that the IP is up but 
		#is neither Windows nor Linux
		} else {
			Write-Host "IP $line is up but is neither Windows nor Linux"
		}
	}
}