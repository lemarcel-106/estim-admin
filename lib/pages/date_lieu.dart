import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class AjoutInfosPage extends StatefulWidget {
  const AjoutInfosPage({super.key});

  @override
  State<AjoutInfosPage> createState() => _AjoutInfosPageState();
}

class _AjoutInfosPageState extends State<AjoutInfosPage> {
  DateTime? _selectedDate;
  TextEditingController _lieuController = TextEditingController();

  var ctrlEtudiant = Get.find<EtudiantController>();

  void initState() {
    super.initState();
    ctrlEtudiant = Get.find<EtudiantController>();
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: now,
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _valider() async {
    FocusScope.of(context).unfocus();

    if (_selectedDate == null) {
      EasyLoading.showError(
        'Veuillez sélectionner une date de naissance',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (_lieuController.text.isEmpty || _lieuController.text.length < 2) {
      EasyLoading.showError(
        'Veuillez entrer le lieu de naissance',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    EasyLoading.show(status: 'Envoi en cours...');

    final uri = Uri.parse(
      '$HOST/api/etudiants/${ctrlEtudiant.etudiant.value!.matricule}/datelieu/',
    );

    final payload = {
      'date_naissance':
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
      'lieu_naissance': _lieuController.text,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final dataMap = json.decode(response.body) as Map<String, dynamic>;
        log('Réponse: $dataMap');

        EasyLoading.dismiss();
        Get.snackbar(
          "Succès",
          "Les informations ont été envoyées",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        log('Erreur ${response.statusCode}: ${response.body}');
        EasyLoading.showError(
          'Erreur lors de l\'envoi (${response.statusCode})',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      log('Exception: $e');
      EasyLoading.showError(
        'Erreur de connexion. Réessayez.',
        duration: const Duration(seconds: 2),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis à jour Date et Lieu de naissance")),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/banner.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(136, 0, 0, 0),
              BlendMode.color,
            ),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Boutons
                  SizedBox(height: 50),

                  // Date de naissance
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date de naissance',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                            : "Choisir une date",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Lieu de naissance
                  TextField(
                    controller: _lieuController,
                    decoration: InputDecoration(
                      labelText: "Lieu de naissance",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Bouton Valider
                  Container(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _valider,
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text(
                        "Enregistrer",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
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
