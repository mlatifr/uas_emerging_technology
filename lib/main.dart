import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'detail_masakan.dart';
import 'input_masakan.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
// String tulisan = "";

String user_aktif = "";
String APIurl = "http://mlatifr.ddns.net/emertech/uas_kuremas/";
// bool pembuka = true;

Future<String> cekLogin() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getString("user_id") ?? '';
    return user_id;
  } catch (e) {
    print('error karena $e');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  cekLogin().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      user_aktif = result;
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Masakan {
  int id;
  String nama, url_foto, bahan;
  Masakan({this.id, this.nama, this.url_foto, this.bahan});
  factory Masakan.fromJson(Map<String, dynamic> json) {
    return new Masakan(
      id: json['id'],
      nama: json['nama'],
      url_foto: json['url_foto'],
      bahan: json['bahan'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String _txtcari = '';
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
        Masakan mskn = Masakan.fromJson(i);
        listMasakans.add(mskn);
      }
      setState(() {});
    });
  }

  // tahap 3 API 1
  //meminta POST
  Future<String> fetchData() async {
    final response = await http
        .post(Uri.parse(APIurl + "get_list_masakan_nama.php"), body: {});
    if (response.statusCode == 200) {
      print("print response body : ${response.body}");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaDataNama() {
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
        Uri.parse(
            "http://mlatifr.southeastasia.cloudapp.azure.com/emertech/uas_kuremas/get_list_masakan_cari_nama_bahan.php"),
        body: {'cari': _txtcari});
    if (response.statusCode == 200) {
      print("print response body : ${response.body}");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget widgetDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Welcome: ' + user_aktif),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/bg.jpg'),
              ),
            ),
          ),
          ListTile(
            title: Text('none'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => actorList()));
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              doLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget widgetGridView() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.search),
            labelText: 'Resep mengandung kata:',
          ),
          onChanged: (value) {
            _txtcari = value;
            bacaDataNama();
          },
          onFieldSubmitted: (value) {
            _txtcari = value;
            bacaDataNama();
            print(_txtcari);
          },
        ),
        GridView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: listMasakans.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(4),
                  child: Column(children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailMasakan(
                                      namaMasakan: listMasakans[index].nama,
                                      indexMasakan: listMasakans[index].id,
                                      url_masakan:
                                          listMasakans[index].url_foto)));
                        },
                        child: Column(
                          children: [
                            Text("${listMasakans[index].nama}"),
                            Image.network("${listMasakans[index].url_foto}",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width * 0.2)
                          ],
                        )),
                  ]));
            }),
      ],
    );
    ;
  }

  @override
  // untuk membaca data diawal build page nya
  void initState() {
    super.initState();
    bacaData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Kumpulan Resep Pak Latif"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fastfood_outlined)),
              // Tab(icon: Icon(Icons.layers_clear)),
              // Tab(icon: Icon(Icons.layers_clear)),
              // Tab(icon: Icon(Icons.layers_clear)),
            ],
          ),
        ),
        drawer: widgetDrawer(),
        body: widgetGridView(),
        // TabBarView(children: [
        //   widgetGridView(),
        //   Center(child: Text('belum ada fitur')),
        //   Center(child: Text('belum ada fitur')),
        //   Center(child: Text('belum ada fitur'))
        // ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InpurMasakan()));
          },
          child: const Icon(Icons.add_circle),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
