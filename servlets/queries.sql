-- most viewed songs
select sond_id, name from songs order by num_views desc limit 10;
-- most liked songs
select sond_id, name from songs order by num_likes desc limit 10;
-- most viewed albums
select sond_id, name from albums order by num_views desc limit 10;
-- most liked albums
select sond_id, name from albums order by num_likes desc limit 10;
-- most viewed artists
select sond_id, name from artists order by num_views desc limit 10;
-- most liked artists
select sond_id, name from artists order by num_likes desc limit 10;

