import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'home.dart';

class InicialHome extends StatefulWidget {
  @override
  _InicialHomeState createState() => _InicialHomeState();
}

class _InicialHomeState extends State<InicialHome> {
  List listas = [];
  var nomeLista = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    int index;
    readData().then((data) {
      listas = json.decode(data);
    });

    Future.delayed(Duration(seconds: 2)).then((value) =>
    {
      if (listas.length == 0)
        {showOptions(context)}
      else
        {
          for (int i = 0; i <= listas.length; i++)
            {
              if (listas[i]["primeira"])
                {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Home(listas[i], i)))
                }
            }
        }
    });
  }

  void showOptions(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            enableDrag: false,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      children: <Widget>[
                        SizedBox(height: 100,),
                  Center(
                  child: Text("Primeira vez?"),
                ),
               Form(
                 key: formkey,
                 child: Row(
                   children: <Widget> [
                     Expanded(child:
                     Padding(padding: EdgeInsets.all(20),
                       child: TextFormField(
                         controller: nomeLista,
                         decoration: InputDecoration(
                           labelText: "Digite o nome da sua primeira lista:",
                         ),
                         maxLength: 25,
                         validator: (value) {
                           if (value.isEmpty){
                             return "É necessario digitar o nome para a sua primeira lista";
                           }
                         },
                       ),
                     ),),
                     CircleAvatar(
                       child: IconButton(icon: Icon(Icons.add), onPressed: () {
                         if (formkey.currentState.validate()) {
                            addToDo();
                         }
                       }),
                     )


                   ],
                 ),
               )


                ],
                ),
                );
              });
        });
  }

  void addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["nome"] = nomeLista.text;
      List listaVazia = [];
      newToDo["tasks"] = listaVazia;
      newToDo["primeira"] = true;
      listas.add(newToDo);
      saveData();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Home(listas[0], 0)));
    });
  }

  Future<File> saveData() async {
    String data = json.encode(listas);
    final file = await getFile();
    return file.writeAsString(data);
  }

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/listast2.json");
  }

  Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      body: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/listagif.gif",
                alignment: Alignment.center,
                width: 200,
                height: 200,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: LinearProgressIndicator(
                  minHeight: 10,
                ),
              )
            ],
          )),
    );
  }
}
