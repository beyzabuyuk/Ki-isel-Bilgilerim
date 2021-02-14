import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

class Fotograf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: FotografAlbumum());
  }
}

class FotografAlbumum extends StatefulWidget {
  @override
  _FotografAlbumumState createState() => _FotografAlbumumState();
}

class _FotografAlbumumState extends State<FotografAlbumum> {
  PickedFile _secilenResim;
  List<String> list = new List<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.pink[300]),
        leading: Container(
          margin: EdgeInsets.only(left: 20),
          child: Icon(Icons.more_vert),
        ),
        actions: [
          Container(
            width: 40,
            child: FloatingActionButton(
              heroTag: 1,
              backgroundColor: Colors.pink[300],
              child: Icon(
                Icons.add_a_photo,
                size: 25,
              ),
              onPressed: () {
                //galeri'den resim alıp buraya ve firestore ekle
                _galeriResimUpload();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
          ),
          Container(
            width: 40,
            child: FloatingActionButton(
              heroTag: 2,
              backgroundColor: Colors.pink[300],
              child: Icon(
                Icons.camera_alt_rounded,
                size: 25,
              ),
              onPressed: () {
                //kameraya basınca resim cek ve firestore ekle bir de resimlerin olduğu yere ekle
                _kameraResimUpload();
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 20, top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fotoğraf Albümüm",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Lobster",
                        fontSize: 30,
                        color: Colors.pink[300]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Fotoğraflarımda Ara",
                    border: InputBorder.none,
                    fillColor: Colors.grey,
                    icon: Icon(
                      Icons.search,
                      color: Colors.pink[300],
                    )),
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
          FutureBuilder<String>(
              future: _firestore
                  .collection("/kullanicilar/beyzbykk@gmail.com/images/")
                  .get()
                  .then((querySnapshot) {
                for (int i = 0; i < querySnapshot.docs.length; i++) {
                  debugPrint(querySnapshot.docs[i].data()["isim"].toString());
                  list.add(querySnapshot.docs[i].data()["isim"].toString());
                }
              }),
              builder: (context, snapshot) {
                return SliverStaggeredGrid.countBuilder(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection(
                                "/kullanicilar/beyzbykk@gmail.com/images")
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          List<Widget> children;
                          if (list.isNotEmpty) {
                            children = <Widget>[Image.network(list[index])];
                          } else if (snapshot.hasError) {
                            children = <Widget>[
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text('Error: ${snapshot.error}'),
                              )
                            ];
                          } else {
                            children = <Widget>[
                              SizedBox(
                                child: CircularProgressIndicator(),
                                width: 60,
                                height: 60,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text('Bekleyiniz...'),
                              )
                            ];
                          }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: children,
                            ),
                          );
                        },
                      );
                    },
                    itemCount: list.length);
              })
        ],
      ),
    );
  }

//Image.file(File(_secilenResim.path))
  void _galeriResimUpload() async {
    var _picker = ImagePicker();
    var resim = await _picker.getImage(
        source: ImageSource.gallery); //uzun sürecek işlem olduğu için
    //kullanıcı galerisine giricek en son resmi secicek ve buraya atıcak

    setState(() {
      //anlık degişim-kullanıcı resim sectiginde arayuzumuze yansıması icin
      _secilenResim = resim;
      list.clear();
    });
    int rastgelesayi = rastgeleSayi();

    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("kullanici")
        .child("galeri")
        .child("galeri $rastgelesayi");
    StorageUploadTask uploadTask = ref.putFile(File(_secilenResim.path));

    var url = await (await uploadTask.onComplete).ref.getDownloadURL();
    debugPrint("upload edilen resmin urlsi : " + url);

    _firestore
        .collection("/kullanicilar/beyzbykk@gmail.com/images")
        .add({"isim": "${url.toString()}"});
  }

  void _kameraResimUpload() async {
    var _picker = ImagePicker();
    var resim = await _picker.getImage(
        source: ImageSource.camera); //uzun sürecek işlem olduğu için
    //kullanıcı galerisine giricek en son resmi secicek ve buraya atıcak

    setState(() {
      //anlık degişim-kullanıcı resim sectiginde arayuzumuze yansıması icin
      _secilenResim = resim;
      list.clear();
    });
    int rastgelesayi = rastgeleSayi();

    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("kullanici")
        .child("kamera")
        .child("kamera $rastgelesayi");
    StorageUploadTask uploadTask = ref.putFile(File(_secilenResim.path));

    var url = await (await uploadTask.onComplete).ref.getDownloadURL();
    debugPrint("upload edilen resmin urlsi : " + url);

    _firestore
        .collection("/kullanicilar/beyzbykk@gmail.com/images")
        .add({"isim": "${url.toString()}"});
  }

  int rastgeleSayi() {
    var rastgeleSayi = Random().nextInt(100);
    return rastgeleSayi;
  }
}
