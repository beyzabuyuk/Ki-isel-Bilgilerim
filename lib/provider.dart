import 'package:firebase_dersleri/task.dart';
import 'package:firebase_dersleri/yapilacaklar_listesi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Provider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: YapilacaklarListesi(),
      ),
    );
  }
}
