import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ana_ekran.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class LoginIslemleri extends StatefulWidget {
  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {
  @override
  void initState() {
    super.initState();
    // _auth.authStateChanges().listen((User user) {
    //   if (user != null) {
    //     print('Kullanıcı oturumunu kapattı!');
    //   } else {
    //     print('Kullanıcı oturum açtı!');
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          mainAlbumImage(),
          loginSection(context),
        ],
      ),
    );
  }

  void _emailSifreOlustur(email, sifre) async {
    String _email = email;
    String _password = sifre;

    try {
      //createUserWithEmailAndPassword'ün bana döndüreceği usercredential
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);

      User _yeniKullanici = _credential.user;
      await _yeniKullanici.sendEmailVerification(); //kullanıcıya mail yollar.
      if (_auth.currentUser != null) {
        debugPrint("Size bir mail attık lütfen onaylayınız");
        await _auth.signOut();
        debugPrint("Kullanıcı sistemden atıldı");
      }
      debugPrint(_yeniKullanici.toString());
    } catch (e) {
      debugPrint("********HATA******");
      debugPrint(e.toString());
    }
  }

  void _emailSifreGiris(BuildContext context, email, password) async {
    String _email, _password;
    _email = email;
    _password = password;

    try {
      if (_auth.currentUser == null) {
        User _oturumAcanKullanici = (await _auth.signInWithEmailAndPassword(
                email: _email, password: _password))
            .user;
        debugPrint("giriş yapıldı");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AnaEkran()));
        if (_oturumAcanKullanici.emailVerified) {
          debugPrint("Mail onaylı");
        } else {
          debugPrint("Lütfen mailinizi onaylayınız!");
          _auth.signOut();
        }
      } else {
        debugPrint("Oturum açmış kullanıcı zaten var");
      }
    } catch (e) {
      debugPrint("Kullanıcı adı veya şifre hatalı");
    }
  }
}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50.0,
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10.0),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            ),
          ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}

mainAlbumImage() {
  return Container(
    width: double.infinity,
    height: 600,
    decoration: BoxDecoration(
      color: Colors.pink.shade300,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
      ),
    ),
    padding: EdgeInsets.only(
      left: 30,
      top: 200,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'KISISEL',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: Colors.white70,
              fontSize: 30.0,
            ),
          ),
        ),
        Text(
          'BILGILERIM',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

loginSection(BuildContext context) {
  final myUsername = TextEditingController();
  final myPassword = TextEditingController();
  String email, sifre;
  return Container(
    width: double.infinity,
    height: 350,
    decoration: new BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey[300],
          blurRadius: 5.0,
          spreadRadius: 0.0,
          offset: Offset(
            0,
            10.0,
          ),
        )
      ],
    ),
    margin: EdgeInsets.only(
      top: 320,
      left: 25,
      right: 25,
    ),
    padding: EdgeInsets.all(20),
    child: Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        TextField(
          style: TextStyle(fontSize: 20),
          cursorColor: Colors.pink[300],
          onChanged: (String text) {
            email = text;
          },
          decoration: InputDecoration(
            labelText: 'E-mail',
          ),
          controller: myUsername,
        ),
        SizedBox(height: 5.0),
        TextField(
          style: TextStyle(fontSize: 20),
          cursorColor: Colors.pink[300],
          onChanged: (String text) {
            sifre = text;
          },
          obscureText: true,
          decoration: InputDecoration(labelText: 'Şifre'),
          controller: myPassword,
        ),
        SizedBox(height: 25.0),
        RaisedGradientButton(
          child: Text(
            'Giriş Yap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          gradient: LinearGradient(
            colors: <Color>[Colors.pinkAccent.shade100, Colors.purple],
          ),
          onPressed: () {
            _LoginIslemleriState giris = new _LoginIslemleriState();
            giris._emailSifreGiris(context, email, sifre);
            myPassword.clear();
            myUsername.clear();
          },
        ),
        SizedBox(height: 25.0),
        RaisedGradientButton(
          child: Text(
            'Kullanıcı Oluştur',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          gradient: LinearGradient(
            colors: <Color>[Colors.pinkAccent.shade100, Colors.purple],
          ),
          onPressed: () {
            _LoginIslemleriState olustur = new _LoginIslemleriState();
            olustur._emailSifreOlustur(email, sifre);
            myPassword.clear();
            myUsername.clear();
          },
        ),
      ],
    ),
  );
}
