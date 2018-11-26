import urllib.request
from bs4 import BeautifulSoup
import re

def strip(name):
	name = re.sub(r'^a ','',name)
	name = re.sub(r'^an ','',name)
	name = re.sub(r'^the ','',name)
	return name

def convert(name):
	name = re.sub(r'[^a-z0-9]', '', name)
	return name

songs_file = "../dataset/songs.txt"
artists_file = "../dataset/artists.txt"

songs = [line.rstrip('\n') for line in open(songs_file)]
artists = [line.rstrip('\n') for line in open(artists_file)]

index = 0
for song, artist in zip(songs[0:10], artists[0:10]):

	song_ = convert(song.lower())
	artist_ = convert(strip(artist.lower()))
	lyrics_file = "../dataset/lyrics/lyrics_" + str(index) + ".txt"

	url = "https://www.azlyrics.com/lyrics/" + artist_ + "/" + song_ + ".html"

	try:
		html = urllib.request.urlopen(url).read()
		with open(lyrics_file, "w+") as file:
			file.write(BeautifulSoup(html, 'html.parser').find_all('div')[21].text)
		print("Found for %d"%(index))
	except:
		with open(lyrics_file, "w+") as file:
			file.write("#")
		print("Not found for %d"%(index))
	index += 1