drop schema public cascade;
create schema public;

create table artist (
	artist_id serial primary key,
	name varchar(256) not null,
	num_views integer default 0,
	num_likes integer default 0,
	num_dislikes integer default 0
);

create table album (
	album_id serial primary key,
	name varchar(256) not null,
	artist_id integer references artist on delete cascade,
	num_views integer default 0,
	num_likes integer default 0,
	num_dislikes integer default 0	
);

create table song (
	song_id serial primary key,
	name varchar(256) not null,
	album_id integer references album on delete cascade,
	artist_id integer references artist on delete cascade,
	genre varchar(20),
	release_date integer, 
	language varchar(30),
	lyrics_link text,
	youtube_link varchar(256) not null,
	num_views integer default 0,
	num_likes integer default 0,
	num_dislikes integer default 0
);

create table users (
	user_id serial primary key,
	username varchar(32) unique not null,
	password varchar(64) not null,
	salt varchar(64) not null
);

create table admin (
	user_id serial primary key,
	username varchar(32) unique not null,
	password varchar(64) not null,
	salt varchar(64) not null
);

create table user_playlist (
	playlist_id serial primary key,
	user_id integer references users on delete cascade,
	name varchar(256) not null,
	playlist_type integer default 0
);

create table user_album (
	album_id integer references song on delete cascade,
	user_id integer references users on delete cascade,
	relation_type integer default 0,
	num_views integer default 1,
	primary key (user_id, album_id)
);

create table user_artist (
	artist_id integer references song on delete cascade,
	user_id integer references users on delete cascade,
	relation_type integer default 0,
	num_views integer default 1,
	primary key (user_id, artist_id)
);

create table user_song (
	song_id integer references song on delete cascade,
	user_id integer references users on delete cascade,
	relation_type integer default 0,
	num_views integer default 1,
	last_viewed timestamp default current_timestamp,
	primary key (user_id, song_id)
);

create table song_playlist (
	song_id integer references song on delete cascade,
	playlist_id integer references user_playlist on delete cascade,
	time_added timestamp default current_timestamp,
	primary key (playlist_id, song_id)
);

create extension pg_trgm;