#!/bin/bash

head -n 10000 ../dataset/data_file_lyrics.txt > temp_top

awk 'BEGIN 	{FS="\t";} {print $1}' temp_top | sort | uniq > temp
awk 'NR <= 10000 {print "insert into artist(name) values ('\''"$0"'\'');"}' temp > insert_data_lyrics.sql

awk 'BEGIN {FS="\t";} {print $1"\t"$2}' temp_top | sort | uniq > temp
awk 'BEGIN {FS="\t";} NR <= 10000 {print "insert into album(name, artist_id) select '\''"$2"'\'', artist_id from artist where artist.name = '\''"$1"'\'';"}' temp >> insert_data_lyrics.sql

awk 'BEGIN {FS="\t";} NR <= 10000 {
		var4 = "'\''"$4"'\'',";
		if($4 == "#") var4 = NULL;
		var5 = "'\''"$5"'\'',";
		if($5 == "#") var5 = NULL;
		var6 = "'\''"$6"'\'',";
		if($6 == "#") var6 = NULL;
		var7 = "'\''"$7"'\'',";
		var8 = "'\''"$8"'\''";
		if($8 == "#") var8 = NULL;	
		if($3 == "#"){
			print "insert into song(name, album_id, artist_id, release_date, genre, lyrics_link, youtube_link, language) select '\''"$3"'\'', NULL, artist_id, ",var4,var5,var6,var7,var8,"from artist where artist.name = '\''"$1"'\'';"	
		} else {
			print "insert into song(name, album_id, artist_id, release_date, genre, lyrics_link, youtube_link, language) select '\''"$3"'\'', album.album_id, artist.artist_id, ",var4,var5,var6,var7,var8,"from album join artist on album.artist_id = artist.artist_id where artist.name = '\''"$1"'\'' and album.name = '\''"$2"'\'';"
		}
}' temp_top >> insert_data_lyrics.sql

rm temp
rm temp_top