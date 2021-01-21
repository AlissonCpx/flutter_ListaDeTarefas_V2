import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_de_tarefas_v2/src/ui/home.dart';
import 'package:path_provider/path_provider.dart';

class DrawerMy extends StatefulWidget {
  @override
  _DrawerMyState createState() => _DrawerMyState();
}

class _DrawerMyState extends State<DrawerMy> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var nomeLista = TextEditingController();
  List listas = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });
    try {
      readData().then((data) {
        setState(() {
          listas = json.decode(data);
          loading = false;
        });
      });
    } catch (erro) {
      print(erro);
      setState(() {
        loading = false;
      });
    }

/*
    listas.remove(true);
    saveData();
    */

  }

  void addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["nome"] = nomeLista.text;
      List listaVazia = [];
      newToDo["tasks"] = listaVazia;
      if (listas.length == 0) {
        newToDo["primeira"] = true;
      } else {
        newToDo["primeira"] = false;
      }
      listas.add(newToDo);
      saveData();
      nomeLista.clear();
    });
  }

  Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              "<Minhas Listas>",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Form(
            key: formkey,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: TextFormField(
                  controller: nomeLista,
                  maxLength: 25,
                  decoration: InputDecoration(labelText: "Nova Lista"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Insira um nome a sua lista";
                    }
                    int i = 0;
                    for (i; i < listas.length; i++) {
                      if (value == listas[i]["nome"]) {
                        return "Ja existe uma lista com este nome!";
                      }
                    }
                  },
                  onFieldSubmitted: (value) {
                    if (formkey.currentState.validate()) {
                      addToDo();
                    }
                  },
                )),
                IconButton(
                    icon: Icon(
                      Icons.add_box,
                      size: 35,
                    ),
                    onPressed: () {
                      if (formkey.currentState.validate()) {
                        addToDo();
                      }
                    })
              ],
            ),
          ),
          loading
              ? Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(),
                )
              : listas.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Voce não possui listas criadas"),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: listas.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              selected: true,
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => Home(listas[index], index)));
                              },
                              trailing: IconButton(
                                  icon: Icon(listas[index]["primeira"]
                                      ? Icons.star
                                      : Icons.star_border),
                                  onPressed: () {
                                    int i = 0;
                                    for (i; i <= listas.length; i++) {
                                      setState(() {
                                        if (listas[i]["primeira"] != false) {
                                          listas[i]["primeira"] = false;
                                        }
                                        listas[index]["primeira"] = true;
                                      });
                                      saveData();
                                    }
                                  }),
                              leading: Icon(Icons.list),
                              hoverColor: Colors.red,
                              title: Text(listas[index]["nome"]),
                            );
                          }),
                    ),
        ],
      ),
    );
  }
}
