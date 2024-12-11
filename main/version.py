import subprocess
from time import sleep
from os import system, getuid, path
import requests
from subprocess import check_output
from main.style import *

RC, GC, YC, CC, DF = '\033[1;31m', '\033[1;32m', '\033[1;33m', '\033[1;36m', '\033[1;37m'

def verCheck():
	system('clear')
	print(f'''
            
            {RC}╭━━━━╮{GC}╱╱╱╱{RC}╭╮{GC}╱╱╱╱╱{RC}╭━━━╮
            {RC}┃╭╮╭╮┃{GC}╱╱╱╱{RC}┃┃{GC}╱╱╱╱╱{RC}┃╭━╮┃
            ╰╯┃┃┣┻━┳━━┫┃{GC}╱╱╱╱╱{RC}┃╰━╯┃
            {GC}╱╱{RC}┃┃┃╭╮┃╭╮┃┃{GC}╱{RC}╭━━╮┃╭╮╭╯
            {GC}╱╱{RC}┃┃┃╰╯┃╰╯┃╰╮╰━━╯┃┃┃╰╮
            {GC}╱╱{RC}╰╯╰━━┻━━┻━╯{GC}╱╱╱╱{RC}╰╯╰━╯{DF}''')
	vers()
	print(f"  {YC}فحص التحديثات.........!{DF}")
	ver_url = "https://raw.githubusercontent.com/info-devf5r/Tool-F5R/master/version.txt"
	ver_rqst = requests.get(ver_url)
	ver_sc = ver_rqst.status_code
	if ver_sc == 200:
		with open('version.txt') as t:
			ver_current = t.read()
			ver_current = ver_current.strip()
			github_ver = ver_rqst.text
			github_ver = github_ver.strip()
		if ver_current == github_ver:
			print(f"  {GC}[Up To Date] {CC} v. {YC}{github_ver}{DF}")
			sleep(5)
		else:
			print(f"  {YC}[+] هناك نسخة جديدة متاحة ..!{DF}\n")
			print(f"  {RC} الحالي الخامس - {YC}{ver_current}{DF}")
			print(f"  {GC} جديد متاح الخامس -{YC}{github_ver}{DF}")
			print(f"  {YC} جارٍ التحديث إلى الإصدار الأحدث، يرجى الانتظار....! {DF}")
			system("git clean -d -f > /dev/null && git pull -f > /dev/null")
			with open('version.txt') as t:
				ver_current = t.read()
				ver_current = ver_current.strip()
			print(f"  {GC}حالة الإصدار بعد التحديث{DF}\n")
			print(f"  {YC}الإصدار الحالي الخامس - {GC}{ver_current}{DF}")
			print(f"  {GC} الإصدار المتاح الخامس - {GC}{github_ver}{DF}")
			sleep(5)
			system('clear')
	else:
		print(f"  {RC}فشل في الحصول على التحديث")
