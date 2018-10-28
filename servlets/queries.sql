-- most viewed songs
select song_id, name from song order by num_views desc limit 10;
-- most liked songs
select album_id, name from album order by num_views desc limit 10;
-- most liked albums
select album_id, name from album order by num_likes desc limit 10;
-- most liked artists
select artist_id, name from artist order by num_likes desc limit 10;
-- recent songs
select song_id, name from song order by release_date desc limit 10;
-- most viewed album
select album.album_id, album.name, sum(song.num_views) + album.num_views as total_views from album join song on album.album_id = song.album_id group by album.album_id, album.name order by total_views desc limit 10;
-- most viewed artist
select artist.artist_id, artist.name, sum(song.num_views) + artist.num_views as total_views from artist join song on artist.artist_id = song.artist_id group by artist.artist_id, artist.name order by total_views desc limit 10;