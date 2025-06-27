import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AjoutInfosPage extends StatefulWidget {
  const AjoutInfosPage({super.key});

  @override
  State<AjoutInfosPage> createState() => _AjoutInfosPageState();
}

class _AjoutInfosPageState extends State<AjoutInfosPage> {
  File? _image;
  DateTime? _selectedDate;
  TextEditingController _lieuController = TextEditingController();

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) return true;
    var result = await permission.request();
    return result == PermissionStatus.granted;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera &&
        !(await _requestPermission(Permission.camera)))
      return;
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrage',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );
      if (cropped != null) {
        setState(() {
          _image = File(cropped.path);
        });
      }
    }
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

  void _valider() {
    if (_image == null ||
        _selectedDate == null ||
        _lieuController.text.isEmpty) {
      Get.snackbar(
        "Champ manquant",
        "Veuillez remplir tous les champs (photo, date, lieu)",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    EasyLoading.show(status: 'Envoi en cours...');
    // Appel de la méthode du controller : ici, c’est un exemple
    // Remplacez-le par votre `ctrlEtudiant.uploadInfos(...)`
    Future.delayed(Duration(seconds: 2), () {
      EasyLoading.dismiss();
      Get.snackbar(
        "Succès",
        "Les informations ont été envoyées",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter Photo + Infos")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Image
            _image != null
                ? Image.file(_image!, height: 200)
                : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text("Aucune image sélectionnée")),
                ),
            SizedBox(height: 10),

            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo),
                  label: Text("Galerie"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera),
                  label: Text("Caméra"),
                ),
              ],
            ),
            SizedBox(height: 20),

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
            ElevatedButton.icon(
              onPressed: _valider,
              icon: Icon(Icons.check),
              label: Text("Valider"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
