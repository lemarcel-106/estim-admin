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

class PhotoView extends StatefulWidget {
  const PhotoView({super.key});

  @override
  State<PhotoView> createState() => _PhotoViewState();
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

class _PhotoViewState extends State<PhotoView> {
  File? _image;
  var ctrlEtudiant = Get.find<EtudiantController>();

  void initState() {
    super.initState();
    ctrlEtudiant = Get.find<EtudiantController>();
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
                        child: Image.asset('assets/images/chapeau.png'),
                      ),
                    ],
                  ),
                ),
                _image == null
                    ? Expanded(
                      child: Container(
                        child: const Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, size: 150),
                              SizedBox(height: 5),
                              Text(
                                'Aucune photo',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 244, 244, 244),
                                  fontFamily: "font1",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                Container(
                  // color: Color.fromARGB(255, 9, 138, 13),
                  padding: const EdgeInsets.all(10),
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

                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buttonAction(
                        const Icon(Icons.photo),
                        _pickImageFromGalery,
                      ),
                      if (_image != null)
                        buttonAction(
                          const Icon(
                            Icons.check,
                            size: 50,
                            color: Colors.green,
                          ),
                          submit,
                        ),

                      // if (_image != null)
                      InkWell(
                        onTap: () => Get.offAndToNamed('/details'),
                        child: Container(
                          height: 70,
                          width: 70,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                            color: Colors.white,
                          ),
                          child: Icon(Icons.close, size: 50, color: Colors.red),
                        ),
                      ),

                      buttonAction(
                        const Icon(Icons.photo_camera),
                        _pickImageFromCamera,
                      ),
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
