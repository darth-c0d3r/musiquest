import urllib.request
from bs4 import BeautifulSoup
import re

def convert(name):
	name = re.sub(r'[^a-z0-9 ]', '', name)
	return name

songs_file = "../dataset/songs.txt"
artists_file = "../dataset/artists.txt"
youtube_file = "../dataset/youtube_links.txt"

songs = [line.rstrip('\n') for line in open(songs_file)]
artists = [line.rstrip('\n') for line in open(artists_file)]

done = 0
with open(youtube_file, "w+") as file:
	for song_, artist_ in zip(songs, artists):

		song = convert(song_.lower()).split()
		artist = convert(artist_.lower()).split()

		url = "https://www.youtube.com/results?search_query="

		for word in song+artist:
			url = url+word+"+"
		url = url[:-1]

		try:
			headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0'}
			req = urllib.request.Request(url, headers = headers)
			html = urllib.request.urlopen(req).read()
			youtube = BeautifulSoup(html, 'html.parser').find_all(class_='yt-uix-tile-link')
			youtube = "https://www.youtube.com" + youtube[0].get('href')
			# print(youtube)
			file.write(youtube+"\n")
		except:
			file.write("#\n") # failed
		done += 1
		print(done)