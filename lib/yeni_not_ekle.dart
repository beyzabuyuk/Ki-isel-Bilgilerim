import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dersleri/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class YeniNotEkle extends StatefulWidget {
  final String id;
  final bool isEditMode;

  YeniNotEkle({
    this.id,
    this.isEditMode,
  });
  @override
  _YeniNotEkleState createState() => _YeniNotEkleState();
}

class _YeniNotEkleState extends State<YeniNotEkle> {
  Task task;
  TimeOfDay _saat;
  DateTime _tarih;
  String _not;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool lightTheme = true;
  Color currentColor = Colors.limeAccent;
  List<Color> currentColors = [Colors.limeAccent, Colors.green];

  void changeColor(Color color) => setState(() => currentColor = color);
  void changeColors(List<Color> colors) =>
      setState(() => currentColors = colors);

  void _notTarihi() {
    showDatePicker(
            context: context,
            initialDate: widget.isEditMode ? _tarih : DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030))
        .then((date) {
      if (date == null) {
        return;
      }
      date = date;
      setState(() {
        _tarih = date;
      });
    });
  }

  void _notZamani() {
    showTimePicker(
      context: context,
      initialTime: widget.isEditMode ? _saat : TimeOfDay.now(),
    ).then((time) {
      if (time == null) {
        return;
      }
      setState(() {
        _saat = time;
      });
    });
  }

  void _onay() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_tarih == null && _saat != null) {
        _tarih = DateTime.now();
      }
      if (!widget.isEditMode) {
        Provider.of<TaskProvider>(context, listen: false).yeniYapilacakOlustur(
          Task(
              id: DateTime.now().toString(),
              yapilacak: _not,
              dueDate: _tarih,
              dueTime: _saat,
              currentColor: currentColor),
        );
      } else {
        Provider.of<TaskProvider>(context, listen: false).duzenle(
          Task(
              id: task.id,
              yapilacak: _not,
              dueDate: _tarih,
              dueTime: _saat,
              currentColor: currentColor),
        );
        // TaskProvider().veritabaniniGuncelle(task);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    if (widget.isEditMode) {
      task =
          Provider.of<TaskProvider>(context, listen: false).getById(widget.id);
      _tarih = task.dueDate;
      _saat = task.dueTime;
      _not = task.yapilacak;
      currentColor = task.currentColor;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Yapılacak:', style: Theme.of(context).textTheme.headline5),
            TextFormField(
              initialValue: _not == null ? null : _not,
              decoration: InputDecoration(
                hintText: 'Notunuzu Giriniz',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Lütfen not giriniz.';
                }
                return null;
              },
              onSaved: (value) {
                _not = value;
              },
            ),
            SizedBox(
              height: 20,
            ),
            Text('Bitiş Tarihi:', style: Theme.of(context).textTheme.headline5),
            TextFormField(
              onTap: () {
                _notTarihi();
              },
              readOnly: true,
              decoration: InputDecoration(
                hintText: _tarih == null
                    ? 'Bitiş tarihini giriniz.'
                    : DateFormat.yMMMd().format(_tarih).toString(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Bitiş Saati:', style: Theme.of(context).textTheme.headline5),
            TextFormField(
              onTap: () {
                _notZamani();
              },
              readOnly: true,
              decoration: InputDecoration(
                hintText: _saat == null
                    ? 'Bitiş saatini giriniz.'
                    : _saat.format(context),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                child: Text(
                  !widget.isEditMode ? 'EKLE' : 'DÜZENLE',
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _onay();
                  print(currentColor);
                  _firestore
                      .collection("/kullanicilar/beyzbykk@gmail.com/notlar")
                      .add({
                    "id": DateTime.now().toString(),
                    "not": _not,
                    "bitis_tarihi": _tarih.toString(),
                    "bitis_saati": _saat.format(context).substring(0, 4),
                    "color": currentColor.toString()
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
