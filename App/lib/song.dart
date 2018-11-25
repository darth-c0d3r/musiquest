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

  String link = 'https://www.cse.iitb.ac.in/~rathi/audios/perfect-slumbers.mp3';

  String status = 'Loading...';
  final config cfg = new config();
  dynamic song_data = <dynamic>[];
  int _data = 0;

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
      });
    });

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
      return PlayerWidget(url: link, id: widget.song.id,);
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
              SizedBox(height: 24.0),
              new Expanded(
                child: SingleChildScrollView(
                  child: new Container(
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
                              new InkWell(
                                child: new Text(
                                  'Prev',
                                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                onTap: () {
                                  final Ids prev_song = widget.song;
                                  if(widget.song.idx >= 0){
                                    prev_song.idx = (widget.song.idx + widget.song.lists.length - 1)%widget.song.lists.length;
                                    prev_song.id = '${widget.song.lists[prev_song.idx]['song_id']}';
                                  }
                                  Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => SongPage(song: prev_song,)));
                                },
                              ),

                              SizedBox(width: 32.0,),

                              dataValues(
                                  'num_views',' Views',
                                  TextStyle(color: Colors.white, fontSize: 16.0),
                                  TextAlign.center
                              ),

                              SizedBox(width: 32.0,),

                              new InkWell(
                                child: new Text(
                                  'Next',
                                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                onTap: () {
                                  final Ids prev_song = widget.song;
                                  if(widget.song.idx >= 0){
                                    prev_song.idx = (widget.song.idx + 1)%widget.song.lists.length;
                                    prev_song.id = '${widget.song.lists[prev_song.idx]['song_id']}';
                                  }
                                  Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => SongPage(song: prev_song,)));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
