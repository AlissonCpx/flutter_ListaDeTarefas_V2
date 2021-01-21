import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_de_tarefas_v2/src/share/drawer.dart';
import 'package:lista_de_tarefas_v2/src/ui/inicialHome.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  Map ListaNome;
  int indexLista;

  Home(this.ListaNome, this.indexLista);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var inputTask = TextEditingController();
  List listasTaf = [];
  List listas = [];
  bool loading = false;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  var comentController = TextEditingController();

  Map<String, dynamic> lastRemoved;
  int lastRemovedPos;

  @override
  void initState() {
    super.initState();

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
        listasTaf = widget.ListaNome["tasks"];
      });
    }
  }

  void addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = inputTask.text;
      newToDo["coment"] = "";
      newToDo["ok"] = false;
      listas[widget.indexLista]["tasks"].add(newToDo);
      listasTaf.add(newToDo);
      saveData();
      inputTask.clear();
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

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: ListTile(
          onTap: () {
            setState(() {
              bool status = listas[widget.indexLista]["tasks"][index]["ok"];
              if (status == true) {
                listas[widget.indexLista]["tasks"][index]["ok"] = false;
              } else {
                listas[widget.indexLista]["tasks"][index]["ok"] = true;
              }
              saveData();
            });
          },
          title: Text(listas[widget.indexLista]["tasks"][index]["title"]),
          subtitle: Text(listas[widget.indexLista]["tasks"][index]["coment"]),
          leading: CircleAvatar(
            backgroundColor: listas[widget.indexLista]["tasks"][index]["ok"]
                ? Colors.green
                : Colors.blue,
            child: mudaIcone(listas[widget.indexLista]["tasks"][index]["ok"]),
          ),
          trailing: Container(
            child: IconButton(
                icon: Icon(Icons.add_comment),
                onPressed: () {
                  if (listas[widget.indexLista]["tasks"][index]["coment"] ==
                          null ||
                      listas[widget.indexLista]["tasks"][index]["coment"] ==
                          "") {
                    comentController.clear();
                  } else {
                    comentController.text =
                        listas[widget.indexLista]["tasks"][index]["coment"];
                  }
                  _settingModalBottomSheet(context, index);
                }),
            height: 50,
            width: 50,
          )),
      onDismissed: (direction) {
        setState(() {
          lastRemoved = Map.from(listas[widget.indexLista]["tasks"][index]);
          lastRemovedPos = index;
          listas[widget.indexLista]["tasks"].removeAt(index);
          saveData();
          final snack = SnackBar(
            content: Text(
                "Tarefa \"${lastRemoved["title"]}\" removida"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    listas[widget.indexLista]["tasks"]
                        .insert(lastRemovedPos, lastRemoved);
                    saveData();
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Widget mudaIcone(bool status) {
    if (status == true) {
      return Icon(
        Icons.check,
        color: Colors.white,
      );
    } else {
      return Icon(
        Icons.error,
        color: Colors.white,
      );
    }
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      listas[widget.indexLista]["tasks"].sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else
          return 0;
      });
      saveData();
    });
  }

  void _settingModalBottomSheet(context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Container(
                    child: new Wrap(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(1),
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              "Digite uma descrição:",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 0.0),
                          child: TextField(
                            controller: comentController,
                            decoration: InputDecoration(
                              icon: Icon(Icons.edit),
                              labelText: "Descrição",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                            ),
                            onChanged: (value) {
                              setState(() {
                                lastRemoved = Map.from(
                                    listas[widget.indexLista]["tasks"][index]);
                                lastRemovedPos = index;
                                listas[widget.indexLista]["tasks"]
                                    .removeAt(index);
                                lastRemoved["coment"] = comentController.text;

                                listas[widget.indexLista]["tasks"]
                                    .insert(lastRemovedPos, lastRemoved);
                                saveData();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMy(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                int i = 0;
                String mensagem = "*Lista ${widget.ListaNome["nome"]}:*\n";
                int j = 1;
                for (i = 0;
                    i < listas[widget.indexLista]["tasks"].length;
                    i++) {
                  String titulo =
                      listas[widget.indexLista]["tasks"][i]["title"];
                  String situacao = listas[widget.indexLista]["tasks"][i]["ok"]
                      ? "Concluído"
                      : "Pendente";
                  String coment =
                      listas[widget.indexLista]["tasks"][i]["coment"];

                  mensagem += "$j. $titulo - ($situacao)\n" +
                      (coment != "" ? "*$coment\n\n" : "\n");
                  j++;
                }
                Share.share(mensagem);
              }),
          SizedBox(
            width: 5,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
            ),
            onPressed: () {
              Alert(
                  context: context,
                  title: "Exluir lista <${widget.ListaNome["nome"]}>",
                  desc:
                      "Deseja excluir a lista ${widget.ListaNome["nome"]} com ${widget.ListaNome["tasks"].length} itens?",
                  buttons: [
                    DialogButton(
                        child: Text("Sim"),
                        onPressed: () {
                          if (listas[widget.indexLista]["primeira"]) {
                            setState(() {
                              listas.removeAt(widget.indexLista);
                            });
                            if (listas.length != 0) {
                              listas[0]["primeira"] = true;
                            }
                          } else {
                            setState(() {
                              listas.removeAt(widget.indexLista);
                            });
                          }
                          saveData();
                          if (listas.length == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InicialHome()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home(listas[0], 0)));
                          }
                        }),
                    DialogButton(
                        child: Text("Não"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ]).show();
            },
          )
        ],
        centerTitle: true,
        title: Text(widget.ListaNome["nome"]),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Form(
              key: formkey,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        if (formkey.currentState.validate()) {
                          addToDo();
                        }
                      },
                      controller: inputTask,
                      maxLength: 40,
                      decoration: InputDecoration(
                          labelText: "Item:",
                          hoverColor: Colors.red,
                          prefixIcon: Icon(Icons.schedule)),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Digite um item para a lista!";
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  CircleAvatar(
                    child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (formkey.currentState.validate()) {
                            addToDo();
                          }
                        }),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            widget.ListaNome["tasks"] != null
                ? Expanded(
                    child: RefreshIndicator(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: listas[widget.indexLista]["tasks"].length,
                      itemBuilder: buildItem,
                    ),
                    onRefresh: refresh,
                  ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
