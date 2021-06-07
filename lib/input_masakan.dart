import 'package:flutter/material.dart';

class InpurMasakan extends StatefulWidget {
  const InpurMasakan({Key key}) : super(key: key);

  @override
  _InpurMasakanState createState() => _InpurMasakanState();
}

class _InpurMasakanState extends State<InpurMasakan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(
          "Tambah Masakan",
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
