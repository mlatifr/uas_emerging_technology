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

class DetailMasakan extends StatefulWidget {
  final namaMasakan, indexMasakan, url_masakan;
  const DetailMasakan(
      {Key key, this.namaMasakan, this.indexMasakan, this.url_masakan})
      : super(key: key);

  @override
  _DetailMasakanState createState() => _DetailMasakanState();
}

class _DetailMasakanState extends State<DetailMasakan> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //function kirim like
          },
          child: const Icon(Icons.favorite),
          backgroundColor: Colors.pink,
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
                'komentar',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.green,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                            child: TextFormField(
                              maxLines: null,
                              enabled: false,
                              textAlign: TextAlign.justify,
                              initialValue: "$index",
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
                  //   submit();
                  // }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        )));
  }
}
