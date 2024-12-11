from os import system
from main.style import *
from tool.tts import *
from tool.ports import *
from tool.base64 import *
from tool.check.Potin import *

RC, GC, YC, CC, DF = '\033[1;31m', '\033[1;32m', '\033[1;33m', '\033[1;36m', '\033[1;37m'

def menu1():
	system('clear')
	print(f'''
            
            {RC}╭━━━━╮{GC}╱╱╱╱{RC}╭╮{GC}╱╱╱╱╱{RC}╭━━━╮
            {RC}┃╭╮╭╮┃{GC}╱╱╱╱{RC}┃┃{GC}╱╱╱╱╱{RC}┃╭━╮┃
            ╰╯┃┃┣┻━┳━━┫┃{GC}╱╱╱╱╱{RC}┃╰━╯┃
            {GC}╱╱{RC}┃┃┃╭╮┃╭╮┃┃{GC}╱{RC}╭━━╮┃╭╮╭╯
            {GC}╱╱{RC}┃┃┃╰╯┃╰╯┃╰╮╰━━╯┃┃┃╰╮
            {GC}╱╱{RC}╰╯╰━━┻━━┻━╯{GC}╱╱╱╱{RC}╰╯╰━╯{DF}''')
	vers()
	print(f"                   {YC}القائمة الرئيسية{DF}\n")
	print(f"  {GC}[{YC}1{GC}] {RC}النص إلى الكلام         {GC}[{YC}2{GC}] {RC}ماسح المنفذ{DF}\n")
	print(f"  {GC}[{YC}3{GC}] {RC}ترميز Base64          {GC}[{YC}4{GC}] {RC}فك تشفير Base64{DF}\n")
	print(f"                 {GC}[{YC}+{GC}] {RC}Credit")
	print(f"                  {GC}[{YC}0{GC}] {RC}Exit")
	
	option = input(f" {YC}>>> {DF}")
	if option == "1":
		textspeech()
	elif option == "2":
		portSc()
	elif option == "3":
		enco()
	elif option == "4":
		deco()
	elif option == "0":
		system("clear")
	else:
		print(f"           {YC}الرجاء إدخال الإدخال الصحيح {DF}")
		sleep(8)
		menu1()
		exit()
