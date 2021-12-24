import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: Center(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
            height: 36,
            width: 36,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          '设置',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0.0,
        elevation: 0.0,
        actions: const <Widget>[],
        // backgroundColor: Color(0xfff9f9f9),
      ),
      body: Column(
        children: [
          Text(
            'Apktool相关',
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          const Text('Framework保存路径'),
        ],
      ),
    );
  }
}
