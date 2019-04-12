import 'package:flutter/material.dart';
import 'package:flutter_drink_app/services/authentication.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;
  bool _success = true;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  @override
  void initState() { // on initialise le state
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  // On vérifie que le formulaire soit valide avant de se connecter ou de s'inscrire
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Selon le type du formulaire , on s'inscris ou on se connecte
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = false;
    });
    if (_validateAndSave()) { // si le formulaire est valide
      setState(() {
        _isLoading = true; // on lance le chargement
      });
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) { // si on est en mode login
          userId = await widget.auth.signIn(_email, _password); // on appel la fonction native de firebase pour se connecter
          print('Signed in: $userId');
          _success = true;
        } else {
          userId = await widget.auth.signUp(_email, _password);// sinon on appel la fonction pour s'inscrire
          print('Signed up user: $userId');

        }
        setState(() {
          _isLoading = false; // chargement fini
        });

        if ( userId != null && userId.length > 0) { // si on à un userId, on est connecté
          widget.onSignedIn();
        }

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _success = null;

          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _success = false;
          });
        });
      }
    }
  }


  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }



  @override
  Widget build(BuildContext context) { // Ceci est le widget principal qui contient tout
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text('OneDrink'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(), // on appel showBody qui contient tous le contenu du widget principal
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(key: Key("loginProgressIndicator"),));
    } return Container(height: 0.0, width: 0.0,);
  }


  Widget _showBody(){ // ce widget appel tous les autres widget pour le widget principal
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }


  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        key: Key("errorMsg"),
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }


  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: new TextFormField(
        key: Key("email"),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) {
          if(value.isEmpty) {
            _success = null;
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _success = false;
              });
            });
            return 'Email can\'t be empty';
          }
          else
            return null;
        },
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        key: Key("password"),
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) {
          if(value.isEmpty) {
            _success = null;
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _success = false;
              });
            });
            return 'Password can\'t be empty';
          }
          else
            return null;
        },
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
          style:
          new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
