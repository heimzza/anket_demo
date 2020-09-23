import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Anket"),
        ),
        body: SurveyList(),
      ),
    );
  }
}

class SurveyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }
}

class SurveyListState extends State {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("dilanketi").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return buildBody(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
        padding: EdgeInsets.only(top: 20.0),
        children: snapshot
            .map<Widget>((data) => buildListItem(context, data))
            .toList());
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row = Anket.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(5.0)),
        child: ListTile(
          title: Text(row.isim),
          trailing: Text(row.oy.toString()),
          onTap: () => Firestore.instance.runTransaction((transaction) async{
            final freshSnapshot = await transaction.get(row.reference); // sanasphot
            final fresh = Anket.fromSnapshot(freshSnapshot); //Anket

            await transaction.update(row.reference, {"oy":fresh.oy+1});
          }),
        ),
      ),
    );
  }
}

final sahteSnapshot = [
  {"isim": "c#", "oy": 3},
  {"isim": "dart", "oy": 9},
  {"isim": "java", "oy": 7},
  {"isim": "dart", "oy": 8},
  {"isim": "python", "oy": 13},
  {"isim": "perl", "oy": 35},
];

class Anket {
  String isim;
  int oy;
  DocumentReference reference;

  Anket.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map["isim"] != null),
        assert(map["oy"] != null),
        isim = map["isim"],
        oy = map["oy"];

  Anket.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
