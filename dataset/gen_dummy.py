import random
import string

total = 75262

link_prefix = 'https://www.cse.iitb.ac.in/~rathi/audios/audio'

albums = ["Album " + str(alpha) for alpha in string.ascii_uppercase]
release_dates = [n for n in range(1990,2020)]
genres = ['rock', 'classic', 'blues', 'rap', 'electric']
lyrics_links = ['a1', 'a2', 'a3', 'a4', 'a5']
youtube_links = [link_prefix+str(i+1)+'.mp3' for i in range(7)]
languages = ['english', 'hindi', 'punjabi', 'japanese']

artists_file = open('artists2.txt', 'r')
albums_file = open('albums.txt','w+')
songs_file = open('songs2.txt', 'r')
release_dates_file = open('release_dates.txt','w+')
genres_file = open('genres.txt','w+')
lyrics_links_file = open('lyrics_links.txt','w+')
youtube_links_file = open('youtube_links.txt','w+')
languages_file = open('languages.txt','w+')
data_file = open('data_file.txt', 'w+')
songs = songs_file.readlines()
artists = artists_file.readlines()

for i in range(total):
	album = albums[random.randint(0,len(albums)-1)]
	release_date = release_dates[random.randint(0,len(release_dates)-1)]
	genre = genres[random.randint(0,len(genres)-1)]
	lyrics_link = lyrics_links[random.randint(0,len(lyrics_links)-1)]
	youtube_link = youtube_links[random.randint(0,len(youtube_links)-1)]
	language = languages[random.randint(0,len(languages)-1)]

	albums_file.write(album+"\n")
	release_dates_file.write(str(release_date)+"\n")
	genres_file.write(genre+"\n")
	lyrics_links_file.write(lyrics_link+"\n")
	youtube_links_file.write(youtube_link+"\n")
	languages_file.write(language+"\n")
	data_file.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n"%(artists[i].strip(),album,songs[i].strip(),release_date,genre,lyrics_link,youtube_link,language))

albums_file.write("\b")
release_dates_file.write("\b")
genres_file.write("\b")
lyrics_links_file.write("\b")
youtube_links_file.write("\b")
languages_file.write("\b")

artists_file.close()
albums_file.close()
release_dates_file.close()
genres_file.close()
lyrics_links_file.close()
youtube_links_file.close()
languages_file.close()
data_file.close()