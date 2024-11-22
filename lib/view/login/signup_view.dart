import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/common_widget/round_button.dart';
import 'package:vivafit_personal_app/common_widget/round_textfield.dart';
import 'package:vivafit_personal_app/view/login/complete_profile_view.dart';
import 'package:vivafit_personal_app/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vivafit_personal_app/view/main_tab/main_tab_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool isCheck = false;
  bool isObscureText = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    _handleUserLogin(userCredential.user);
    return userCredential;
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


  Future<void> saveUserData(String uid, String name, String lastName) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'lastName': lastName,
      'createdDate': Timestamp.now(),
    });
  }

  String translateFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'O endereço de e-mail é inválido.';
      case 'user-disabled':
        return 'O usuário foi desativado.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'O endereço de e-mail já está em uso.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      default:
        return 'Ocorreu um erro desconhecido.';
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/vivafit_logo.png',
                  width: 120,
                  height: 120,
                ),     
                const SizedBox(
                   height: 20,
                ),           
                Text(
                  "Olá,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Crie sua conta",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                RoundTextField(
                  hitText: "Nome",
                  icon: "assets/img/user_text.png",
                  controller: _nameController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Sobrenome",
                  icon: "assets/img/user_text.png",
                  controller: _lastNameController,
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
                  obscureText: isObscureText,
                  controller: _passwordController,
                  rigtIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          isObscureText = !isObscureText;
                        });
                      },
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
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: IconButton(
                              onPressed: () {
                              setState(() {
                                isCheck = !isCheck;
                              });
                            },
                      icon: Icon(
                        isCheck
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank_outlined,
                        color: TColor.gray,
                        size: 20,
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child:  Text(
                          "Ao continuar você aceita nossa Política de Privacidade e\nTermos de Uso",
                          style: TextStyle(color: TColor.gray, fontSize: 10),
                        ),
                     
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                RoundButton(title: "Cadastrar", onPressed: () async {
                    try {

                        String name = _nameController.text;
                        String lastName = _lastNameController.text;
                        String email = _emailController.text;
                        String password = _passwordController.text; 
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(                            
                            email: email,
                            password: password,
                        );
                        
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await user.updateProfile(
                            displayName: name,
                            //photoURL: "https://example.com/nova-foto.jpg",
                          );
                          await user.reload();
                          user = FirebaseAuth.instance.currentUser;
                        }

                        await saveUserData(userCredential.user!.uid, name, lastName);
                        
                        if(userCredential.user != null)
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteProfileView()));
                        }

                    } catch (e) {
                        print("Error creating account: $e");
                        String errorMessage = 'Ocorreu um erro ao criar a conta. Por favor, tente novamente.';
                        if (e is FirebaseAuthException) {
                            errorMessage = translateFirebaseAuthError(e.code);
                        }

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                                return AlertDialog(
                                    title: Text("Erro"),
                                    content: Text(errorMessage),
                                    actions: [
                                        TextButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                                Navigator.of(context).pop();
                                            },
                                        ),
                                    ],
                                );
                            },
                        );
                    }
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
                      onTap: () async {
                        await signInWithGoogle();
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
                      onTap: () {},
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
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Já tem uma conta? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Login",
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
