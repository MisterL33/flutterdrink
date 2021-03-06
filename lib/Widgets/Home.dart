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
  String avatar;

  User({this.name, this.id, this.avatar});
}

class _HomeState extends State<Home> {
  BuildContext buildContext;

  bool _success = true;
  String _errorMessage;

  Future<List<User>> fetchUsersFromGitHub() async {
    final response = await http.get('https://api.github.com/users');
    var responseJson = json.decode(response.body.toString());
    List<User> userList = createUserList(responseJson);
    return userList;
  }

  List<User> createUserList(List data) {
    List<User> list = [];
    for (int i = 0; i < data.length; i++) {
      String title = data[i]["login"];
      int id = data[i]["id"];
      String avatar = data[i]["avatar_url"];
      User movie = new User(name: title, id: id, avatar: avatar);
      list.add(movie);
    }
    return list;
  }


  @override
  void initState() {
    super.initState();
    final users = fetchUsersFromGitHub();
    print(users);
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
  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(),
    );
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
          child: new FutureBuilder<List<User>>(
              future: fetchUsersFromGitHub(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return new GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return CardView(user : snapshot.data[index]);
                      });
                }else{
                  return _loadingView;
                }
              }),
        ));
  }
}

class CardView extends StatefulWidget {

  final User user;
  CardView({Key key, @required this.user}) : super(key: key);


  @override
  CardViewState createState() {
    return new CardViewState();
  }
}

class CardViewState extends State<CardView> with SingleTickerProviderStateMixin {
  Animation<double> heightAnimation;
  Animation<double> scaleAnimation;
  AnimationController controller;
  double _cardBannerHeight = 0.1;
  double _cardImageScale = 0.6;

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
              image: '${widget.user.avatar}',
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
              child: Text('${widget.user.name}',
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
