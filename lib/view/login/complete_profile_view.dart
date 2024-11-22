import 'package:firebase_auth/firebase_auth.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/models/roles.dart';
import 'package:vivafit_personal_app/models/user_profile.dart';
import 'package:vivafit_personal_app/services/user_profile_service.dart';
import 'package:vivafit_personal_app/view/login/what_your_goal_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();  

  String? _selectedGender;

  @override
  void dispose() {
    _genderController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/img/complete_profile.png",
                  width: media.width,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Vamos completar o seu perfil",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "Isso nos ajudará a saber mais sobre você!",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: TColor.lightGray,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  
                                  child: Image.asset(
                                    "assets/img/gender.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: TColor.gray,
                                  )),
                            
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedGender,
                                        items: ["Masculino", "Feminino"]
                                            .map((name) => DropdownMenuItem(
                                                  value: name,
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                        color: TColor.gray,
                                                        fontSize: 14),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value;
                                            _genderController.text = value == "Masculino" ? "M" : "F";
                                          });
                                        },
                                        isExpanded: true,
                                        hint: Text(
                                          "Escolha o gênero",
                                          style: TextStyle(
                                              color: TColor.gray, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ),

                             const SizedBox(width: 8,)

                            ],
                          ),),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      RoundTextField(
                        controller: _birthDateController,
                        hitText: "Data de nascimento",
                        icon: "assets/img/date.png",   
                        keyboardType: TextInputType.datetime,
                        validationPattern: r"^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$",                                   
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: _weightController,
                              hitText: "Seu peso",
                              icon: "assets/img/weight.png",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "KG",
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: _heightController,
                              hitText: "Sua altura",
                              icon: "assets/img/hight.png",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "CM",
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      RoundButton(
                          title: "Próximo",
                          onPressed: () async {
                            try {
                              if (_genderController.text.isEmpty || _birthDateController.text.isEmpty || _heightController.text.isEmpty || _weightController.text.isEmpty) {
                                return;
                              }
                          
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                String uid = user.uid;
                                DateTime birthDate = DateFormat("dd/MM/yyyy").parseStrict(_birthDateController.text);
                          
                                UserProfile student = UserProfile(
                                  id: uid,
                                  name: user.displayName ?? '',
                                  email: user.email ?? '',
                                  phone: user.phoneNumber ?? '',
                                  personalTrainerId: '',
                                  isActive: true,
                                  birthDate: birthDate,
                                  gender: _genderController.text,
                                  height: double.parse(_heightController.text.replaceAll(',', '.')),
                                  weight: double.parse(_weightController.text.replaceAll(',', '.')),
                                  imageUrl: user.photoURL ?? '',
                                  goal: '',
                                  roles: [UserRole.student], 
                                  trainingHistory: [],
                                );
                          
                                UserProfileService userProfileService = UserProfileService();
                                await userProfileService.createUserProfile(student);
                          
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WhatYourGoalView(user: user),
                                  ),
                                );
                              } else {
                                // Handle the case where the user is not logged in
                                print("User is not logged in");
                              }
                            } catch (e) {
                              print(e);
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
