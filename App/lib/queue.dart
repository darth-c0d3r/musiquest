import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'config.dart';
import 'song.dart';
import 'home.dart';

class QueuePage extends StatefulWidget {
  QueuePage({Key key, this.uname, this.queue_id}) : super(key: key);

  final String uname;
  final String queue_id;
  QueuePageState createState() => new QueuePageState();
}

class QueuePageState extends State<QueuePage> {

  final Session s = new Session();

  String loading = "Loading...";
  dynamic songs_data = <dynamic>[];
  bool _data = false;
  final config cfg = new config();

  Widget buildAppbar() {
    return new AppBar(
      bottomOpacity: 0.0,
      title: Text('My Queue', style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(uname: widget.uname)));
        },
      ),
    );
  }

  Widget buildSongs() {
    return  ListView.builder(
      padding: const EdgeInsets.all(16.0),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        if(i.isOdd) return Divider(height: 16.0,color: Colors.white,);
        final index = i ~/2;
        return _buildRow(songs_data[index],index,songs_data);
      },
      itemCount:2* songs_data.length,
    );
  }

  Widget _buildRow(dynamic d, int idx, dynamic lists) {
    return new ListTile(
      leading: new GestureDetector(
        child: new Image.asset(
          'icon/song.png',
          height: 32.0,
        ),
        onTap: (){
          final Ids song = new Ids();
          if(_data){
            song.uname = widget.uname;
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
            song.uname = widget.uname;
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
              'playlist_id' : widget.queue_id
            };
            s.post(cfg.rmvfrompl, data).then((ret){
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => QueuePage(uname: widget.uname,queue_id: widget.queue_id,)));
            });
          }
      ),
    );
  }

  void getDetails() {
    dynamic data = {
      'playlist_id': widget.queue_id,
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
          loading = '${det['message']}';
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
                    child: buildSongs(),
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
}