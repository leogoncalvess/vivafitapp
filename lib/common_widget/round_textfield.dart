import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:flutter/services.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String hitText;
  final Widget? rigtIcon;
  final String icon;
  final EdgeInsets? margin;
  final String? validationPattern;
  final String? Function(String?)? validator;
  final String? firebaseStoragePath;
  final List<String>? acceptedFileTypes;
  final List<String>? dropdownItems;
  final void Function(String?)? onChanged;

  RoundTextField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.hitText,
    this.rigtIcon,
    required this.icon,
    this.margin,
    this.validationPattern,
    this.validator,
    this.firebaseStoragePath,
    this.acceptedFileTypes,
    this.dropdownItems,
    this.onChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      controller.text = dateFormat.format(picked);
    }
  }

  void _selectNumber(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int value) {
                  controller.text = (value / 10).toStringAsFixed(1).replaceAll('.', ',');
                },
                children: List<Widget>.generate(1000, (int index) {
                  return Center(
                    child: Text((index / 10).toStringAsFixed(1).replaceAll('.', ',')),
                  );
                }),
              ),
            ),
            CupertinoButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not authenticated');
      return;
    }

    // Verifica se o usuário tem a função 'admin'
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || !(userDoc.data() as Map<String, dynamic>)['roles'].contains('admin')) {
      print('User is not authorized');
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: acceptedFileTypes,
    );

    if (result == null) {
      print('O usuário cancelou a seleção do arquivo.');
      return;
    }
    
    File file = File(result.files.single.path!);

    try {
      final FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'gs://vivafit-personal-app-bdsvxs.appspot.com',
        app: Firebase.app(),
      );

      final String path = '$firebaseStoragePath/${result.files.single.name}';
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        print('Progresso do upload: ${progress.toStringAsFixed(2)}');
      });

      await uploadTask.whenComplete(() => print('Upload concluído com sucesso'));     

    } catch (e) {
      print('Erro inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
          color: TColor.lightGray, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 50,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: TColor.gray,
            ),
          ),
          Expanded(
            child: keyboardType == TextInputType.text && dropdownItems != null
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.text.isEmpty ? null : controller.text,
                      items: dropdownItems?.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: TColor.gray, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        controller.text = newValue ?? '';
                        if (onChanged != null) {
                          onChanged!(newValue);
                        }
                      },
                      isExpanded: true,
                      hint: Text(
                        hitText,
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    ),
                  )
                : TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: hitText,
                      suffixIcon: rigtIcon,
                      hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                    inputFormatters: keyboardType == TextInputType.number 
                        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*'))]
                        : keyboardType == TextInputType.datetime
                            ? [DateTextInputFormatter()]
                            : validationPattern != null 
                                ? [FilteringTextInputFormatter.allow(RegExp(validationPattern!))]
                                : [],
                    validator: validator,
                  ),
          ),
          if (keyboardType == TextInputType.number)
            IconButton(
              icon: Icon(Icons.arrow_drop_down),
              onPressed: () => _selectNumber(context),
            ),
          if (keyboardType == TextInputType.datetime)
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
          if (keyboardType == TextInputType.url)
            IconButton(
              icon: Icon(Icons.video_file_outlined),
              onPressed: () => _uploadFile(),
            ),
        ],
      ),
    );
  }
}

class DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length == 2 || text.length == 5) {
      if (oldValue.text.length < newValue.text.length) {
        return TextEditingValue(
          text: '$text/',
          selection: TextSelection.collapsed(offset: text.length + 1),
        );
      }
    }
    return newValue;
  }
}