import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dersleri/widgets.dart';
import 'package:firebase_dersleri/task.dart';
import 'package:firebase_dersleri/yeni_not_ekle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class ListItem extends StatefulWidget {
  final Task task;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ListItem(this.task);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  var silinecekid;
  bool lightTheme = true;
  Color currentColor = Colors.white;

  List<Color> currentColors = [Colors.limeAccent, Colors.green];

  void changeColor(Color color) => setState(() => currentColor = color);
  void changeColors(List<Color> colors) =>
      setState(() => currentColors = colors);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    void _checkItem() {
      setState(() {
        Provider.of<TaskProvider>(context, listen: false)
            .yapildiMi(widget.task.id);
      });
    }

    return Dismissible(
      //kaydırma için kullanılır-silme işlemi
      key: ValueKey(widget.task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        TaskProvider().veritabanindanSil(
            widget.task.id); //şuanki id göndrdiği için bulamıyor ve silemiyor
        Provider.of<TaskProvider>(context, listen: false).cikar(widget.task.id);
      },
      background: Container(
        //burası kaydırınca sil yazısı için
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.red,
                fontSize: 30,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.delete,
              color: Colors.red,
              size: 28,
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _checkItem,
        child: Container(
          height: 180,
          child: Card(
            color: currentColor,
            elevation: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.task.isDone,
                      onChanged: (_) => _checkItem(),
                    ),
                    ItemText(
                        //item_text dosyası
                        widget.task.isDone,
                        widget.task.yapilacak,
                        widget.task.dueDate,
                        widget.task.dueTime,
                        widget.task.currentColor),
                  ],
                ),
                if (!widget.task.isDone)
                  IconButton(
                    icon: Icon(Icons.edit),
                    iconSize: 25,
                    splashRadius: 20,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => YeniNotEkle(
                          id: widget.task.id,
                          isEditMode: true,
                        ),
                      );
                    },
                  ),
                if (!widget.task.isDone)
                  IconButton(
                    icon: Icon(Icons.format_color_fill),
                    iconSize: 25,
                    splashRadius: 20,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titlePadding: const EdgeInsets.all(0.0),
                            contentPadding: const EdgeInsets.all(0.0),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: currentColor,
                                onColorChanged: changeColor,
                                colorPickerWidth: 300.0,
                                pickerAreaHeightPercent: 0.7,
                                enableAlpha: true,
                                displayThumbColor: true,
                                showLabel: true,
                                paletteType: PaletteType.hsv,
                                pickerAreaBorderRadius: const BorderRadius.only(
                                  topLeft: const Radius.circular(2.0),
                                  topRight: const Radius.circular(2.0),
                                ),
                              ),
                            ),
                            actions: [
                              RaisedButton(
                                  child: Text("TAMAM"),
                                  onPressed: () async {
                                    await _firestore
                                        .collection(
                                            "/kullanicilar/beyzbykk@gmail.com/notlar")
                                        .get()
                                        .then((value) {
                                      for (int i = 0;
                                          i < value.docs.length;
                                          i++) {
                                        // if (guncellenecekid == widget.task.id) {
                                        var guncellenecekid = value.docs[i].id;
                                        print(guncellenecekid);
                                        print(currentColor);
                                        _firestore
                                            .doc(
                                                "/kullanicilar/beyzbykk@gmail.com/notlar/$guncellenecekid")
                                            .update({"color": "$currentColor"});
                                      }
                                    });
                                    Navigator.of(context).pop();
                                  })
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
