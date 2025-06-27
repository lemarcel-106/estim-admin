import 'dart:io';
import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class MenuDestails extends StatefulWidget {
  const MenuDestails({super.key});

  @override
  State<MenuDestails> createState() => _MenuDestailsState();
}

// Recadrage de l'image
dynamic _cropImage(File imageFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Recadrage de l\'image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPresetCustom(),
        ],
      ),
    ],
  );
  // print("Le crop file");
  // print(croppedFile!.path);
  // print(croppedFile);
  return croppedFile;
}

// Activité principal de la page

class _MenuDestailsState extends State<MenuDestails> {
  File? _image;
  var ctrlEtudiant = Get.find<EtudiantController>();

  void initState() {
    super.initState();
    ctrlEtudiant = Get.find<EtudiantController>();

    // print(Get.arguments['matricule']);
    // print(Get.arguments['nom']);
    // print(Get.arguments['prenom']);
    // print(Get.arguments['classe']);
  }

  // Demande de permissions pour la photo .
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  // Sélectionner de l'image depuis la galerie
  Future<void> _pickImageFromGalery() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      dynamic cropped = await _cropImage(File(pickedFile.path));
      if (cropped != null) {
        setState(() {
          _image = File(cropped.path);
        });
      }
    }
  }

  // Sélectionneur utilisant la caméra
  Future<void> _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();

    if (!(await _requestPermission(Permission.camera))) {
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      dynamic cropped = await _cropImage(File(pickedFile.path));
      if (cropped != null) {
        setState(() {
          _image = File(cropped.path);
        });
      }
    }
  }

  // Le build de l'activité principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 55, 100, 70),
      body: SafeArea(
        child: Obx(
          () => Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
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
                  // color: Color.fromARGB(255, 9, 138, 13),
                  padding: EdgeInsets.all(20).copyWith(top: 10, bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Nom : ${ctrlEtudiant.etudiant.value?.nom} ',
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "font1",
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Classe : ${ctrlEtudiant.etudiant.value?.classeLibelle}',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "font1",
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Matricule : ${ctrlEtudiant.etudiant.value?.matricule}',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "font1",
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Image.asset(
                          'assets/images/chapeau.png',
                          height: 65,
                          width: 65,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0).copyWith(top: 50),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuButton(
                          text: 'Ajouter une photo',
                          icon: Icons.photo_camera,
                          color: Colors.white,
                          onPressed: () => Get.toNamed('/photo'),
                        ),
                        SizedBox(height: 20),
                        MenuButton(
                          text: 'La date et le lieu de naissance',
                          icon: Icons.calendar_today,
                          color: Colors.white,
                          onPressed: () => Get.toNamed('/date-lieu'),
                        ),

                        SizedBox(height: 20),
                        MenuButton(
                          text: 'Changer de matricule',
                          icon: Icons.exit_to_app,
                          color: const Color.fromARGB(255, 151, 148, 148),
                          onPressed: () => Get.toNamed('/'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  submit() {
    if (_image == null) {
      Get.snackbar(
        "Attention !!",
        "Veuillez photographier l'étudiant avant la validation de la photo",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackStyle: SnackStyle.GROUNDED,
        duration: const Duration(seconds: 3),
      );
    } else {
      EasyLoading.show(status: 'Chargement...');
      ctrlEtudiant
          .uploadPhoto(_image!)
          .then((value) {
            EasyLoading.dismiss();
            Get.snackbar(
              "Succès !!",
              "La photo a été téléchargée avec succès",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackStyle: SnackStyle.GROUNDED,
              duration: const Duration(seconds: 3),
            );
          })
          .catchError((error) {
            EasyLoading.dismiss();
            Get.snackbar(
              "Erreur !!",
              "Échec du téléchargement de la photo",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackStyle: SnackStyle.GROUNDED,
              duration: const Duration(seconds: 3),
            );
          });
    }
  }

  Widget buttonAction(icon, function) {
    return InkWell(
      onTap: () => function(),
      child: Container(
        height: 70,
        width: 70,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          color: Colors.white,
        ),
        child: icon,
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const MenuButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
