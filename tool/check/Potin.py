import requests
import sys
import socket

print("      https://t.me/devf5r   	")

# COLORS #
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


if len(sys.argv) != 2:
    print("\n Error: Type python3 potin.py yourfile.txt\n")
    sys.exit()
else:
    f = open(sys.argv[1], 'r')
    lines = f.readlines()
    f.close()

    filename = 'potin_files/' + sys.argv[1].replace('../', '') + '_output.txt'
    ip_filename = 'potin_files/'+ sys.argv[1].replace('../', '') + '_out-IP.txt'
    ip_out = open(ip_filename, 'w+')

ip_list = []

for line in lines:
    try:
        if 'http://' in line.strip() or 'https://' in line.strip():
            url = line.strip()
        else:
            url = 'http://' + line.strip()

        s = requests.Session()
        r = s.head(url, timeout=1)
        response = r.headers

        if r.status_code == 200:
            ip = socket.gethostbyname(url.replace('http://', '').replace('https://', ''))
            ip_list.append(ip)

            try:
                print("\n", '\x1b[6;30;42m', '[OK]200', bcolors.ENDC, ':', url, r.headers['server'])
                print("IP Address:", ip)
            except KeyError:
                print('Server not found')
                print("IP Address:", ip)

        if r.status_code == 308:
            ip = socket.gethostbyname(url.replace('http://', '').replace('https://', ''))
            ip_list.append(ip)

            try:
                print("\n", '\x1b[6;39;40m', '[308]', bcolors.OKBLUE, ':', url, r.headers['server'])
                print("IP Address:", ip)
            except KeyError:
                print('Server not found')
                print("IP Address:", ip)

        if r.status_code == 302:
            ip = socket.gethostbyname(url.replace('http://', '').replace('https://', ''))
            ip_list.append(ip)

            print('\n', bcolors.FAIL, r.status_code, ' : ', url, r.headers)
            print("IP Address:", ip)

        if r.status_code == 301:
            ip = socket.gethostbyname(url.replace('http://', '').replace('https://', ''))
            ip_list.append(ip)

            try:
                print("\n", '\x1b[6;39;40m', '[301]', bcolors.OKCYAN, ':', url, r.headers['server'])
                print("IP Address:", ip)
            except KeyError:
                print('Server not found')
                print("IP Address:", ip)

        if r.status_code == 403:
            ip = socket.gethostbyname(url.replace('http://', '').replace('https://', ''))
            ip_list.append(ip)

            try:
                print("\n", '\x1b[6;39;40m', '[403]', bcolors.OKGREEN, ':', url, r.headers['server'])
                print("IP Address:", ip)
            except KeyError:
                print('Server not found')
                print("IP Address:", ip)

    except requests.ConnectionError as e:
        print("\n", bcolors.ENDC + url + bcolors.FAIL + " Failed to connect ")
        continue
    except requests.Timeout as e:
        print("[!] : Timeout Error")
        continue
    except requests.RequestException as e:
        print("[!] : General Error")
        continue

    except KeyboardInterrupt:
        ip_out.close()
        print("IP addresses saved in: " + ip_filename)
        exit()

# Remove duplicate IP addresses
unique_ips = list(set(ip_list))

# Write unique IP addresses to ip.txt
for ip in unique_ips:
    ip_out.write(ip + '\n')

print("IP addresses saved in: " + ip_filename)
ip_out.close()