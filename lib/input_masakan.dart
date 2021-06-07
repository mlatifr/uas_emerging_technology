import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

File _image = null;

class InpurMasakan extends StatefulWidget {
  const InpurMasakan({Key key}) : super(key: key);

  @override
  _InpurMasakanState createState() => _InpurMasakanState();
}

class _InpurMasakanState extends State<InpurMasakan> {
  void submit() async {
    List<int> imageBytes = _image.readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    final response2 = await http.post(
        Uri.parse(
          APIurl + "upload_img_masakan.php",
        ),
        body: {
          // 'movie_id': widget.movie_id.toString(),
          'nama_masakan': namaMakanan,
          'img': base64Image,
        });
    if (response2.statusCode == 200) {
      print('respone 2 body: ${response2.body}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response2.body)));
    }

    // final response = await http.post(
    //     Uri.parse("http://ubaya.prototipe.net/daniel/updatemovie.php"),
    //     body: {
    //       'title': pm.title,
    //       'overview': pm.overview,
    //       'homepage': pm.homepage,
    //       'movie_id': widget.movie_id.toString()
    //     });
    // if (response.statusCode == 200) {
    //   print(response.body);
    //   Map json = jsonDecode(response.body);
    //   if (json['result'] == 'success') {
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(SnackBar(content: Text('Sukses mengubah Data')));
    //   }
    // } else {
    //   throw Exception('Failed to read API');
    // }
  }

  final _formKey = GlobalKey<FormState>();

  _imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 600,
        maxWidth: 600);
    setState(() {
      _image = File(image.path);
    });
  }

  _imgKamera() async {
    final picker = ImagePicker();
    final image =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    setState(() {
      _image = File(image.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              color: Colors.white,
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      tileColor: Colors.white,
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galeri'),
                      onTap: () {
                        _imgGaleri();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      _imgKamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  String namaMakanan, bahan, langkah;
  TextEditingController _namaMakanan,
      _bahan,
      _langkah = new TextEditingController();
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(2),
                  child: TextFormField(
                    enabled: true,
                    textAlign: TextAlign.center,
                    // initialValue: widget.namaMasakan,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                    ),
                    onChanged: (value) {
                      namaMakanan = value;
                    },
                    controller: _namaMakanan,
                  )),
              Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: _image != null
                      ? Image.file(_image)
                      : Image.network(
                          "http://ubaya.prototipe.net/daniel/blank.png"),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(2),
                  child: TextFormField(
                    onChanged: (value) {
                      bahan = value;
                    },
                    controller: _bahan,
                    maxLines: 10,
                    enabled: true,
                    textAlign: TextAlign.center,
                    // initialValue: listMasakans[0].bahan,
                    decoration: const InputDecoration(
                      labelText: 'Bahan',
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.all(2),
                  child: TextFormField(
                    onChanged: (value) {
                      langkah = value;
                    },
                    controller: _langkah,
                    maxLines: 10,
                    enabled: true,
                    textAlign: TextAlign.center,
                    // initialValue: listMasakans[0].langkah,
                    decoration: const InputDecoration(
                      labelText: 'langkah',
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Harap Isian diperbaiki')));
                    } else {
                      submit();
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
