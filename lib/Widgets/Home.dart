import 'package:flutter/material.dart';
import 'package:flutter_drink_app/services/authentication.dart';

class Home extends StatefulWidget {
  final BaseAuth auth;
  final String userId;
  final VoidCallback onSignedOut;

  const Home({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }
}



class _HomeState extends State<Home> {
  BuildContext buildContext;

  @override
  void initState() {
    super.initState();
  }

  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('OneDrink'),
      ),
      body: Center(
          child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15.0),
              children: <Widget>[
                CardView()
              ]
          )
          ),
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

class CardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.network(
              'https://placeimg.com/640/480/any',
              fit: BoxFit.fill,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            elevation: 10,
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: UserDescription()
          )
        ]
    );
  }
}

class UserDescription extends StatelessWidget {
  const UserDescription({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green,
        constraints: BoxConstraints.expand(height: 55),
        child:
          Column(
            children:
            [
                Text('Laurent', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                Text('Développeur', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ]
          )
    );
  }
}
