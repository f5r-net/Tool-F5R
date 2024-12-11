import gtts
import os
import sys
from os import system
from time import sleep
from main.style import *

RC, GC, YC, CC, DF = '\033[1;31m', '\033[1;32m', '\033[1;33m', '\033[1;36m', '\033[1;37m'

def textspeech():
	system('clear')
	print(f'''
            
            {RC}╭━━━━╮{GC}╱╱╱╱{RC}╭╮{GC}╱╱╱╱╱{RC}╭━━━╮
            {RC}┃╭╮╭╮┃{GC}╱╱╱╱{RC}┃┃{GC}╱╱╱╱╱{RC}┃╭━╮┃
            ╰╯┃┃┣┻━┳━━┫┃{GC}╱╱╱╱╱{RC}┃╰━╯┃
            {GC}╱╱{RC}┃┃┃╭╮┃╭╮┃┃{GC}╱{RC}╭━━╮┃╭╮╭╯
            {GC}╱╱{RC}┃┃┃╰╯┃╰╯┃╰╮╰━━╯┃┃┃╰╮
            {GC}╱╱{RC}╰╯╰━━┻━━┻━╯{GC}╱╱╱╱{RC}╰╯╰━╯{DF}''')
	vers()
	ttst = input(f"{GC}إدخال النص لإنشاء ملف تحويل النص إلى كلام mp3 \n  {YC}>>>{DF} ")
	ttsn = input(f"\n{GC}أدخل اسمًا لإخراج mp3 بامتداد .mp3 \n   {YC}>>>{DF} ")

	tts = gtts.gTTS(ttst, lang='en')

	tts.save(ttsn)
	os.system('play-audio' + ' ' + ttsn)
	print(f'{RC}حفظ الملف الصوتي في الدليل الحالي باسم{DF} ',ttsn)
	sleep(5)
