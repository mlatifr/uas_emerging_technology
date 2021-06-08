import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class MasakanBaru {
  int id_masakan_baru;
  MasakanBaru({this.id_masakan_baru});
  factory MasakanBaru.fromJson(Map<String, dynamic> json) {
    return new MasakanBaru(
      id_masakan_baru: json['id_masakan_baru'],
    );
  }
}

class InputMasakan extends StatefulWidget {
  const InputMasakan({Key key}) : super(key: key);

  @override
  _InputMasakanState createState() => _InputMasakanState();
}

class _InputMasakanState extends State<InputMasakan> {
  Future onGoBack(dynamic value) {
    print("masuk goback");
    setState(() {
      bacaDataNama();
    });
  }

  bacaDataNama() {
    List listMasakans = [];
    if (listMasakans.isNotEmpty) listMasakans.clear();
    Future<String> data = fetchDataNama();
    data.then((value) {
      //Mengubah json menjadi Array
      Map json = jsonDecode(value);
      // print("print value API 1 = ${value} \n \n");
      for (var i in json['data']) {
        Masakan mskn = Masakan.fromJson(i);
        listMasakans.add(mskn);
      }
      setState(() {});
    });
  }

  // tahap 3 API 1
  //meminta POST
  Future<String> fetchDataNama() async {
    final response = await http.post(
        Uri.parse(APIurl + "get_list_masakan_cari_nama_bahan.php"),
        body: {'cari': ''});
    if (response.statusCode == 200) {
      print("print response body : ${response.body}");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  int id_masakan_baru;
  File _image = null;
  void submit() async {
    List<int> imageBytes = _image.readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    // kirim foto
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
      Map json = jsonDecode(response2.body);
      if (json['result'] == 'success') {
        id_masakan_baru = json['id_masakan_baru'];
      }
      setState(() {});

      print('respone 2 body: ${id_masakan_baru}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response2.body)));
    }
    final prefs = await SharedPreferences.getInstance();
    print('cek parameter');
    print("$id_masakan_baru ${prefs.getString('user_id')} $_bahan $_langkah");

    final response = await http.post(
        Uri.parse(APIurl + "input_masakan_resep_bahan_langkah.php"),
        body: {
          'masakan_id': id_masakan_baru.toString(),
          'user_id': prefs.getString(
              'user_id'), //id pembuat masakan(id yang login saat ini)
          'bahan': bahan,
          'langkah': langkah,
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses mengubah Data')));
      }
    } else {
      throw Exception('Failed to read API');
    }
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            ).then(onGoBack);

            // Navigator.pop(context);
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
