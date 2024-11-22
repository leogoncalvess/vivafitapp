import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/common_widget/round_button.dart';
import 'package:vivafit_personal_app/common_widget/round_textfield.dart';
import 'package:vivafit_personal_app/models/user_profile.dart';
import 'package:vivafit_personal_app/services/user_profile_service.dart';
import 'package:vivafit_personal_app/view/manager/student_form_view.dart';
import 'package:vivafit_personal_app/common_widget/user_row.dart'; // Importe o UserRow

class StudentManagementView extends StatefulWidget {
  @override
  _StudentManagementViewState createState() => _StudentManagementViewState();
}

class _StudentManagementViewState extends State<StudentManagementView> {
  List<UserProfile> students = [];
  List<UserProfile> filteredStudents = [];
  TextEditingController searchController = TextEditingController();
  final UserProfileService _userProfileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    students = await _userProfileService.searchUserProfiles(personalTrainerId: ''); // Substitua 'personalTrainerId' pelo ID do professor atual
    setState(() {
      filteredStudents = students;
    });
  }

  void filterStudents(String query) {
    List<UserProfile> filteredList = students.where((student) {
      return student.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredStudents = filteredList;
    });
  }

  void toggleAccess(UserProfile student) async {
    if (student.isActive) {
      await _userProfileService.deactivateUserProfile(student.id);
    } else {
      await _userProfileService.activateUserProfile(student.id);
    }
    _loadStudents();
  }

  void _navigateToForm({UserProfile? student}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentFormView(student: student),
      ),
    );
    _loadStudents();
  }
  

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
        "Administração de alunos",
        style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RoundTextField(
                controller: searchController,
                hitText: "Pesquisar Alunos",
                icon: 'assets/img/user_text.png',
                margin: EdgeInsets.only(bottom: 16.0),
                rigtIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    filterStudents(searchController.text);
                  },
                ),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  UserProfile student = filteredStudents[index];
                  return UserRow(
                    userProfile: student,
                    onSendPushNotification: () {
                      // Adicione a lógica para enviar notificação push
                    },
                    onEditUser: () {
                      _navigateToForm(student: student);
                    },
                    onToggleActiveStatus: () {
                      toggleAccess(student);
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RoundButton(
                  title: "Pré-cadastrar Aluno",
                  onPressed: () async {
                    _navigateToForm();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}