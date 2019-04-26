import 'package:flutter/material.dart';
import 'package:flutter_drink_app/services/authentication.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  final BaseAuth auth;
  final String userId;
  final VoidCallback onSignedOut;

  const Home({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class User {
  String name;
  int id;

  User({this.name, this.id});
}

class _HomeState extends State<Home> {
  BuildContext buildContext;

  bool _success = true;
  String _errorMessage;

  final cards = List.generate(20, (i) => CardView());

  @override
  void initState() {
    super.initState();
  }

  int _count = 0;

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('OneDrink'),
        actions: <Widget>[
          FlatButton(
              child: Text('Logout', style: TextStyle(fontSize: 17.0)),
              onPressed: _signOut),
        ],
      ),
      body: Center(
          child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
              children: cards)),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
              _count++;
            }),
        tooltip: 'Increment Counter',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class CardView extends StatefulWidget {
  @override
  CardViewState createState() {
    return new CardViewState();
  }
}

class CardViewState extends State<CardView>
    with SingleTickerProviderStateMixin {
  Animation<double> heightAnimation;
  Animation<double> scaleAnimation;
  AnimationController controller;
  double _cardBannerHeight = 0.1;
  double _cardImageScale = 0.6;

  Future<List<User>> fetchUsersFromGitHub() async {
    final response = await http.get('https://randomuser.me/api/?page=1&results=10');
    print('here');
    var responseJson = json.decode(response.body.toString());
    List<User> userList = createUserList(responseJson);
    return userList;
  }

  List<User> createUserList(List data) {
    List<User> list = new List();
    for (int i = 0; i < data.length; i++) {
      String title = data[i]["login"];
      int id = data[i]["id"];
      User movie = new User(name: title, id: id);
      list.add(movie);
    }
    return list;
  }

  void initState() {
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    heightAnimation = controller
        .drive(CurveTween(curve: Curves.fastOutSlowIn))
        .drive(Tween(begin: 0.1, end: 0.0));

    scaleAnimation = controller
        .drive(CurveTween(curve: Curves.fastOutSlowIn))
        .drive(Tween(begin: 0.7, end: 1.0));

    controller.addListener(() {
      setState(() {
        _cardBannerHeight = heightAnimation.value;
        _cardImageScale = scaleAnimation.value;
      });
    });

    var users = fetchUsersFromGitHub();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: FractionalOffset.bottomCenter,
      children: <Widget>[
        GestureDetector(
          // When the child is tapped, show a snackbar
          onTap: () {
            controller.forward();
            if (_cardBannerHeight == 0.0) {
              controller.reverse();
            }
          },
          child: Transform.scale(
            scale: _cardImageScale,
            origin: Offset(0.0, 0.0),
            child: FadeInImage.memoryNetwork(
              fit: BoxFit.fill,
              placeholder: kTransparentImage,
              image: 'https://placeimg.com/640/480/any',
            ),
          ),
        ),
        FractionallySizedBox(
          alignment: FractionalOffset.bottomRight,
          heightFactor: _cardBannerHeight,
          widthFactor: 0.8,
          child: Container(
              alignment: FractionalOffset.center,
              margin: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(color: Colors.green),
              child: Text('Sarah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ))),
        )
      ],
    );
  }
}
