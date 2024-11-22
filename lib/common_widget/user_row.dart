import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/models/user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class UserRow extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onSendPushNotification;
  final VoidCallback onEditUser;
  final VoidCallback onToggleActiveStatus;

  const UserRow({
    super.key,
    required this.userProfile,
    required this.onSendPushNotification,
    required this.onEditUser,
    required this.onToggleActiveStatus,
  });

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

void _openWhatsApp() async {
  final url = 'https://wa.me/${userProfile.phone}?text=Olá, ${userProfile.name} tudo bem?';
  final Uri whatsappUri = Uri.parse(url);
  try {
    //await canLaunchUrl(whatsappUri);
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  } catch (e) {
    print('Error launching WhatsApp: $e');
  }
}

  void _sendEmail() async {
    final url = 'mailto:${userProfile.email}';
    final Uri emailUri = Uri.parse(url);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: TColor.white, // Alterado para a cor primária
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  userProfile.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  userProfile.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),          // Espaçamento entre o nome e os detalhes
          Text(
            'Idade: ${calculateAge(userProfile.birthDate)} anos',
            style: TextStyle(fontSize: 12, color: TColor.gray),
          ),
          Text(
            'Altura: ${userProfile.height} m',
            style: TextStyle(fontSize: 12, color: TColor.gray),
          ),
          Text(
            'Peso: ${userProfile.weight} kg',
            style: TextStyle(fontSize: 12, color: TColor.gray),
          ),
          Text(
            'Objetivo: ${userProfile.goal}',
            style: TextStyle(fontSize: 12, color: TColor.gray),
          ),          
          // Theme(
          //   data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          //   child: ExpansionTile(
          //     backgroundColor: TColor.lightGray, // Cor de fundo consistente
          //     tilePadding: EdgeInsets.zero, // Remove o padding do título
          //     title: Row(                
          //       children: [
          //         Icon(Icons.more_horiz, color: TColor.lightGray),
          //       ],
          //     ),
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Text(
          //           'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
          //           'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          //           style: TextStyle(fontSize: 12, color: TColor.gray),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.fitness_center, color: TColor.black, size: 20),
                onPressed: onEditUser,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                onPressed: onEditUser,
              ),
              IconButton(
                icon: Icon(
                  userProfile.isActive ? Icons.toggle_on : Icons.toggle_off,
                  color: userProfile.isActive ? Colors.green : Colors.grey,
                  size: 20,
                ),
                onPressed: onToggleActiveStatus,
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                onPressed: _openWhatsApp,
              ),          
            ],
          ),
        ],
      ),
    );
  }
}