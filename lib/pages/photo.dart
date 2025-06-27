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

class EstimPhotoPage extends StatefulWidget {
  const EstimPhotoPage({super.key});

  @override
  State<EstimPhotoPage> createState() => _EstimPhotoPageState();
}

class _EstimPhotoPageState extends State<EstimPhotoPage>
    with TickerProviderStateMixin {
  File? _image;
  var ctrlEtudiant = Get.find<EtudiantController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<PhotoAction> photoActions = [
    PhotoAction(
      name: "Galerie",
      description: "Sélectionner depuis la galerie",
      icon: Icons.photo_library,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      action: "gallery",
    ),
    PhotoAction(
      name: "Caméra",
      description: "Prendre une nouvelle photo",
      icon: Icons.camera_alt,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      action: "camera",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Recadrage de l'image
  dynamic _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrage de l\'image',
          toolbarColor: Color(0xFF3B82F6),
          toolbarWidgetColor: Colors.white,
          statusBarColor: Color(0xFF2563EB),
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Color(0xFF3B82F6),
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
      ],
    );
    return croppedFile;
  }

  // Demande de permissions pour la photo
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
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      dynamic cropped = await _cropImage(File(pickedFile.path));
      if (cropped != null) {
        setState(() {
          _image = File(cropped.path);
        });
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  // Sélectionneur utilisant la caméra
  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();

    if (!(await _requestPermission(Permission.camera))) {
      Get.snackbar(
        'Permission requise',
        'L\'accès à la caméra est nécessaire pour prendre une photo',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      dynamic cropped = await _cropImage(File(pickedFile.path));
      if (cropped != null) {
        setState(() {
          _image = File(cropped.path);
        });
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  void _handlePhotoAction(String action) {
    switch (action) {
      case 'gallery':
        _pickImageFromGallery();
        break;
      case 'camera':
        _pickImageFromCamera();
        break;
    }
  }

  void _submitPhoto() {
    if (_image == null) {
      Get.snackbar(
        "Attention !",
        "Veuillez sélectionner une photo avant la validation",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    EasyLoading.show(status: 'Téléchargement...');
    ctrlEtudiant
        .uploadPhoto(_image!)
        .then((value) {
          EasyLoading.dismiss();
          Get.snackbar(
            "Succès !",
            "La photo a été téléchargée avec succès",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: Icon(Icons.check_circle, color: Colors.white),
          );
          
          // Retour au menu principal après 2 secondes
          Future.delayed(Duration(seconds: 2), () {
            Get.back();
          });
        })
        .catchError((error) {
          EasyLoading.dismiss();
          Get.snackbar(
            "Erreur !",
            "Échec du téléchargement de la photo",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: Icon(Icons.error, color: Colors.white),
          );
        });
  }

  void _removePhoto() {
    setState(() {
      _image = null;
    });
    Get.snackbar(
      'Photo supprimée',
      'Sélectionnez une nouvelle photo',
      backgroundColor: Color(0xFF6B7280),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9FAFB),
              Color(0xFFEFF6FF).withOpacity(0.3),
              Color(0xFFF5F3FF).withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header avec retour
                _buildHeader(),
                
                // Contenu principal
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Info étudiant
                        _buildStudentInfo(),
                        SizedBox(height: 32),
                        
                        // Zone de photo
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildPhotoSection(),
                        ),
                        SizedBox(height: 32),
                        
                        // Actions photo si pas d'image
                        if (_image == null) _buildPhotoActions(),
                        
                        // Boutons d'action si image sélectionnée
                        if (_image != null) _buildActionButtons(),
                        
                        SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Color(0xFF374151),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion Photo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Photo d\'identité étudiant',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Obx(() {
      final student = ctrlEtudiant.etudiant.value;
      if (student == null) return Container();
      
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF10B981).withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.nom ?? 'Non renseigné',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Matricule: ${student.matricule}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Classe: ${student.classeLibelle}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _image == null ? _buildEmptyPhotoState() : _buildPhotoPreview(),
    );
  }

  Widget _buildEmptyPhotoState() {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B7280).withOpacity(0.1),
                  Color(0xFF9CA3AF).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo,
              size: 60,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Aucune photo sélectionnée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Prenez une photo ou sélectionnez depuis la galerie',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Aperçu de la photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 300,
                maxWidth: 250,
              ),
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Photo prête pour l\'upload',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoActions() {
    return Column(
      children: [
        Text(
          'Choisissez une option',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 20),
        ...photoActions.map((action) => Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildActionCard(action),
        )).toList(),
      ],
    );
  }

  Widget _buildActionCard(PhotoAction action) {
    return InkWell(
      onTap: () => _handlePhotoAction(action.action),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              action.gradientColors[0].withOpacity(0.1),
              action.gradientColors[1].withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.gradientColors[0].withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: action.gradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: action.gradientColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                action.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    action.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Color(0xFF6B7280),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton Valider
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _submitPhoto,
            icon: Icon(Icons.cloud_upload, size: 24),
            label: Text(
              'Télécharger la photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Color(0xFF10B981).withOpacity(0.3),
            ),
          ),
        ),
        SizedBox(height: 12),
        
        // Boutons secondaires
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _removePhoto,
                  icon: Icon(Icons.delete_outline, size: 20),
                  label: Text('Supprimer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF3F4F6),
                    foregroundColor: Color(0xFF6B7280),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _image = null;
                    });
                  },
                  icon: Icon(Icons.refresh, size: 20),
                  label: Text('Nouvelle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6).withOpacity(0.1),
                    foregroundColor: Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PhotoAction {
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String action;

  PhotoAction({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.action,
  });
}