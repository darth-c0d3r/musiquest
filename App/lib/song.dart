import 'package:flutter/material.dart';
import 'player_widget.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'home.dart';
import 'PlayLists.dart';

class SongPage extends StatefulWidget {
  SongPage({Key key, this.song}) : super(key: key);

  final Ids song;
  SongPageState createState() => new SongPageState();
}

class SongPageState extends State<SongPage> {

  final Session s = new Session();

  String link = 'https://www.cse.iitb.ac.in/~rathi/audios/audio1.mp3';

  String status = 'Loading...';
  final config cfg = new config();
  dynamic song_data = <dynamic>[];
  int _data = 0;
  bool mute = false;
  bool lyrics = false;

  Future getDataString(String url) async {
    return (await s.get(url));
  }

  Widget dataValues(String s, String next,TextStyle t, TextAlign a) {
    if(_data <= 0){
      return Text(
        status,
      );
    } else {
      return Text(
        song_data[0][s].toString()+next,
        style: t,
        textAlign: a,
      );
    }
  }

  Widget buildAppbar() {
    return new AppBar(
      bottomOpacity: 0.0,
      title: dataValues('album_name','', TextStyle(color: Colors.white), TextAlign.center),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if(_data > 0 && widget.song.idx >= 0){
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uname: widget.song.uname)));
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: mute ? Icon(Icons.volume_off) : Icon(Icons.volume_up),
          onPressed: (){
            setState(() {
              mute =  !mute;
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.playlist_add,
            //size: 32.0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlaylistsPage(uname: widget.song.uname, type: 1, song_id: widget.song.id)));
          },
          color: Colors.white,
        ),
      ],
    );
  }


  void getDetails() {
    dynamic data = {
      'song_id': widget.song.id,
    };

    s.post(cfg.song, data).then((ret){
      Map<String,dynamic> det = json.decode(ret);

      if ('${det['status']}' == 'true') {
        song_data.clear();
        for (var row in det['data']) {
          song_data.add(row);
        }
      } else {
        setState(() {
          status = '${det['message']}';
        });
      }
      setState(() {
        _data = 1;
        link = song_data[0]['youtube_link'];
        print(song_data[0]['relation_type']);
      });
    });

  }

  Widget buildSongBody(){
    if(lyrics){
      return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        margin: const EdgeInsets.symmetric(horizontal: 40.0),
        color: Colors.purpleAccent,
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Text(
                'Lyrics',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),
              ),
              SizedBox(height: 12.0),
              new Text(
                song_data[0]['lyrics_link'],
                style: TextStyle(color: Colors.white,),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    'Swipe For Lyrics',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 8.0,),
                  new Image.asset(
                    'icon/left-swipe.gif',
                    height: 16.0,
                  ),
                ],
              ),
              SizedBox(height: 8.0,),
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                margin: const EdgeInsets.symmetric(horizontal: 40.0),
                color: Colors.purpleAccent,
                child: new Center(
                  child: new Column(
                    children: <Widget>[
                      new Image.asset(
                        'icon/song.png',
                        height: 240.0,
                      ),

                      dataValues(
                          'name','',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28.0),
                          TextAlign.center
                      ),

                      dataValues(
                          'artist_name','',
                          TextStyle(color: Colors.white, fontSize: 20.0),
                          TextAlign.center
                      ),

                      SizedBox(height: 24.0),

                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          dataValues(
                              'num_views',' Views',
                              TextStyle(color: Colors.white, fontSize: 16.0),
                              TextAlign.center
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    getDetails();
  }

  Widget playSong() {
    if(_data <= 0) {
      return Text(status);
    } else {
      return PlayerWidget(
          url: link, id: widget.song.id,
          song: widget.song, mute: mute, type: song_data[0]['relation_type']);
    }
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8.0),
              new Expanded(
                child: SingleChildScrollView(
                  child: new GestureDetector(
                    child: buildSongBody(),
                    onHorizontalDragEnd: (DragEndDetails details){
                      if (details.velocity.pixelsPerSecond.dx < -100.0 && !lyrics) {
                        setState(() {
                          lyrics = true;
                        });
                      }
                      else if(details.velocity.pixelsPerSecond.dx > 100.0 && lyrics){
                        setState(() {
                          lyrics = false;
                        });
                      }
                    },
                  ),
                ),
              ),

              playSong(),
            ],
          ),
        ],
      ),
    );
  }
}
