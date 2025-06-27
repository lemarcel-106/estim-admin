import 'dart:convert';
import 'dart:developer';
import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class EstimDateLieuPage extends StatefulWidget {
  const EstimDateLieuPage({super.key});

  @override
  State<EstimDateLieuPage> createState() => _EstimDateLieuPageState();
}

class _EstimDateLieuPageState extends State<EstimDateLieuPage>
    with TickerProviderStateMixin {
  DateTime? _selectedDate;
  TextEditingController _lieuController = TextEditingController();
  var ctrlEtudiant = Get.find<EtudiantController>();
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    
    // Animation principale
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Animation de pulsation pour le bouton
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Écouter les changements pour validation
    _lieuController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _selectedDate != null && 
                     _lieuController.text.isNotEmpty && 
                     _lieuController.text.length >= 2;
    });
    
    if (_isFormValid) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _validateForm();
    }
  }

  void _valider() async {
    if (!_isFormValid) return;
    
    FocusScope.of(context).unfocus();

    EasyLoading.show(status: 'Enregistrement en cours...');

    final uri = Uri.parse(
      '$HOST/api/etudiants/${ctrlEtudiant.etudiant.value!.matricule}/datelieu/',
    );

    final payload = {
      'date_naissance':
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
      'lieu_naissance': _lieuController.text.trim(),
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
        
        // Animation de succès
        _animationController.reverse().then((_) {
          Get.snackbar(
            "Succès !",
            "Les informations ont été enregistrées avec succès",
            backgroundColor: Color(0xFF10B981),
            colorText: Colors.white,
            icon: Icon(Icons.check_circle, color: Colors.white),
            snackPosition: SnackPosition.TOP,
          );
          
          // Retour automatique après 2 secondes
          Future.delayed(Duration(seconds: 2), () {
            Get.back();
          });
        });
      } else {
        log('Erreur ${response.statusCode}: ${response.body}');
        EasyLoading.dismiss();
        Get.snackbar(
          "Erreur",
          "Échec de l'enregistrement (${response.statusCode})",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      log('Exception: $e');
      EasyLoading.dismiss();
      Get.snackbar(
        "Erreur de connexion",
        "Vérifiez votre connexion internet et réessayez",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.wifi_off, color: Colors.white),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                // Header
                _buildHeader(),
                
                // Contenu principal
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Info étudiant
                          _buildStudentInfo(),
                          SizedBox(height: 32),
                          
                          // Section titre
                          _buildSectionTitle(),
                          SizedBox(height: 32),
                          
                          // Formulaire
                          _buildFormCard(),
                          SizedBox(height: 32),
                          
                          // Bouton de validation
                          _buildSubmitButton(),
                          SizedBox(height: 24),
                          
                          // Information de sécurité
                          _buildSecurityInfo(),
                        ],
                      ),
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
                  'Informations Civiles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Date et lieu de naissance',
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
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_calendar,
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

  Widget _buildSectionTitle() {
    return Column(
      children: [
        Text(
          'Compléter le profil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Renseignez la date et le lieu de naissance',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Date de naissance
          _buildDateSection(),
          SizedBox(height: 32),
          
          // Section Lieu de naissance
          _buildLieuSection(),
          SizedBox(height: 24),
          
          // Indicateur de validation
          _buildValidationIndicator(),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Date de naissance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedDate != null 
                  ? Color(0xFF10B981) 
                  : Color(0xFFD1D5DB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _selectedDate != null 
                ? Color(0xFF10B981).withOpacity(0.05)
                : Color(0xFFF9FAFB),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: _selectedDate != null 
                    ? Color(0xFF10B981) 
                    : Color(0xFF6B7280),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : "Sélectionner une date",
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null 
                        ? Color(0xFF111827) 
                        : Color(0xFF6B7280),
                      fontWeight: _selectedDate != null 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_selectedDate != null) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
              SizedBox(width: 6),
              Text(
                'Date sélectionnée',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLieuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Lieu de naissance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _lieuController,
          decoration: InputDecoration(
            hintText: "Ex: Brazzaville, Congo",
            prefixIcon: Icon(
              Icons.place,
              color: _lieuController.text.isNotEmpty 
                ? Color(0xFF10B981) 
                : Color(0xFF6B7280),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFD1D5DB), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _lieuController.text.isNotEmpty 
                  ? Color(0xFF10B981) 
                  : Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: _lieuController.text.isNotEmpty 
              ? Color(0xFF10B981).withOpacity(0.05)
              : Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
          ),
          onChanged: (value) => _validateForm(),
        ),
        if (_lieuController.text.isNotEmpty && _lieuController.text.length >= 2) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
              SizedBox(width: 6),
              Text(
                'Lieu renseigné',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildValidationIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isFormValid 
          ? Color(0xFF10B981).withOpacity(0.1)
          : Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFormValid 
            ? Color(0xFF10B981).withOpacity(0.3)
            : Color(0xFFF59E0B).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isFormValid ? Icons.check_circle : Icons.info,
            color: _isFormValid ? Color(0xFF10B981) : Color(0xFFF59E0B),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _isFormValid 
                ? 'Formulaire complet - Prêt à enregistrer'
                : 'Veuillez remplir tous les champs requis',
              style: TextStyle(
                fontSize: 14,
                color: _isFormValid ? Color(0xFF10B981) : Color(0xFFF59E0B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isFormValid ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isFormValid ? _valider : null,
              icon: Icon(
                Icons.save,
                size: 24,
                color: Colors.white,
              ),
              label: Text(
                'Enregistrer les informations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid 
                  ? Color(0xFF10B981) 
                  : Color(0xFF9CA3AF),
                disabledBackgroundColor: Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: _isFormValid ? 6 : 0,
                shadowColor: _isFormValid 
                  ? Color(0xFF10B981).withOpacity(0.3) 
                  : Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Sécurité des données',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Vos informations sont protégées et utilisées uniquement pour l\'administration scolaire. Toutes les données sont cryptées et stockées de manière sécurisée.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Copyright ESTIM ECOLE • Design by TTM',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}