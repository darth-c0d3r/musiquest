import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'home.dart';
import 'song.dart';

class PlayListInfoPage extends StatefulWidget {
  PlayListInfoPage({Key key, this.playlist}) : super(key: key);

  final Ids playlist;
  PlayListInfoPageState createState() => new PlayListInfoPageState();
}

class PlayListInfoPageState extends State<PlayListInfoPage> {

  final Session s = new Session();

  String status = 'Loading...';
  final config cfg = new config();
  dynamic songs_data = <dynamic>[];
  bool _data = false;


  Future getDataString(String url) async {
    return (await s.get(url));
  }

  Future<void> DeleteFromPl(BuildContext context2, dynamic data) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete From Playlist?'),
            content: null,
            actions: <Widget>[
              FlatButton(
                child: Text('CONFIRM'),
                onPressed: () {
                  s.post(cfg.rmvfrompl, data).then((ret){
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context2) => PlayListInfoPage(playlist: widget.playlist,)));
                  });
                },
              ),
              FlatButton(
                child: Text('CANCEL'),
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
      bottomOpacity: 0.0,
      title: Text(widget.playlist.lists['name'], style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
            Navigator.pop(context);
        },
      ),
    );
  }

  Widget buildSongs(BuildContext context) {
    return  ListView.builder(
      padding: const EdgeInsets.all(16.0),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        if(i.isOdd) return Divider(height: 16.0,color: Colors.white,);
        final index = i ~/2;
        return _buildRow(songs_data[index],index,songs_data, context);
      },
      itemCount:2* songs_data.length,
    );
  }

  Widget _buildRow(dynamic d, int idx, dynamic lists, BuildContext context2) {
    return new ListTile(
        leading: new GestureDetector(
          child: new Image.asset(
            'icon/song.png',
            height: 32.0,
          ),
          onTap: (){
            final Ids song = new Ids();
            if(_data){
              song.uname = widget.playlist.uname;
              song.id = '${d['song_id']}';
              song.idx = idx;
              song.lists = lists;
              Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage(song: song,)));
            }
          },
        ),
        title: new InkWell(
          child: new Text(
            _data ? '${d['name']}' : '',
            textAlign: TextAlign.left,
            style: TextStyle( color: Colors.white),
          ),
          onTap: () {
            final Ids song = new Ids();
            if(_data){
              song.uname = widget.playlist.uname;
              song.id = '${d['song_id']}';
              song.idx = idx;
              song.lists = lists;
              Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage(song: song,)));
            }
          },
        ),
        trailing: new IconButton(
          icon: Icon(Icons.delete, color: Colors.white, size: 24.0,),
          onPressed: (){
            dynamic data = {
              'song_id': '${d['song_id']}',
              'playlist_id' : widget.playlist.id
            };
            DeleteFromPl(context2, data);
          }
        ),
    );
  }

  void getDetails() {
    dynamic data = {
      'playlist_id': widget.playlist.id,
    };

    s.post(cfg.playlist, data).then((ret){
      Map<String,dynamic> det = json.decode(ret);

      if ('${det['status']}' == 'true') {
        songs_data.clear();
        for (var row in det['data']) {
          songs_data.add(row);
        }
      } else {
        setState(() {
          status = '${det['message']}';
        });
      }
      setState(() {
        _data = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
            children: <Widget>[
              new Expanded(
                  child: new Container(
                    child: buildSongs(context),
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
}