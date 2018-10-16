import urllib.request
from bs4 import BeautifulSoup
import re

def convert(name):
	name = re.sub(r'[^a-z0-9 ]', '', name)
	return name

songs_file = "songs.txt"
artists_file = "artists.txt"
albums_file = "albums.txt"

songs = [line.rstrip('\n') for line in open(songs_file)]
artists = [line.rstrip('\n') for line in open(artists_file)]

with open(albums_file, "w") as file:
	for song_, artist_ in zip(songs, artists):

		song = convert(song_.lower()).split()
		artist = convert(artist_.lower()).split()

		url = "https://www.google.co.in/search?q="

		for word in song+artist:
			url = url+word+"+"
		url = url + "album"

		try:
			headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0'}
			req = urllib.request.Request(url, headers = headers)
			html = urllib.request.urlopen(req).read()
			album = BeautifulSoup(html, 'html.parser').find('div', class_="Z0LcW").text
			file.write(album+"\n")
		except:
			try:
				headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0'}
				req = urllib.request.Request(url+"+name", headers = headers)
				html = urllib.request.urlopen(req).read()
				album = BeautifulSoup(html, 'html.parser').find('div', class_="Z0LcW").text
				file.write(album+"\n")
			except:
				file.write("#\n") # most probably a single song