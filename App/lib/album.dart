import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'home.dart';
import 'song.dart';

class AlbumPage extends StatefulWidget {
  AlbumPage({Key key, this.album}) : super(key: key);

  final Ids album;
  AlbumPageState createState() => new AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {

  final Session s = new Session();

  String status = 'Loading...';
  final config cfg = new config();
  dynamic album_data = <dynamic>[];
  dynamic songs = <dynamic>[];
  int _data = 0;
  var up = 0;
  var ups = 0;
  var dns = 0;
  var dn = 0;
  var value = 0;
  Color up_color = Colors.white;
  Color dn_color = Colors.white;

  Future getDataString(String url) async {
    return (await s.get(url));
  }

  Widget dataValues(String s, String prefix,TextStyle t, TextAlign a) {
    if(_data <= 0){
      return Text(
        status,
      );
    } else {
      return Text(
        prefix + album_data[0][s].toString(),
        style: t,
        textAlign: a,
      );
    }
  }

  Widget buildAppbar() {
    return new AppBar(
      bottomOpacity: 0.0,
      title: dataValues('name','', TextStyle(color: Colors.white), TextAlign.center),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if(widget.album.idx == 0)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uname: widget.album.uname)));
          else
            Navigator.pop(context);
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
        return _buildRow(songs[index],index,songs);
      },
      itemCount:2* songs.length,
    );
  }

  Widget _buildRow(dynamic d, int idx, dynamic lists) {
    return GestureDetector(
      onTap: () {
        final Ids song = new Ids();
        if(_data == 1){
          song.uname = widget.album.uname;
          song.id = '${d['song_id']}';
          song.idx = idx;
          song.lists = lists;
          Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage(song: song,)));
        }
      },

      child: new ListTile(
        leading: new Image.asset(
          'icon/song.png',
          height: 32.0,
        ),
        title: new Text(
          '${d['name']}',
          textAlign: TextAlign.left,
          style: TextStyle( color: Colors.white),
          // overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void getDetails() {
    dynamic data = {
      'album_id': widget.album.id,
    };

    s.post(cfg.album, data).then((ret){
      Map<String,dynamic> det = json.decode(ret);

      if ('${det['metadata']['status']}' == 'true') {
        album_data.clear();
        for (var row in det['metadata']['data']) {
          album_data.add(row);
        }
        if ('${det['songs']['status']}' == 'true') {
          songs.clear();
          for (var row in det['songs']['data']) {
            songs.add(row);
          }
        } else {
          setState(() {
            status = '${det['songs']['message']}';
          });
        }
        setState(() {
          ups = album_data[0]['num_likes'];
          dns = album_data[0]['num_dislikes'];
          if(album_data[0]['relation_type']==1){
            up=1;
            up_color = Colors.green;
          } else if(album_data[0]['relation_type']==-1){
            dn=1;
            dn_color = Colors.red;
          }
        });
      } else {
        setState(() {
          status = '${det['metadata']['message']}';
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
              new Column(
                children: <Widget>[
                  dataValues('artist_name', 'Artist: ', TextStyle(color: Colors.white), TextAlign.left),
                  new Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new IconButton(
                        onPressed: (){
                          setState(() {
                            value = up*(-1) + (1-up)*(1+dn);
                            dn_color = Colors.white;
                            if(up==1){
                              setState(() {
                                if(ups>0)ups--;
                              });
                              up=0;
                              up_color = Colors.white;
                            }
                            else{
                              setState(() {
                                ups++;
                              });
                              up=1;
                              up_color = Colors.green;
                            }
                            dynamic data = {
                              'album_id': widget.album.id,
                              'value': value.toString(),
                            };
                            print(value);
                            s.post(cfg.updateAlbum, data).then((ret){

                            });
                            setState(() {
                              if(dn==1 && dns > 0)dns--;
                            });
                            dn=0;
                          });
                        },
                        icon: new Icon(Icons.thumb_up
                        ),
                        color: up_color,
                      ),
                      dataValues(
                        'num_views', 'Views: ',
                        TextStyle(color: Colors.white,fontSize: 16.0,), TextAlign.left),
                      new IconButton(
                          onPressed: (){
                            setState(() {
                              value = dn*(1) - (1-dn)*(1+up);
                              up_color = Colors.white;
                              if(dn==1){
                                setState(() {
                                  if(dns>0)dns--;
                                });
                                dn=0;
                                dn_color = Colors.white;
                              }
                              else{
                                setState(() {
                                  dns++;
                                });
                                dn=1;
                                dn_color = Colors.red;
                              }

                              dynamic data = {
                                'album_id': widget.album.id,
                                'value': value.toString(),
                              };
                              s.post(cfg.updateAlbum, data).then((ret){

                              });
                              setState(() {
                                if(up==1 && ups > 0)ups--;
                              });
                              up = 0;
                            });
                          },
                          icon: new Icon(Icons.thumb_down),
                          color: dn_color
                      ),
                    ],
                  ),

                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Likes: ' +  ups.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 32.0,),
                      Text(
                        'Dislikes: ' + dns.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}