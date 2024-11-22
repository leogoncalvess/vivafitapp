import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/common_widget/round_button.dart';
import 'package:vivafit_personal_app/common_widget/round_textfield.dart';
import 'package:vivafit_personal_app/view/login/complete_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../main_tab/main_tab_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}
class _LoginViewState extends State<LoginView> {
  
  bool isCheck = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    // Inicie o fluxo de autenticação
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtenha os detalhes de autenticação da solicitação
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Crie uma nova credencial
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Faça o login com a credencial do Google
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
  
    // Solicite a autenticação do usuário
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
  
    // Crie uma nova credencial
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
  
    // Faça o login com a credencial do Apple
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  Future<void> _loginWithGoogle() async {
    try {
      UserCredential userCredential = await signInWithGoogle();
      _handleUserLogin(userCredential.user);
    } catch (e) {
      _showErrorDialog('Erro ao fazer login com Google: $e');
    }
  }

  Future<void> _loginWithApple() async {
    try {
      UserCredential userCredential = await signInWithApple();
      _handleUserLogin(userCredential.user);
    } catch (e) {
      _showErrorDialog('Erro ao fazer login com Apple: $e');
    }
  }

  void _handleUserLogin(User? user) async {
    if (user != null) {
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('userProfiles').doc(user.uid).get();

      if (profileSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfileView(),
          ),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

Future<User?> _getUserByEmail(String email) async {
    try {
      // Tente fazer login com e-mail e senha inválidos para verificar se a conta existe
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: 'invalid-password',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return null;
      } else if (e.code == 'wrong-password') {
        // A conta existe, mas a senha está incorreta
        return FirebaseAuth.instance.currentUser;
      }
    }
    return null;
  }

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Verifique se o perfil do usuário já está preenchido
      User? user = userCredential.user;
      print('User data: $user');
      _handleUserLogin(user); 

    } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          // Verifica se a conta está vinculada a um provedor
          User? user = await _getUserByEmail(_emailController.text);
          if (user != null) {
            bool isGoogleProvider = user.providerData.any((userInfo) => userInfo.providerId == 'google.com');
            bool isAppleProvider = user.providerData.any((userInfo) => userInfo.providerId == 'apple.com');

            if (isGoogleProvider) {
              await _loginWithGoogle();
            } else if (isAppleProvider) {
              await _loginWithApple();
            } else {
              _showErrorDialog('Conta não encontrada ou senha incorreta.');
            }
          } else {
            _showErrorDialog('Conta não encontrada ou senha incorreta.');
          }
        } else {
          _showErrorDialog('Erro ao fazer login: ${e.message}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Image.asset(
                  'assets/img/vivafit_logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  "Olá,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Sejá Bem vindo",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Email",
                  icon: "assets/img/email.png",
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Senha",
                  icon: "assets/img/lock.png",
                  obscureText: true,
                  controller: _passwordController,
                  rigtIcon: TextButton(
                      onPressed: () {},
                      child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            "assets/img/show_password.png",
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: TColor.gray,
                          ))),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Esqueceu sua senha?",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 10,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
               const Spacer(),
                RoundButton(
                    title: "Entrar",
                    onPressed: () async {

                      _login(context);
                      return;
                    }),
                SizedBox(
                  height: media.width * 0.04,
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.,
                  children: [
                    Expanded(
                        child: Container(
                      height: 1,
                      color: TColor.gray.withOpacity(0.5),
                    )),
                    Text(
                      "  Ou  ",
                      style: TextStyle(color: TColor.black, fontSize: 12),
                    ),
                    Expanded(
                        child: Container(
                      height: 1,
                      color: TColor.gray.withOpacity(0.5),
                    )),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () 
                      {
                        _loginWithGoogle();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TColor.white,
                          border: Border.all(
                            width: 1,
                            color: TColor.gray.withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          "assets/img/google.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: media.width * 0.04,
                    ),
                    GestureDetector(
                      onTap: () 
                      {
                        _loginWithApple();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TColor.white,
                          border: Border.all(
                            width: 1,
                            color: TColor.gray.withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          "assets/img/facebook.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Não tem uma conta ainda? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Cadastre-se",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
