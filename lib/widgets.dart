import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemText extends StatelessWidget {
  //textlerini burada yazar
  final bool check;
  final String text;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final Color currentColor;

  ItemText(
      this.check, this.text, this.dueDate, this.dueTime, this.currentColor);

  Widget _buildText(BuildContext context) {
    if (check) {
      //check box işaretlenmisse
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            text,
            overflow: TextOverflow.ellipsis, //taşma işini hallet!!
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                decoration:
                    TextDecoration.lineThrough), //bittiğinde çizgi çeker
          ),
          _tarihveSaat(context),
        ],
      );
    }
    return Column(
      //check box işaretli değilse
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        _tarihveSaat(context),
      ],
    );
  }

  Widget _tarihOlustur(BuildContext context) {
    return Text(
      DateFormat.yMMMd().format(dueDate).toString(),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        color: check ? Colors.grey : Theme.of(context).primaryColorDark,
      ),
    );
  }

  Widget _saatOlustur(BuildContext context) {
    return Text(
      dueTime.format(context),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        color: check ? Colors.grey : Theme.of(context).primaryColorDark,
      ),
    );
  }

  Widget _tarihveSaat(BuildContext context) {
    if (dueDate != null && dueTime == null) {
      //eğer tarih boş değil, saat boşsa
      return _saatOlustur(context);
    } else if (dueDate != null && dueTime != null) {
      //ikisi de doluysa
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _tarihOlustur(context),
          SizedBox(
            width: 30,
          ),
          _saatOlustur(context),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return _buildText(context);
  }
}
