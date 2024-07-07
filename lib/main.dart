import 'package:flutter/material.dart';
import 'models.dart';
import 'shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD with SharedPreferences',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListScreen(),
    );
  }
}

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Lista> _listas = [];
  final TextEditingController _listController = TextEditingController();
  final TextEditingController _sublistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListas();
  }

  Future<void> _loadListas() async {
    List<Lista> listas = await Storage.loadListas();
    setState(() {
      _listas = listas;
    });
  }

  Future<void> _saveListas() async {
    await Storage.saveListas(_listas);
  }

  void _addLista() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Lista'),
        content: TextField(
          controller: _listController,
          decoration: InputDecoration(hintText: 'Nombre de la lista'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_listController.text.isNotEmpty) {
                setState(() {
                  _listas.add(Lista(nombre: _listController.text, subListas: []));
                });
                _saveListas();
                _listController.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _editLista(int index) {
    _listController.text = _listas[index].nombre;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Lista'),
        content: TextField(
          controller: _listController,
          decoration: InputDecoration(hintText: 'Nombre de la lista'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_listController.text.isNotEmpty) {
                setState(() {
                  _listas[index].nombre = _listController.text;
                });
                _saveListas();
                _listController.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _addSubLista(int listaIndex) {
    if (_sublistController.text.isNotEmpty) {
      setState(() {
        _listas[listaIndex].subListas.add(SubLista(nombre: _sublistController.text));
      });
      _saveListas();
      _sublistController.clear();
    }
  }

  void _editSubLista(int listaIndex, int subListaIndex) {
    _sublistController.text = _listas[listaIndex].subListas[subListaIndex].nombre;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar SubLista'),
        content: TextField(
          controller: _sublistController,
          decoration: InputDecoration(hintText: 'Nombre de la sublista'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_sublistController.text.isNotEmpty) {
                setState(() {
                  _listas[listaIndex].subListas[subListaIndex].nombre = _sublistController.text;
                });
                _saveListas();
                _sublistController.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación'),
        content: Text('¿Estás seguro de que deseas eliminar esta lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<bool> _confirmDismissSubLista(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación'),
        content: Text('¿Estás seguro de que deseas eliminar esta sublista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  void _removeLista(int index) {
    setState(() {
      _listas.removeAt(index);
    });
    _saveListas();
  }

  void _removeSubLista(int listaIndex, int subListaIndex) {
    setState(() {
      _listas[listaIndex].subListas.removeAt(subListaIndex);
    });
    _saveListas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas'),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _listas.removeAt(oldIndex);
            _listas.insert(newIndex, item);
          });
          _saveListas();
        },
        children: [
          for (int index = 0; index < _listas.length; index++)
            Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) => _confirmDismiss(context),
              onDismissed: (direction) {
                _removeLista(index);
              },
              background: Container(color: Colors.red),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_listas[index].nombre),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editLista(index),
                    ),
                  ],
                ),
                children: [
                  for (int subIndex = 0; subIndex < _listas[index].subListas.length; subIndex++)
                    Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _confirmDismissSubLista(context),
                      onDismissed: (direction) {
                        _removeSubLista(index, subIndex);
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_listas[index].subListas[subIndex].nombre),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editSubLista(index, subIndex),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _sublistController,
                            decoration: InputDecoration(hintText: 'Nombre de la sublista'),
                            onSubmitted: (_) => _addSubLista(index),  // Agrega la sublista al presionar Enter
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _addSubLista(index),
                        ),
                      ],
                    ),
                  ),
                ],
                onExpansionChanged: (isOpen) {
                  if (isOpen) {
                    // Asegúrate de que el campo de texto se limpie cuando se abra
                    _sublistController.clear();
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLista,
        child: Icon(Icons.add),
      ),
    );
  }
}
