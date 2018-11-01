import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MusiQuest',
      theme: new ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      home: new MyHomePage(title: 'MusiQuest'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text(widget.title),
//      ),
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('icon/home_bg.png'),
                fit: BoxFit.cover,
                //colorFilter: ColorFilter.mode(Colors.lightBlueAccent.withOpacity(0.0), BlendMode.hardLight),
              ),
            ),
          ),
//          new BackdropFilter(
//            filter: new ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
//            child: new Container(
//              decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
//            ),
//          ),
          new Column(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 16.0,),
                    new ClipRRect(
                      borderRadius: new BorderRadius.circular(64.0),
                      child: new Image.asset(
                        'icon/music.png',
                        height: 132.0,
                        width: 132.0,
                        //colorBlendMode: BlendMode.lighten,
                        //color: Colors.lightBlueAccent.withOpacity(0.4),
                      ),
                    ),

                    SizedBox(height: 148.0,),
                    new Center(
                      child : new Text(
                        "Welcome!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0,),
                      child: Material(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.deepPurple,
                        shadowColor: Colors.lightBlueAccent,
                        elevation: 5.0,
                        child: MaterialButton(
                          minWidth: 200.0,
                          height: 42.0,
                          child: new Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white,fontSize: 16.0),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              new Container(
                color: Colors.deepPurpleAccent,
                height: 48.0,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    SizedBox(width: 16.0,),

                    new InkWell(
                      child: new Text(
                        "Register Here",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
