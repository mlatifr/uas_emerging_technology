import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:resep_pak_latif/main.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasakanBahanLangkah {
  int masakan_id;
  String user_id, bahan, langkah;
  MasakanBahanLangkah(
      {this.masakan_id, this.user_id, this.bahan, this.langkah});
  factory MasakanBahanLangkah.fromJson(Map<String, dynamic> json) {
    return new MasakanBahanLangkah(
      masakan_id: json['masakan_id'],
      user_id: json['user_id'],
      bahan: json['bahan'],
      langkah: json['langkah'],
    );
  }
}

class Komentar {
  int resep_masakan_id, komentar_id;
  String id_user_komentar, komentar;
  Komentar(
      {this.resep_masakan_id,
      this.id_user_komentar,
      this.komentar_id,
      this.komentar});
  factory Komentar.fromJson(Map<String, dynamic> json) {
    return new Komentar(
      resep_masakan_id: json['resep_masakan_id'],
      id_user_komentar: json['id_user_komentar'],
      komentar_id: json['komentar_id'],
      komentar: json['komentar'],
    );
  }
}

class DetailMasakan extends StatefulWidget {
  final namaMasakan, indexMasakan, url_masakan;
  const DetailMasakan(
      {Key key, this.namaMasakan, this.indexMasakan, this.url_masakan})
      : super(key: key);

  @override
  _DetailMasakanState createState() => _DetailMasakanState();
}

class _DetailMasakanState extends State<DetailMasakan> {
  var komentar_id;
  void submit() async {
    final prefs = await SharedPreferences.getInstance();
    // List<int> imageBytes = _image.readAsBytesSync();
    // print(imageBytes);
    // String base64Image = base64Encode(imageBytes);
    // kirim foto
    final response2 = await http.post(
        Uri.parse(
          APIurl + "input_id_pengomentar.php",
        ),
        body: {
          'komentar': komentar,
          'id_user_komentar': prefs.getString(
              'user_id'), //id pembuat masakan(id yang login saat ini)
        });
    if (response2.statusCode == 200) {
      Map json = jsonDecode(response2.body);
      if (json['result'] == 'success') {
        komentar_id = json['komentar_id'];
      }
      setState(() {});

      print('respone 2 body: ${komentar_id}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response2.body)));
    }
    print('cek parameter');
    // print("$id_masakan_baru ${prefs.getString('user_id')} $_bahan $_langkah");

    final response = await http
        .post(Uri.parse(APIurl + "input_get_pengomentar_resep.php"), body: {
      'resep_masakan_id': widget.indexMasakan.toString(),
      'resep_user_id': prefs
          .getString('user_id'), //id pembuat masakan(id yang login saat ini)
      'komentar_id': komentar_id.toString(),
    });
    if (response.statusCode == 200) {
      print(response.body);
      print(
          ' \n ${widget.indexMasakan}\n ${prefs.getString('user_id')}\n ${komentar_id}');
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.body}')));
        setState(() {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  List listKomentar = [];
  // tahap 2 API 1
  bacaDataKomentar() {
    if (listKomentar.isNotEmpty) listMasakans.clear();
    Future<String> data = fetchDataKomentar();
    data.then((value) {
      //Mengubah json menjadi Array
      Map json = jsonDecode(value);
      // print("print value API 1 = ${value} \n \n");
      for (var i in json['data']) {
        Komentar kmntr = Komentar.fromJson(i);
        listKomentar.add(kmntr);
      }
      setState(() {});
    });
  }

  // tahap 3 API 1
  //meminta POST
  Future<String> fetchDataKomentar() async {
    final response = await http.post(
        Uri.parse(APIurl + "get_list_masakan_resep_komentar.php"),
        body: {'id': widget.indexMasakan.toString()});
    if (response.statusCode == 200) {
      print("print response body : ${response.body} ${widget.indexMasakan}");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  List listMasakans = [];
  // tahap 2 API 1
  bacaData() {
    if (listMasakans.isNotEmpty) listMasakans.clear();
    Future<String> data = fetchData();
    data.then((value) {
      //Mengubah json menjadi Array
      Map json = jsonDecode(value);
      // print("print value API 1 = ${value} \n \n");
      for (var i in json['data']) {
        MasakanBahanLangkah mskn = MasakanBahanLangkah.fromJson(i);
        listMasakans.add(mskn);
      }
      setState(() {});
    });
  }

  // tahap 3 API 1
  //meminta POST
  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(APIurl + "get_masakan_resep.php"),
        body: {'id_masakan': widget.indexMasakan.toString()});
    if (response.statusCode == 200) {
      print("print response body : ${response.body} ${widget.indexMasakan}");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  // untuk membaca data diawal build page nya
  void initState() {
    super.initState();
    print("ini widget idx masakan id : ${widget.indexMasakan}");
    listMasakans.clear();
    bacaData();
    listKomentar.clear();
    bacaDataKomentar();
  }

  String komentar = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          width: 65.0,
          height: 65.0,
          child: FloatingActionButton(
            onPressed: () {
              //function kirim like
            },
            child: Column(
              children: [
                Text('  '),
                Icon(
                  Icons.favorite,
                  size: 25,
                ),
                Text(
                  '12',
                  style: TextStyle(fontSize: 8),
                ),
              ],
            ),
            backgroundColor: Colors.pink,
          ),
        ),
        appBar: AppBar(
          elevation: 2,
          title: Text(
            "Detail Masakan",
          ),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Image.network("${widget.url_masakan}",
                width: MediaQuery.of(context).size.width),
            Divider(
              color: Colors.blue,
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: TextFormField(
                maxLines: null,
                enabled: false,
                textAlign: TextAlign.center,
                initialValue: widget.namaMasakan,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
              ),
              children: <Widget>[
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: TextFormField(
                      maxLines: null,
                      enabled: false,
                      textAlign: TextAlign.justify,
                      initialValue: listMasakans[0].bahan,
                      decoration: const InputDecoration(
                        labelText: 'Bahan',
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: TextFormField(
                      maxLines: null,
                      enabled: false,
                      textAlign: TextAlign.justify,
                      initialValue: listMasakans[0].langkah,
                      decoration: const InputDecoration(
                        labelText: 'langkah',
                      ),
                    ),
                  ),
                )
              ],
            ),
            ExpansionTile(
              title: Text(
                'Komentar : ${listKomentar.length}',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  color: Colors.green,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: listKomentar.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          // width: MediaQuery.of(context).size.width * 0.8,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextFormField(
                              maxLines: null,
                              enabled: false,
                              textAlign: TextAlign.justify,
                              initialValue:
                                  "${listKomentar[index].id_user_komentar}:\n${listKomentar[index].komentar}",
                              decoration: const InputDecoration(
                                labelText: 'Komentar',
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                maxLines: null,
                enabled: true,
                textAlign: TextAlign.justify,
                // initialValue: 'Isi Komentar disini',
                decoration: const InputDecoration(
                  labelText: 'Tambah Komentar',
                ),
                onChanged: (value) {
                  komentar = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // if (!_formKey.currentState.validate()) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Harap Isian diperbaiki')));
                  // } else {
                  submit();
                  // }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        )));
  }
}
