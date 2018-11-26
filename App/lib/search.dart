import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'song.dart';
import 'album.dart';
import 'artist.dart';
import 'home.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.uname, this.queue_id}) : super(key: key);

  final String uname;
  final String queue_id;
  SearchPageState createState() => new SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final Session s = new Session();

  dynamic songs = <dynamic>[];
  dynamic albums = <dynamic>[];
  dynamic artists = <dynamic>[];

  String loading = "Enter Search key...";
  int _data = 0;
  String key = '';
  int special = 0;

  final config cfg = new config();

  Future<void> AddToQueue(BuildContext context, var songId) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add to Queue?'),
            content: null,
            actions: <Widget>[
              FlatButton(
                child: Text('Add!'),
                onPressed: () {
                  dynamic data = {
                    'song_id': songId,
                    'playlist_id': widget.queue_id
                  };
                  s.post(cfg.UpdtList, data).then((ret){
                    print(ret);
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  Widget buildAppbar() {
    return new AppBar(
      title: new TextField(
        keyboardType: TextInputType.text,
        onChanged: (text) {
          setState(() {
            key = text;
            _data = 0;
          });
          special++;
          getvalues(key, special);
        },
        style: TextStyle(color: Colors.white, fontSize: 16.0),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          }
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            size: 32.0,
          ),
          onPressed: () {

          },
          color: Colors.white,
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    if (_data == 0) {
      return new Center(
        child: new Text(
          loading,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }
    else if(_data == 1) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(
                'Songs',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(songs, 1, context),
              ),
            ],
          ),

          new Column(
            children: <Widget>[
              new Text(
                'Albums',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(albums, 2, context),
              ),
            ],
          ),

          new Column(
            children: <Widget>[
              new Text(
                'Artists',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(artists, 3, context),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildList(dynamic each_row, int type, BuildContext context) {
    return  ListView.builder(
      padding: const EdgeInsets.all(16.0),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return _buildRow(each_row[i], type, context);
      },
      itemCount: each_row.length,
    );
  }

  Widget image(int type){
    String text = '';
    if(type == 1)
      text = 'icon/song.png';
    else if(type == 2)
      text = 'icon/album.png';
    else if(type == 3)
      text = 'icon/artist.png';

    return new Image.asset(
      text,
      height: 96.0,
    );
  }

  Widget _buildRow(dynamic d, int type, BuildContext context2){
    return GestureDetector(
      onTap: () {
        final Ids song = new Ids();
        song.idx = null;
        song.lists = null;
        if(type == 1){
          song.uname = widget.uname;
          song.id = '${d['song_id']}';
          song.idx = -1;
          dynamic single_list = <dynamic>[];
          single_list.add(d);
          song.lists = single_list;
          Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage(song: song,)));
        } else if(type == 2) {
          song.uname = widget.uname;
          song.idx = 0;
          song.id = '${d['album_id']}';
          Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPage(album: song,)));
        } else if(type == 3) {
          song.uname = widget.uname;
          song.id = '${d['artist_id']}';
          Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistPage(artist: song,)));
        }
      },

      onLongPress: () {
        if(type == 1){
          AddToQueue(context2, '${d['song_id']}');
        }
      },

      child: new Container(
        width: 120.0,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: new Column(
          children: <Widget>[
            image(type),

            new Text(
              '${d['name']}',
              textAlign: TextAlign.center,
              style: TextStyle( color: Colors.white),
              // overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void getvalues(var key, int curr){
    dynamic data = {
      'search_key': key
    };
    if(key == '') return;
    s.post(cfg.search, data).then((ret){
      print(ret);
      if(curr < special) return;
      Map<String, dynamic> det = json.decode(ret);
      songs.clear();
      albums.clear();
      artists.clear();

      if ('${det['albums']['status']}' == 'true') {
        for (var row in det['albums']['data']) {
          albums.add(row);
        }
      } else {
        setState(() {
          loading = '${det['albums']['message']}';
        });
      }

      if ('${det['artists']['status']}' == 'true') {
        for (var row in det['artists']['data']) {
          artists.add(row);
        }
      } else {
        setState(() {
          loading = '${det['artists']['message']}';
        });
      }

      if ('${det['songs']['status']}' == 'true') {
        for (var row in det['songs']['data']) {
          songs.add(row);
        }
      } else {
        setState(() {
          loading = '${det['songs']['message']}';
        });
      }
        setState(() {
          _data = 1;
        });
    });
  }

  @override
  void initState() {
    super.initState();

    getvalues(key, special);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        appBar: buildAppbar(),

        body: new Stack(
          children : <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('icon/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            new Column(
              //mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 16.0,),
                new Expanded(
                    child: new Container(
                      child: buildBody(context), //_buildList(song_views),
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}