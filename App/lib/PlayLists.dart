import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'home.dart';
import 'PlayListInfo.dart';

class PlaylistsPage extends StatefulWidget {
  PlaylistsPage({Key key, this.uname, this.type, this.song_id}) : super(key: key);

  final String uname;
  final int type;
  final String song_id;
  PlaylistsPageState createState() => new PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> {

  final Session s = new Session();

  String status = 'Loading...';
  final config cfg = new config();
  dynamic playlists_data = <dynamic>[];
  bool _data = false;
  TextEditingController plName = new TextEditingController();

  Future getDataString(String url) async {
    return (await s.get(url));
  }

  Future<void> AddToPlay(BuildContext context) async {
    if(widget.type != 0)
      return null;
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Playlist Name'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  new TextFormField(
                    controller: plName,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter PlayListName';
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Create!'),
                onPressed: () {
                  if(widget.type == 0){
                    dynamic data = {
                      'name': plName.text
                    };
                    s.post(cfg.crtpl, data).then((ret){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PlaylistsPage(uname: widget.uname, type: 0, song_id : "-1")));
                    });
                  }
                },
              ),
            ],
          );
        }
    );
  }

  Future<void> DeletePlay(BuildContext context, dynamic data) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Playlist?'),
            actions: <Widget>[
              FlatButton(
                child: Text('CONFIRM'),
                onPressed: () {
                  s.post(cfg.rmvpl, data).then((ret){
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PlaylistsPage(uname: widget.uname, type: 0, song_id : "-1")));
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

  String titles() {
    if(widget.type == 0) return 'My PlayLists';
    return 'Add To Playlist';
  }

  Widget buildAppbar(BuildContext context) {
    return new AppBar(
      bottomOpacity: 0.0,
      title: Text(titles(), style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if(widget.type == 0)
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(uname: widget.uname)));
          else
            Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.playlist_add),
          onPressed: () {
            AddToPlay(context);
          }
        ),
      ],
    );
  }

  Widget buildList(BuildContext context) {
    return  ListView.builder(
      padding: const EdgeInsets.all(16.0),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        if(i.isOdd) return Divider(height: 16.0,color: Colors.white,);
        final index = i ~/2;
        return _buildRow(playlists_data[index], context);
      },
      itemCount:2*playlists_data.length,
    );
  }

  Widget _buildRow(dynamic d,BuildContext context) {
    return new ListTile(
      leading: new IconButton(
        icon: Icon(Icons.playlist_add_check),
        color: Colors.white,
        iconSize: 24.0,
        onPressed: () {
          if(widget.type == 0){
            final Ids song = new Ids();
            if(_data){
              song.uname = widget.uname;
              song.id = '${d['playlist_id']}';
              song.idx = null;
              song.lists = d;
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlayListInfoPage(playlist: song,)));
            }
          } else {
            dynamic data = {
              'song_id': widget.song_id,
              'playlist_id': '${d['playlist_id']}'
            };
            s.post(cfg.UpdtList, data).then((ret){
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully Added to playlist!'),
                ),
              );
            });
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
          if(widget.type == 0){
            final Ids song = new Ids();
            if(_data){
              song.uname = widget.uname;
              song.id = '${d['playlist_id']}';
              song.idx = null;
              song.lists = d;
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlayListInfoPage(playlist: song,)));
            }
          } else {
            dynamic data = {
              'song_id': widget.song_id,
              'playlist_id': '${d['playlist_id']}'
            };
            s.post(cfg.UpdtList, data).then((ret){
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully Added to playlist!'),
                ),
              );
            });
          }
        },
      ),
      trailing: deleted('${d['playlist_id']}', context, '${d['playlist_type']}'),
    );
  }


  Widget deleted(var id, BuildContext context2, var type) {
    if(widget.type == 0 && type != '2') {
      return new IconButton(
          icon: new Icon(Icons.delete, color: Colors.white, size: 24.0,),
          onPressed: (){
            dynamic data = {
              'playlist_id' : id
            };
            DeletePlay(context2, data);
          }
      );
    } else
      return null;
  }

  void getDetails() {
    dynamic data = {
      'type': widget.type.toString(),
    };
    s.post(cfg.APList, data).then((ret){
      Map<String,dynamic> det = json.decode(ret);

      if ('${det['status']}' == 'true') {
        playlists_data.clear();
        for (var row in det['data']) {
          playlists_data.add(row);
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
      appBar: buildAppbar(context),

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
                    child: buildList(context),
                  )
              ),

            ],
          ),
        ],
      ),
    );
  }
}