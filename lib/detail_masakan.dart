import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
        Uri.parse(
            "http://mlatifr.southeastasia.cloudapp.azure.com/emertech/uas_kuremas/get_masakan_resep.php"),
        body: {'id_masakan': widget.indexMasakan.toString()});
    if (response.statusCode == 200) {
      print("print response body : ${response.body}");
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
            // Divider(),
            Image.network("${widget.url_masakan}",
                // height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width),
            Divider(
              // height: 150,
              color: Colors.blue,
            ),
            Padding(
                padding: EdgeInsets.all(1),
                child: TextFormField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  initialValue: widget.namaMasakan,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                )),
          ],
        )));
  }
}
