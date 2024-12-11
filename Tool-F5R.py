import asyncio
import aiohttp
import sys
import socket
from urllib.parse import urlparse

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

# Validate URL
def validate_url(url):
    parsed = urlparse(url)
    if not parsed.scheme:
        url = "http://" + url
    return url

# Get IP Address
def get_ip(url):
    try:
        hostname = urlparse(url).netloc
        return socket.gethostbyname(hostname)
    except socket.gaierror:
        return "IP not found"

# Process single URL
async def process_url(url, session, output, ip_output, retries=3):
    url = validate_url(url.strip())
    for attempt in range(retries):
        try:
            async with session.head(url, timeout=aiohttp.ClientTimeout(total=10)) as response:
                status = response.status
                server = response.headers.get("server", "Unknown")
                ip = get_ip(url)

                # Save results
                output.append(f"{url}: {status}")
                ip_output.append(f"{ip}")

                # Print results
                if status == 200:
                    print(f"{bcolors.OKGREEN}[200 OK]{bcolors.ENDC} {url} | Server: {server} | IP: {ip}")
                elif status in [301, 302, 308]:
                    print(f"{bcolors.OKCYAN}[{status} Redirect]{bcolors.ENDC} {url} | Server: {server} | IP: {ip}")
                elif status == 403:
                    print(f"{bcolors.WARNING}[403 Forbidden]{bcolors.ENDC} {url} | Server: {server} | IP: {ip}")
                else:
                    print(f"{bcolors.FAIL}[{status} Error]{bcolors.ENDC} {url} | Server: {server} | IP: {ip}")
                return
        except (aiohttp.ClientError, asyncio.exceptions.TimeoutError) as e:
            print(f"{bcolors.WARNING}[Attempt {attempt + 1}]{bcolors.ENDC} {url} - {str(e)}")
        except asyncio.exceptions.CancelledError:
            print(f"{bcolors.FAIL}[Cancelled]{bcolors.ENDC} {url} - Request cancelled unexpectedly")
            return
        await asyncio.sleep(2)  # Wait before retrying
    print(f"{bcolors.FAIL}[Failed]{bcolors.ENDC} {url} - All retries exhausted")

# Main function
async def main(file_path):
    try:
        # Read URLs from file
        with open(file_path, 'r') as f:
            urls = f.readlines()

        # Prepare outputs
        output = []
        ip_output = []

        async with aiohttp.ClientSession() as session:
            tasks = [process_url(url, session, output, ip_output) for url in urls]
            await asyncio.gather(*tasks)

        # Save to files
        output_file = f"results/output_{file_path}.txt"
        ip_file = f"results/ip_{file_path}.txt"

        with open(output_file, 'w') as out_f, open(ip_file, 'w') as ip_f:
            out_f.write("\n".join(output))
            ip_f.write("\n".join(ip_output))

        print(f"\nResults saved in: {output_file}")
        print(f"IP addresses saved in: {ip_file}")

    except FileNotFoundError:
        print(f"{bcolors.FAIL}Error: File not found!{bcolors.ENDC}")

# Entry point
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"{bcolors.FAIL}Usage: python3 script.py yourfile.txt{bcolors.ENDC}")
    else:
        asyncio.run(main(sys.argv[1]))
