import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dersleri/task.dart';
import 'package:firebase_dersleri/yeni_not_ekle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'yazilar_listesi.dart';

/// This is the stateful widget that the main application instantiates.
class YapilacaklarListesi extends StatelessWidget {
  var id, bitistarihi, not, bitissaati, color;
  TimeOfDay bitis_s;
  DateTime bitis_t;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final taskList = Provider.of<TaskProvider>(context).itemsList;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverAppBar(
            title: Text(
              "Yapılacaklar Listesi",
              style: TextStyle(fontFamily: "Lobster", fontSize: 30),
            ),
            backgroundColor: Colors.blue[200],
            expandedHeight: 250,
            brightness: Brightness.light,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "assets/pen.png",
                fit: BoxFit.fill,
              ),
            ),
            actions: [
              FloatingActionButton(
                backgroundColor: Colors.pink.shade300,
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => YeniNotEkle(isEditMode: false),
                  );
                },
              ),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.pink.shade300,
                child: Icon(
                  Icons.data_usage,
                  size: 40,
                ),
                onPressed: () async {
                  await _firestore
                      .collection("/kullanicilar/beyzbykk@gmail.com/notlar")
                      .get()
                      .then((value) {
                    for (int i = 0; i < value.docs.length; i++) {
                      debugPrint(value.docs[i].data().toString());
                      id = value.docs[i].data()["id"];
                      bitistarihi =
                          DateTime.parse(value.docs[i].data()["bitis_tarihi"]);
                      bitissaati = TimeOfDay(
                          hour: int.parse(value.docs[i]
                              .data()["bitis_saati"]
                              .split(":")[0]),
                          minute: int.parse(value.docs[i]
                              .data()["bitis_saati"]
                              .split(":")[1]));
                      not = value.docs[i].data()["not"];
                      color = value.docs[i].data()["color"];
                      String valueString = color.split('(0x')[1].split(')')[0];
                      int deger = int.parse(valueString, radix: 16);
                      Color otherColor = new Color(deger);
                      print(otherColor);
                      Provider.of<TaskProvider>(context, listen: false)
                          .veritabanindanGetir(
                        Task(
                            id: id,
                            yapilacak: not,
                            dueDate: bitistarihi,
                            dueTime: bitissaati,
                            currentColor: otherColor),
                      );
                    }
                  });
                },
              )
            ],
          ),
        )
      ],
      body: Container(
        color: Colors.blue.shade300,
        child: ListView.builder(
          itemCount: taskList.length,
          itemBuilder: (context, index) {
            return ListItem(taskList[index]);
          },
        ),
      ),
    );
  }
}
