import 'package:flutter/material.dart';
import 'package:ifood_app/src/controllers/login_controller.dart';
import 'package:ifood_app/src/screens/cliente/home_cliente.dart';
import 'package:ifood_app/src/screens/restaurante/home_restaurante.dart';
import 'package:ifood_app/src/screens/signup.dart';
import 'package:ifood_app/src/screens/alert_dialog.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // LoginController loginController = BlocProvider.getDependency<LoginController>();
  var loginController = LoginController();
  var email = TextEditingController();
  var password = TextEditingController();

  bool loading;

  Widget build(BuildContext context) {
    loading = false;
    return ListView(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/ifood_logo.png",
                height: 200,
                width: 200,
              ),
              Container(
                height: 60,
                width: 335,
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    hintText: "Digite seu email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 60,
                width: 335,
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Digite sua senha",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 60,
                width: 335,
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });
                    loginController.handleLogin(email.text, password.text).then(
                      (res) {
                        loading = false;
                        email.text = "";
                        password.text = "";

                        if(!res.containsKey("usuario") || res["usuario"].isEmpty)
                          showInfoDialog(
                              context,
                              "Erro",
                              "Não foi possível fazer login. Email e/ou senha incorreto(s).",
                              "Entendi",
                            );
                        
                        else
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                if (res["usuario"][0]["provedor"] == false) {
                                  return HomeCliente(
                                    usuario: res["usuario"][0],
                                  );
                                } else {
                                  return HomeRestaurante(
                                      usuario: res["usuario"][0]);
                                }
                              },
                            ),
                          );
                      },
                    );
                  },
                  color: Color(0xffDF4723),
                  textColor: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(9.0)),
                  child: loading
                      ? CircularProgressIndicator()
                      : Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 60),
              Text(
                "Não possui conta?",
                style: TextStyle(
                  color: Color(0xffDF4723),
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 60,
                width: 335,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Signup()));
                  },
                  color: Color(0xffDF4788),
                  textColor: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(9.0)),
                  child: Text(
                    "Cadastre-se",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
