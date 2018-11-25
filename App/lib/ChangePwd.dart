import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'config.dart';
import 'home.dart';

class ChangePwdPage extends StatefulWidget {
  ChangePwdPage({Key key, this.uname}) : super(key: key);

  final String uname;
  ChangePwdPageState createState() => new ChangePwdPageState();
}

class ChangePwdPageState extends State<ChangePwdPage> {
  final Session s = new Session();
  final formkey = GlobalKey<FormState>();
  bool _autovalidate = false;
  final config cfg = new config();

  TextEditingController old_password = new TextEditingController();
  TextEditingController new_password = new TextEditingController();
  TextEditingController cfm_new_password = new TextEditingController();

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
                  image: new AssetImage('icon/login.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.lightBlue, BlendMode.hue),
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
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.deepPurpleAccent.withOpacity(0.6),
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
                                  obscureText: true,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  controller: old_password,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter Old Password';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Old Password',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0,),
                              new Flexible(
                                fit: FlexFit.loose,
                                child: new TextFormField(
                                  obscureText: true,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  controller: new_password,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter New Password';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'New Password',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0,),
                              new Flexible(
                                fit: FlexFit.loose,
                                child: new TextFormField(
                                  obscureText: true,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  controller: cfm_new_password,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please confirm New Password';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Confirm New Password',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.0,),
                              Material(
                                borderRadius: BorderRadius.circular(30.0),
                                color: Colors.deepPurple.shade900,
                                shadowColor: Colors.deepPurpleAccent,
                                elevation: 5.0,
                                child:  MaterialButton(
                                  minWidth: 280.0,
                                  height: 42.0,
                                  child: Text('Change Password',style: TextStyle(color: Colors.white),),
                                  onPressed: () {
                                    if (formkey.currentState.validate()) {
                                      if(new_password.text == cfm_new_password.text){
                                        dynamic data = {
                                          'old_password': old_password.text,
                                          'new_password': new_password.text
                                        };
                                        s.post(cfg.chngpwd,data).then((ret) {
                                          Map<String, dynamic> results = json.decode(ret);
                                          if ('${results['status']}' == 'false') {
                                            Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Verification Unsuccessful!'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => HomePage(uname: widget.uname,)),
                                            );
                                          }
                                        }).catchError((onError) =>
                                            Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                content:Text(onError.toString()),
                                              ),
                                            )
                                        );
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Passwords donot match'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
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
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}