import 'package:flutter/material.dart';

class MaintenancePage extends StatefulWidget {

  @override
  MaintenancePageState createState() => new MaintenancePageState();
}

class MaintenancePageState extends State<MaintenancePage> {

  Widget buildAppbar() {
    return new AppBar(
      title: const Text('Maintenance'),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildRow() {
    return new  Text(
      'Admin Page',
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        appBar: buildAppbar(),
        body: _buildRow(),
      ),
    );
  }
}