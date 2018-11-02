import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'config.dart';
import 'home.dart';
import 'maintenance.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final Session s = new Session();
  final formkey = GlobalKey<FormState>();
  bool _autovalidate = false;
  final config cfg = new config();

  TextEditingController uname = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      backgroundColor: Colors.grey,
//      appBar: AppBar(
//        title: Text('MusiQuest'),
//      ),
      body: new Builder(
        builder: (BuildContext context) {
          return new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('icon/login2.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.deepPurpleAccent, BlendMode.hue),
              ),
            ),
            child: new Center(
              child: SingleChildScrollView(
                child : new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
//                        new Image.asset(
//                          "icon/name2.png",
//                          height: 64.0 ,
//                          width: 192.0,
////                          colorBlendMode: BlendMode.,
//                        ),
                    SizedBox(height: 48.0,),
                    new Container(
                      decoration: new BoxDecoration(
                        //color: Colors.deepPurple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: Colors.deepPurple, width: 1.0, style: BorderStyle.solid),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: new Form(
                        key: formkey,
                        autovalidate: _autovalidate,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Flexible(
                              fit: FlexFit.loose,
                              child: new TextFormField(
                                // style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.text,
                                controller: uname,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter UserName';
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'UserName',
                                  //hintStyle: TextStyle(color: Colors.white.)
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0,),
                            new Flexible(
                              fit: FlexFit.loose,
                              child: new TextFormField(
                                obscureText: true,
                                keyboardType: TextInputType.text,
                                controller: password,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter Password';
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                ),
                              ),
                            ),
                            SizedBox(height: 24.0,),
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.deepPurple,
                              shadowColor: Colors.deepPurpleAccent,
                              elevation: 5.0,
                              child:  MaterialButton(
                                minWidth: 280.0,
                                height: 42.0,
                                child: Text('Login',style: TextStyle(color: Colors.white),),
                                onPressed: () {
                                  if (formkey.currentState.validate()) {
                                    dynamic data = {
                                      'username': uname.text,
                                      'password': password.text
                                    };
                                    s.post(cfg.login,data).then((ret) {
                                      String type = ret.substring(0,1);
                                      Map<String, dynamic> results = json.decode(ret.substring(1));
                                      if ('${results['status']}' == 'false') {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Login Failed'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      } else {
                                        if(type == "U"){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomePage(uname: uname.text,)),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => MaintenancePage()),
                                          );
                                        }
                                      }
                                    }).catchError((onError) =>
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content:Text(onError.toString()),
                                            duration: Duration(seconds: 1),
                                          ),
                                        )
                                    );
                                  } else {
                                    setState(() {
                                      _autovalidate = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
          );
        }
      ),
    );
  }
}