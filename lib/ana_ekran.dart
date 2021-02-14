import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dersleri/fotograf_albumum.dart';
import 'package:firebase_dersleri/login_islemleri.dart';
import 'package:firebase_dersleri/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'baslik.dart';
import 'cate_container.dart';
import 'islemler.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class AnaEkran extends StatelessWidget {
  List<Islemler> _islemListe = [
    Islemler(
      image: 'assets/todolistt.png',
    ),
    Islemler(image: 'assets/album.png')
  ];
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: [
              Baslik(),
              SizedBox(
                height: _height * 0.05,
              ),
              Container(
                height: _height * 0.65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _islemListe.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CateContainer(
                        image: _islemListe[index].image,
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Provider()));
                          }
                          if (index == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FotografAlbumum()));
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.exit_to_app),
        backgroundColor: Colors.pink[300],
        onPressed: () {
          _cikisYap();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoginIslemleri()));
        },
      ),
    );
  }

  void _cikisYap() async {
    if (_auth.currentUser != null) {
      await _auth.signOut();
      debugPrint("çıkış yapıldı");
    } else {
      debugPrint("Hiçbir oturum açık değil");
    }
  }
}
