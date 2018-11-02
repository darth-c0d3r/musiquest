import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'session.dart';
import 'config.dart';

class HomePage extends StatefulWidget {

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {

  final Session s = new Session();
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();

  dynamic song_views = <dynamic>[];
  dynamic song_likes = <dynamic>[];
  dynamic song_date = <dynamic>[];

  dynamic album_likes = <dynamic>[];
  dynamic album_views = <dynamic>[];

  dynamic artist_likes = <dynamic>[];
  dynamic artist_views = <dynamic>[];

  dynamic recently_played = <dynamic>[];

  String loading = "Loading...";
  int _data = 0;
  int search = 0;
  Color onTapColor3 =  Colors.white;
  Color onTapColor2 =  Colors.white;
  Color onTapColor1 =  Colors.white;

  final config cfg = new config();

  Future getDataString(String url) async {
    return (await s.get(url));
  }

  @override
  Widget bottomNames3() {
    return new Text(
      'Artists',
      style: TextStyle(color: onTapColor3, fontSize: 20.0,),
    );
  }

  @override
  Widget bottomNames2() {
    return new Text(
      'Albums',
      style: TextStyle(color: onTapColor2, fontSize: 20.0,),
    );
  }

  @override
  Widget bottomNames1() {
    return new Text(
      'Songs',
      style: TextStyle(color: onTapColor1, fontSize: 20.0,),
    );
  }

  @override
  Widget buildBottombar() {
    return new Container(
      height: 48.0,
      color: Colors.deepPurple,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new InkWell(
            child: bottomNames3(),
            onTap: () {
              setState(() {
                _data = 3;
                onTapColor3 = Colors.black;
                onTapColor2 = Colors.white;
                onTapColor1 = Colors.white;
              });
            },
          ),

          SizedBox(width: 36.0,),

          new InkWell(
            child: bottomNames1(),
            onTap: () {
              setState(() {
                _data = 1;
                onTapColor1 = Colors.black;
                onTapColor2 = Colors.white;
                onTapColor3 = Colors.white;
              });
            },
          ),

          SizedBox(width: 36.0,),

          new InkWell(
            child: bottomNames2(),
            onTap: () {
              setState(() {
                _data = 2;
                onTapColor2 = Colors.black;
                onTapColor3 = Colors.white;
                onTapColor1 = Colors.white;
              });
            },
          ),

        ],
      ),
    );
  }

  @override
  Widget buildAppbar() {
    return new AppBar(
      title: const Text(
        'MusiQuest Home',
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
          icon: new Icon(Icons.menu),
          onPressed: () => _ScaffoldKey.currentState.openDrawer()
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            //size: 32.0,
          ),
          onPressed: () {
            setState(() {
              search++;
            });
          },
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  Widget buildType() {
    if (_data == 0) {
      return new Text(
        loading,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }
    else if(_data == 1) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(
                'Recently Played',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(recently_played),
              ),
            ],
          ),


          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(
                'New Releases',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(song_date),
              ),
            ],
          ),

          new Column(
            children: <Widget>[
              new Text(
                'Most Popular',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(song_views),
              ),
            ],
          ),

          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(
                'Top Songs',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(song_likes),
              ),
            ],
          ),
        ],
      );

    } else if(_data == 2) {

      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(
                'Most Popular',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(album_views),
              ),
            ],
          ),

          new Column(
            children: <Widget>[
              new Text(
                'Top Albums',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(album_likes),
              ),
            ],
          ),
        ],
      );
    } else if(_data == 3) {

      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(
                'Most Popular',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(artist_views),
              ),
            ],
          ),

          new Column(
            children: <Widget>[
              new Text(
                'Top Artists',
                style: TextStyle(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              new Container(
                height: 180.0,
                child: _buildList(artist_likes),
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget _buildList(dynamic each_row) {
    return  ListView.builder(
      padding: const EdgeInsets.all(16.0),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return _buildRow(each_row[i]);
      },
      itemCount: each_row.length,
    );
  }

  @override
  Widget image(){
    String text = '';
    if(_data == 1)
      text = 'icon/song.png';
    else if(_data == 2)
      text = 'icon/album.png';
    else if(_data == 3)
      text = 'icon/artist.png';

    return new Image.asset(
      text,
      height: 96.0,
    );
  }

  @override
  Widget _buildRow(dynamic d) {
    return new Container(
      width: 120.0,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: new Column(
        children: <Widget>[
          image(),

          new Text(
            '${d['name']}',
            textAlign: TextAlign.center,
            style: TextStyle( color: Colors.white),
            softWrap: true,
           // overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void fillList() {
    var data = getDataString(cfg.home);
    data.then((ret) {
      song_date.clear();
      song_views.clear();
      song_likes.clear();

      album_likes.clear();
      album_views.clear();

      artist_likes.clear();
      artist_views.clear();

      recently_played.clear();

      Map<String, dynamic> det = json.decode(ret);
      if ('${det['artist_views']['status']}' == 'true') {
        for (var row in det['artist_views']['data']) {
          artist_views.add(row);
        }
      } else {
        setState(() {
          loading = '${det['artist_views']['message']}';
        });
      }

      if ('${det['artist_likes']['status']}' == 'true') {
        for (var row in det['artist_likes']['data']) {
          artist_likes.add(row);
        }
      } else {
        setState(() {
          loading = '${det['artist_likes']['message']}';
        });
      }

      if ('${det['song_views']['status']}' == 'true') {
        for (var row in det['song_views']['data']) {
          song_views.add(row);
        }
      } else {
        setState(() {
          loading = '${det['song_views']['message']}';
        });
      }

      if ('${det['song_likes']['status']}' == 'true') {
        for (var row in det['song_likes']['data']) {
          song_likes.add(row);
        }
      } else {
        setState(() {
          loading = '${det['song_likes']['message']}';
        });
      }

      if ('${det['song_date']['status']}' == 'true') {
        for (var row in det['song_date']['data']) {
          song_date.add(row);
        }
      } else {
        setState(() {
          loading = '${det['song_date']['message']}';
        });
      }

      if ('${det['album_views']['status']}' == 'true') {
        for (var row in det['album_views']['data']) {
          album_views.add(row);
        }
      } else {
        setState(() {
          loading = '${det['album_views']['message']}';
        });
      }

      if ('${det['album_likes']['status']}' == 'true') {
        for (var row in det['album_likes']['data']) {
          album_likes.add(row);
        }
      } else {
        setState(() {
          loading = '${det['album_likes']['message']}';
        });
      }

      if ('${det['recently_played']['status']}' == 'true') {
        for (var row in det['recently_played']['data']) {
          recently_played.add(row);
        }
      } else {
        setState(() {
          loading = '${det['recently_played']['message']}';
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

    fillList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _ScaffoldKey,
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
                    child: buildType(), //_buildList(song_views),
                  )
              ),
              buildBottombar(), // Bottom bar build
            ],
          ),
        ],
      ),

      drawer: new Drawer(
        elevation: 25.0,
        child: new ListView(
          children: <Widget>[
            new ListTile(
              title: new CircleAvatar(
                backgroundColor: Colors.purple,
                child: new IconButton(
                  icon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  iconSize: 64.0,
                  onPressed: null,
                ),
                radius: 64.0,
              ),
            ),

            new ListTile(
              title: new Text(
                'User Name',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0,),
                softWrap: true,
              ),
            ),

            new Divider(
              height: 16.0,
              color: Colors.black,
            ),

            new ListTile(
              title: new Text(
                'My PlayLists',
                textAlign: TextAlign.center,
              ),
              onTap: (){
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.library_music,
                color: Colors.purple,
              ),
            ),

            new Divider(
              height: 8.0,
              color: Colors.black12,
            ),

            new ListTile(
              title: new Text(
                'Change Password',
                textAlign: TextAlign.center,
              ),
              onTap: (){
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.build,
                color: Colors.purple,
              ),
            ),

            new Divider(
              height: 8.0,
              color: Colors.black12,
            ),

            new ListTile(
              title: new Text(
                'Delete Account',
                textAlign: TextAlign.center,
              ),
              onTap: (){
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.delete_forever,
                color: Colors.purple,
              ),
            ),

            new Divider(
              height: 8.0,
              color: Colors.black12,
            ),

            new ListTile(
              title: new Text(
                'Logout',
                textAlign: TextAlign.center,
              ),
              onTap: (){
                var data = getDataString(cfg.logout);
                data.then((ret) {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                });
              },
              leading: Icon(
                Icons.exit_to_app, //Icons.power_settings_new,
                color: Colors.purple,
              ),
            ),

          ],
        ),
      ),
    );
  }
}