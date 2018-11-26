import 'dart:async';
import 'session.dart';
import 'config.dart';
import 'home.dart';
import 'song.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

class PlayerWidget extends StatefulWidget {
  final String url;
  var id;
  final Ids song;
  final bool mute;
  final int type;

  PlayerWidget({@required this.url, this.id, this.song, this.mute, this.type});

  @override
  State<StatefulWidget> createState() {
    return new _PlayerWidgetState(url, id);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  var  id;
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  final Session s = new Session();
  final config cfg = new config();

  PlayerState _playerState = PlayerState.stopped;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  var up = 0;
  var dn = 0;
  var value = 0;
  Color up_color = Colors.white;
  Color dn_color = Colors.white;

  _PlayerWidgetState(this.url, this.id);

  void initvalues(){
    print("TYPE OF RELATIION: " + widget.type.toString());
    if(widget.type == 1){
      up = 1;
      up_color = Colors.green;
    } else if(widget.type == -1) {
      dn  = 1;
      dn_color = Colors.red;
    }
  }

  @override
  void initState() {
    super.initState();

    initvalues();
    _initAudioPlayer();

    _play();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
  }

  Widget playPause() {
    if(_isPlaying)
      return new Icon(Icons.pause);
    else
      return new Icon(Icons.play_arrow);
  }

  @override
  Widget build(BuildContext context) {

    if(widget.mute) {
      _audioPlayer.setVolume(0.0);
    } else {
      _audioPlayer.setVolume(1.0);
    }

    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new IconButton(
              onPressed: (){
                setState(() {
                  value = up*(-1) + (1-up)*(1+dn);
                  dn_color = Colors.white;
                  if(up==1){
                    up=0;
                    up_color = Colors.white;
                  }
                  else{
                    up=1;
                    up_color = Colors.green;
                  }
                  dynamic data = {
                    'song_id': id,
                    'value': value.toString(),
                  };
                  s.post(cfg.updateSong, data).then((ret){
                      print(ret);
                  });
                  dn = 0;
                });
              },
              icon: new Icon(Icons.thumb_up
            ),
                color: up_color),

            new IconButton(
              icon: Icon(Icons.skip_previous),
              iconSize: 24.0,
              color: Colors.white,
              onPressed: (){
                final Ids prev_song = widget.song;
                if(widget.song.idx >= 0){
                  prev_song.idx = (widget.song.idx + widget.song.lists.length - 1)%widget.song.lists.length;
                  prev_song.id = '${widget.song.lists[prev_song.idx]['song_id']}';
                }
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SongPage(song: prev_song,)));
              },
            ),
            new IconButton(
                onPressed: _isPlaying ? () => _pause() : () => _play(),
                icon: playPause(),
                iconSize: 24.0,
                color: Colors.cyan),
            new IconButton(
                onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                icon: new Icon(Icons.stop),
                iconSize: 24.0,
                color: Colors.cyan),

            new IconButton(
              icon: Icon(Icons.skip_next),
              iconSize: 24.0,
              color: Colors.white,
              onPressed: (){
                final Ids prev_song = widget.song;
                if(widget.song.idx >= 0){
                  prev_song.idx = (widget.song.idx + 1)%widget.song.lists.length;
                  prev_song.id = '${widget.song.lists[prev_song.idx]['song_id']}';
                }
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SongPage(song: prev_song,)));
              },
            ),

            new IconButton(
              onPressed: (){
                setState(() {
                  value = dn*(1) - (1-dn)*(1+up);
                  up_color = Colors.white;
                  if(dn==1){
                    dn=0;
                    dn_color = Colors.white;
                  }
                  else{
                    dn=1;
                    dn_color = Colors.red;
                  }

                  dynamic data = {
                    'song_id': id,
                    'value': value.toString(),
                  };
                  s.post(cfg.updateSong, data).then((ret){
                    print(ret);
                  });
                  up = 0;
                });
              },
              icon: new Icon(Icons.thumb_down),
              color: dn_color
            ),
          ],
        ),
        new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Padding(
              padding: new EdgeInsets.all(12.0),
              child: new Stack(
                children: [
                  _duration == null
                      ? new Container()
                      : new Slider(
                      value: _position != null ? _position.inMilliseconds + 0.0 : 0.0,
                      onChanged: (double val2){
                        int val = val2.toInt();
                        int millisec = val%1000;
                        int sec = (val/1000).floor();
                        int minute = (val/60000).floor();
                        int hr = (val/3600000).floor();
                        sec -= minute*60;
                        minute -= hr*60;
                        Duration dur = new Duration(hours: hr, minutes: minute, seconds: sec, milliseconds: millisec);
                        _seek(dur);
                      },
                      min: 0.0,
                      max: _duration.inMilliseconds + 0.0,
                      activeColor: Colors.cyan,
                      inactiveColor: Colors.white,
                  ),
//                  new Stack(
//                    children: <Widget>[
//                      new CircularProgressIndicator(
//                        value: 1.0,
//                        valueColor: new AlwaysStoppedAnimation(Colors.white),
//                      ),
//                      new CircularProgressIndicator(
//                        value: _position != null && _position.inMilliseconds > 0
//                            ? _position.inMilliseconds / _duration.inMilliseconds
//                            : 0.0,
//                        valueColor: new AlwaysStoppedAnimation(Colors.cyan),
//                      ),
//                    ],
//                  ),
                ],
              ),
            ),
            new Text(
              _position != null
                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                  : _duration != null ? _durationText : '',
              style: new TextStyle(fontSize: 24.0, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = new AudioPlayer();

    _audioPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    _audioPlayer.positionHandler = (p) => setState(() {
      _position = p;
    });

    _audioPlayer.completionHandler = () {
      _onComplete();
      setState(() {
        _position = _duration;
      });
      final Ids prev_song = widget.song;
      if(widget.song.idx >= 0){
        prev_song.idx = (widget.song.idx + 1)%widget.song.lists.length;
        prev_song.id = '${widget.song.lists[prev_song.idx]['song_id']}';
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SongPage(song: prev_song,)));

    };



    _audioPlayer.errorHandler = (msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = new Duration(seconds: 0);
        _position = new Duration(seconds: 0);
      });
    };
  }

  Future<int> _play() async {
    final result = await _audioPlayer.play(url, isLocal: false);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> _seek(Duration dur) async {
    final result = await _audioPlayer.seek(dur);
    if (result == 1) {
      setState(() {
        _position = dur;
      });
    }
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = new Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);

  }
}
