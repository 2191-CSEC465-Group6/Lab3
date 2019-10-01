import argparse
import ipaddress
import subprocess

def ping(ip):
    command = ['ping', '-n', '1', str(ipaddress.IPv4Address(ip))]
    return subprocess.call(command) == 0

parser = argparse.ArgumentParser(description='Ping Sweep')
parser.add_argument("iprange", type=str, help="IP Range")
args = parser.parse_args()

if "-" in args.iprange:
    ips = args.iprange.split("-")
    ip1 = ipaddress.IPv4Address(ips[0])
    ip2 = ipaddress.IPv4Address(ips[1])
    ip = []

    for i in range(int(ip1), int(ip2) + 1):
        ip.append(i)
else:
    ip = [i for i in ipaddress.IPv4Network(args.iprange).hosts()]

good = []

for addr in ip:
    if ping(addr):
        good.append(ipaddress.IPv4Address(addr))

for ip in good:
    print(str(ip))
