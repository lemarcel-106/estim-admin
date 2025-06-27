import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

// const HOST = "https://gestion.estim-online.com";
const HOST = "http://192.168.100.22:8000";

/// Modèle de l'étudiant
class Etudiant {
  final String? nom;
  final String? matricule;
  final String? classeLibelle;

  Etudiant({this.matricule, this.nom, this.classeLibelle});

  /// Crée une instance d'Etudiant à partir du JSON
  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      matricule: json['matricule']?.toString(),
      nom: json['nom'] as String?,
      classeLibelle: json['classe'] as String?,
    );
  }
}

/// Controller GetX pour gérer l'état et les opérations réseau de l'étudiant
class EtudiantController extends GetxController {
  EtudiantController();

  final Rx<Etudiant?> etudiant = Rx<Etudiant?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Méthode pour récupérer l'étudiant par matricule
  Future<Etudiant> getEtudiant(int idEtudiant) async {
    final result = await fetchEtudiant(idEtudiant);
    etudiant.value = result;
    return result;
  }

  /// Méthode pour uploader la photo de l'étudiant
  Future<void> uploadPhoto(File imageFile) async {
    await uploadPhotoEtudiant(
      idEtudiant: etudiant.value!.matricule.toString(),
      imageFile: imageFile,
    );
  }
}

/// Service: récupère l'étudiant via GET et décode le JSON brut (compatible Django Ninja)
Future<Etudiant> fetchEtudiant(int idEtudiant) async {
  final uri = Uri.parse('$HOST/api/etudiants/by-matricule/$idEtudiant/');
  final response = await http.get(uri);
  Map<String, dynamic> dataMap = {};

  try {
    if (response.statusCode == 200) {
      // Django Ninja renvoie directement l'objet JSON de l'étudiant
      dataMap = json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException('Échec du GET (status ${response.statusCode})');
    }
  } catch (e) {
    EasyLoading.showError(
      'Erreur de matricule | Reessayer !! ',
      duration: const Duration(seconds: 2),
    );
    EasyLoading.dismiss();
  }

  return Etudiant.fromJson(dataMap);
}

/// Service: upload de la photo via POST multipart
Future<void> uploadPhotoEtudiant({
  required String idEtudiant,
  required File imageFile,
  String? token,
}) async {
  final uri = Uri.parse('$HOST/api/etudiants/$idEtudiant/photo/');
  final request = http.MultipartRequest('POST', uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  // Détection automatique du type MIME
  final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
  final fileName = path.basename(imageFile.path);
  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: fileName,
      // contentType: MediaType.parse(mimeType),
    ),
  );

  final streamed = await request.send();
  final resp = await http.Response.fromStream(streamed);

  if (resp.statusCode != 200) {
    throw HttpException('Échec du POST (status ${resp.statusCode})');
  }
}
