import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Task {
  final String id;
  String yapilacak;
  DateTime dueDate;
  TimeOfDay dueTime;
  bool isDone;
  Color currentColor;

  Task({
    @required this.id,
    @required this.yapilacak,
    this.dueDate,
    this.dueTime,
    this.isDone = false,
    this.currentColor,
  });
}

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var silinecekid;
  List<Task> get itemsList {
    return _liste;
  }

  final List<Task> _liste = [];

  Task getById(String id) {
    return _liste.firstWhere(
        (task) => task.id == id); //listenin ilk elemanı task'ın id'si olur
  }

  void yeniYapilacakOlustur(Task task) {
    final yeniYapilacak = Task(
        id: task.id,
        yapilacak: task.yapilacak,
        dueDate: task.dueDate,
        dueTime: task.dueTime,
        currentColor: task.currentColor);
    _liste.add(yeniYapilacak); //listeye yeni eklenen yapilacak eklenir
    notifyListeners();
  }

  void veritabanindanGetir(Task task) {
    final oncedenOlanListe = Task(
        id: task.id,
        yapilacak: task.yapilacak,
        dueDate: task.dueDate,
        dueTime: task.dueTime,
        currentColor: task.currentColor);
    _liste.add(oncedenOlanListe);
    notifyListeners();
  }

  void duzenle(Task task) {
    cikar(task.id);
    yeniYapilacakOlustur(task);
  }

  void cikar(String id) {
    _liste.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void yapildiMi(String id) {
    int index = _liste.indexWhere((task) => task.id == id);
    _liste[index].isDone = !_liste[index].isDone;
  }

  void veritabanindanSil(String id) async {
    print("{$id}");
    await _firestore
        .collection("/kullanicilar/beyzbykk@gmail.com/notlar")
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        silinecekid = value.docs[i].data()["id"];
        if (silinecekid == id) {
          var docid = value.docs[i].id;
          _firestore
              .doc("/kullanicilar/beyzbykk@gmail.com/notlar/$docid")
              .delete();
        }
      }
    });
  }
}
