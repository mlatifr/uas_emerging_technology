import 'package:flutter/material.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

String tulisan = "";
String user_aktif = "";
bool pembuka = true;

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

class _MyHomePageState extends State<MyHomePage> {
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
    return GridView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 22,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return Card(
              elevation: 4,
              margin: EdgeInsets.all(4),
              child: Column(children: <Widget>[
                GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             DetailMovie(index)));
                    },
                    child: Column(
                      children: [
                        Text("data ${index + 1}"),
                        Image.network(
                            'http://ubaya.prototipe.net/daniel/blank.png',
                            height: 150)
                      ],
                    )),
              ]));
        });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Kumpulan Resep Pak Latif"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fastfood_outlined)),
              Tab(icon: Icon(Icons.layers_clear)),
              Tab(icon: Icon(Icons.layers_clear)),
              Tab(icon: Icon(Icons.layers_clear)),
            ],
          ),
        ),
        drawer: widgetDrawer(),
        body: TabBarView(children: [
          widgetGridView(),
          Center(child: Text('belum ada fitur')),
          Center(child: Text('belum ada fitur')),
          Center(child: Text('belum ada fitur'))
        ]),
      ),
    );
  }
}
