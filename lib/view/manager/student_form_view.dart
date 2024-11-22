import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/common_widget/round_button.dart';
import 'package:vivafit_personal_app/common_widget/round_textfield.dart';
import 'package:vivafit_personal_app/models/roles.dart';
import 'package:vivafit_personal_app/models/user_profile.dart';
import 'package:vivafit_personal_app/services/user_profile_service.dart';

class StudentFormView extends StatefulWidget {
  final UserProfile? student;

  const StudentFormView({super.key, this.student});

  @override
  _StudentFormViewState createState() => _StudentFormViewState();
}

class _StudentFormViewState extends State<StudentFormView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _personalTrainerIdController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _studentService = UserProfileService();  

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _emailController.text = widget.student!.email;
      _phoneController.text = widget.student!.phone;
      _genderController.text = widget.student!.gender;
      _heightController.text = widget.student!.height.toString();
      _weightController.text = widget.student!.weight.toString();
      _goalController.text = widget.student!.goal;
      _personalTrainerIdController.text = widget.student!.personalTrainerId;
      _imageUrlController.text = widget.student!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _personalTrainerIdController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      UserProfile student = UserProfile(
        id: widget.student!.id,
        gender: _genderController.text,
        birthDate: DateTime.now(), // Ajuste conforme necessário
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        goal: _goalController.text,
        isActive: true,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        personalTrainerId: _personalTrainerIdController.text,
        imageUrl: _imageUrlController.text,
        roles: [UserRole.student], 
        trainingHistory: [],
      );

      if (widget.student == null) {
        await _studentService.saveUserProfile(student);
      } else {
        await _studentService.updateUserProfile(student);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aluno salvo com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Adicionar Aluno' : 'Editar Aluno'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  RoundTextField(
                    controller: _nameController,
                    hitText: "Nome",
                    icon: "assets/img/name.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _emailController,
                    hitText: "Email",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _phoneController,
                    hitText: "Telefone",
                    icon: "assets/img/phone.png",
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um número de telefone';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _genderController,
                    hitText: "Gênero",
                    icon: "assets/img/gender.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um gênero';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _heightController,
                    hitText: "Altura",
                    icon: "assets/img/height.png",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Por favor, insira uma altura válida';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _weightController,
                    hitText: "Peso",
                    icon: "assets/img/weight.png",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Por favor, insira um peso válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _goalController,
                    hitText: "Objetivo",
                    icon: "assets/img/goal.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um objetivo';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _personalTrainerIdController,
                    hitText: "ID do Personal Trainer",
                    icon: "assets/img/trainer.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o ID do personal trainer';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _imageUrlController,
                    hitText: "URL da Imagem",
                    icon: "assets/img/image.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a URL da imagem';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.07),
                  RoundButton(
                    title: "Salvar",
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}