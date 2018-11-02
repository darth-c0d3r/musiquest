import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'home.dart';

class SongPage extends StatefulWidget {
  SongPage({Key key, this.song}) : super(key: key);
  @override
  final Song song;
  SongPageState createState() => new SongPageState();
}

class SongPageState extends State<SongPage> {

  final Session s = new Session();

  final String link = 'https://www.youtube.com/watch?v=v2H4l9RpkwM';
  AudioPlayer advancedPlayer = new AudioPlayer();

  final config cfg = new config();

  Future getDataString(String url) async {
    return (await s.get(url));
  }

  @override
  Widget buildAppbar() {
    return new AppBar(
      title: const Text(
        'Song Home',
      ),
      centerTitle: true,
//      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.playlist_add,
            //size: 32.0,
          ),
          onPressed: () {
            setState(() {

            });
          },
          color: Colors.white,
        ),
      ],
    );
  }

  void playYoutubeVideo() {
    FlutterYoutube.playYoutubeVideoByUrl(
      apiKey: "<API_KEY>",
      videoUrl: link,

    );
  }

  @override
  void initState() {
    super.initState();

    playYoutubeVideo();
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
            //mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 16.0,),
//              new Expanded(
//                  child: new Container(
//                    child: buildType(), //_buildList(song_views),
//                  )
//              ),
//              buildBottombar(), // Bottom bar build
            ],
          ),
        ],
      ),
    );
  }
}

class Song {
  String uname;
  var id;
}