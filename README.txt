2. First change the $path variable to point to our provided sample text file (hosts.txt).
Then add the hosts you want to resolve to the file. There can only be one hostname per line.
ex) www.google.com
www.amazon.com
DESKTOP-HEPE84U

3. The command line argument should be a range of valid IPv4 addresses in either dash notation (8.8.8.1-8.8.8.10) or CIDR notation (8.8.8.0/24)
ex) python .\3.py 8.8.8.0/24

4. The command line argument should be a file with valid IPv4 addresses stored line by line. Please refer to lab3_iplist.txt for an example input file
ex) powershell .\4.ps1 'lab3_iplist.txt'

5. First change the $path variable to point to our provided sample text file (port_scan.txt).
Then add the IP address range and port range you would like to scan. The IP address range and
port range must be separated by a space. There are 2 accepted formats for IP ranges:
dash notation (192.168.10.1-192.168.10.5) and CIDR notation (192.168.10.1/24). There must not be
a space between the dash and the IP addresses. There also must not be a space between the IP address,
the CIDR number and the slash. There are 2 accepted formats for port ranges: dash notation (1-1000)
and comma delimited notation (21,22,23). There must not be a space between the dashes or commas.

6. Change the --server argument at the end of the file to the NTP server you want to query.
The argument takes either a fully qualified hostname or an IP address. The default is 'ntp.rit.edu' if no argument is provided.
There are two switch options, -NoDns and -NoMonlist. The first disables the resolution of referenceId IP addresses to domain mames and the second disables attempting to send MON_GETLIST command to NTP server.
