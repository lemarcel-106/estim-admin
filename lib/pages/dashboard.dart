import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// Ajout des nouveaux imports
import '../controllers/app_controllers.dart';
import '../utils/app_utils.dart';

class EstimMainDashboard extends StatefulWidget {
  const EstimMainDashboard({super.key});

  @override
  State<EstimMainDashboard> createState() => _EstimMainDashboardState();
}

class _EstimMainDashboardState extends State<EstimMainDashboard>
    with TickerProviderStateMixin {
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController matriculeController = TextEditingController();

  // Injection des controllers GetX (anciens et nouveaux)
  final EtudiantController ctrl = Get.put(EtudiantController());
  final MainAppController mainController = Get.put(MainAppController());
  final ExamenController examenController = Get.put(ExamenController());
  final FinanceController financeController = Get.put(FinanceController());

  final List<DashboardMenuOption> menuOptions = [
    // Section Gestion Étudiants
    DashboardMenuOption(
      category: "Gestion Étudiants",
      name: "Gestion Photos",
      description: "Ajouter et gérer les photos d'identité",
      value: "Photos étudiantes",
      icon: Icons.camera_alt,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      bgGradientColors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
      route: "/photo",
      requiresStudent: true,
    ),
    DashboardMenuOption(
      category: "Gestion Étudiants",
      name: "Informations Personnelles",
      description: "Date et lieu de naissance",
      value: "Données civiles",
      icon: Icons.person_outline,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      bgGradientColors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
      route: "/date-lieu",
      requiresStudent: true,
    ),
    DashboardMenuOption(
      category: "Gestion Étudiants",
      name: "Menu Étudiant",
      description: "Tableau de bord complet",
      value: "Vue d'ensemble",
      icon: Icons.dashboard,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      bgGradientColors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
      route: "/details",
      requiresStudent: true,
    ),

    // Section Académique (nouvelles fonctionnalités intégrées)
    DashboardMenuOption(
      category: "Académique",
      name: "Gestion des Classes",
      description: "Classes et étudiants inscrits",
      value: "Organisation scolaire",
      icon: Icons.school,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      bgGradientColors: [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
      route: "/classes",
      requiresStudent: false,
    ),
    DashboardMenuOption(
      category: "Académique",
      name: "Gestion des Notes",
      description: "Notes, statistiques et évaluations",
      value: "Système de notation",
      icon: Icons.assignment,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      bgGradientColors: [Color(0xFFFDF2F8), Color(0xFFFCE7F3)],
      route: "/notes",
      requiresStudent: false,
    ),
    DashboardMenuOption(
      category: "Académique",
      name: "Examens & Évaluations",
      description: "Programmer et gérer les examens",
      value: "Évaluations complètes",
      icon: Icons.quiz,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      bgGradientColors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      route: "/examens",
      requiresStudent: false,
    ),

    // Section Administration (nouvelles fonctionnalités)
    DashboardMenuOption(
      category: "Administration",
      name: "Rechercher Étudiant",
      description: "Nouveau matricule étudiant",
      value: "Changer d'étudiant",
      icon: Icons.search,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      bgGradientColors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
      route: "/search",
      requiresStudent: false,
    ),
    DashboardMenuOption(
      category: "Administration",
      name: "Gestion Financière",
      description: "Frais de scolarité et paiements",
      value: "Finances & Rapports",
      icon: Icons.account_balance_wallet,
      gradientColors: [Color(0xFF059669), Color(0xFF047857)],
      bgGradientColors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
      route: "/finances",
      requiresStudent: false,
    ),
    DashboardMenuOption(
      category: "Administration",
      name: "Statistiques Générales",
      description: "Vue d'ensemble de l'établissement",
      value: "Tableau de bord",
      icon: Icons.analytics,
      gradientColors: [Color(0xFF84CC16), Color(0xFF65A30D)],
      bgGradientColors: [Color(0xFFF7FEE7), Color(0xFFECFCCB)],
      route: "/analytics",
      requiresStudent: false,
    ),
  ];

  // Groupement des options par catégorie
  Map<String, List<DashboardMenuOption>> get groupedOptions {
    Map<String, List<DashboardMenuOption>> grouped = {};
    for (var option in menuOptions) {
      if (!grouped.containsKey(option.category)) {
        grouped[option.category] = [];
      }
      grouped[option.category]!.add(option);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Initialiser l'application avec les nouveaux controllers
    _initializeApp();
  }

  // Nouvelle méthode d'initialisation
  void _initializeApp() async {
    try {
      // Pré-charger les données essentielles
      await Future.wait([
        examenController.loadSessions(),
        financeController.loadMoisDisponibles(),
      ]);
      
      // Afficher le statut d'initialisation
      NotificationService.showSuccess('Application initialisée avec succès');
    } catch (e) {
      NotificationService.showError('Erreur d\'initialisation: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleMenuClick(DashboardMenuOption option) {
    setState(() {
      selectedOption = option.name;
    });

    if (option.route == "/search") {
      _showSearchDialog();
      return;
    }

    // Vérifier si un étudiant est sélectionné pour les options qui le requièrent
    if (option.requiresStudent && ctrl.etudiant.value == null) {
      Get.snackbar(
        'Attention',
        'Veuillez d\'abord rechercher un étudiant',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: Icon(Icons.warning, color: Colors.white),
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Navigation intelligente avec pré-chargement des données
    _navigateToModule(option);
  }

  // Nouvelle méthode de navigation intelligente
  void _navigateToModule(DashboardMenuOption option) async {
    try {
      EasyLoading.show(status: 'Chargement...');
      
      switch (option.route) {
        case "/examens":
          await examenController.loadInitialData();
          Get.toNamed(option.route);
          break;
        case "/finances":
          // Si un étudiant est sélectionné, charger ses frais
          if (ctrl.etudiant.value != null) {
            await financeController.loadFraisEtudiant(ctrl.etudiant.value!.matricule!);
          }
          Get.toNamed(option.route);
          break;
        case "/notes":
          // Pré-charger les notes si un étudiant est sélectionné
          if (ctrl.etudiant.value != null) {
            await Future.wait([
              examenController.loadNotesDevoirs(matricule: ctrl.etudiant.value!.matricule),
              examenController.loadNotesExamens(matricule: ctrl.etudiant.value!.matricule),
            ]);
          }
          Get.toNamed(option.route);
          break;
        default:
          Get.toNamed(option.route);
      }
      
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      NotificationService.showError('Erreur de navigation: $e');
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rechercher un étudiant',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: TextField(
                    controller: matriculeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6, // Augmenté pour supporter plus de matricules
                    buildCounter: (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) => null,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      color: Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Matricule de l'étudiant',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Ex : 12345',
                      prefixIcon: const Icon(
                        Icons.school,
                        color: Color(0xFF3B82F6),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Entrez le matricule pour accéder aux données de l\'étudiant',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                matriculeController.clear();
              },
              child: Text('Annuler'),
            ),
            Obx(() => ElevatedButton(
              onPressed: ctrl.isLoading.value ? null : () => _searchStudent(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ctrl.isLoading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Rechercher'),
            )),
          ],
        );
      },
    );
  }

  void _searchStudent() async {
    // Validation améliorée
    if (matriculeController.text.isEmpty) {
      NotificationService.showError('Veuillez entrer un matricule');
      return;
    }

    if (!DataValidationUtils.validateMatricule(matriculeController.text)) {
      NotificationService.showError('Matricule invalide (minimum 4 caractères)');
      return;
    }

    final id = int.tryParse(matriculeController.text);
    if (id == null) {
      NotificationService.showError('Le matricule doit être un nombre');
      return;
    }

    Navigator.of(context).pop(); // Fermer le dialog
    EasyLoading.show(status: 'Recherche...');

    try {
      await ctrl.getEtudiant(id);
      EasyLoading.dismiss();

      if (ctrl.etudiant.value != null) {
        setState(() {}); // Refresh UI
        
        // Notification de succès améliorée
        Get.snackbar(
          'Succès',
          'Étudiant trouvé: ${ctrl.etudiant.value!.nom}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(Icons.check_circle, color: Colors.white),
        );
        
        // Pré-charger les données de l'étudiant en arrière-plan
        _preloadStudentData();
      }
    } catch (e) {
      EasyLoading.dismiss();
      NotificationService.showError('Étudiant non trouvé');
    }

    matriculeController.clear();
  }

  // Nouvelle méthode pour pré-charger les données de l'étudiant
  void _preloadStudentData() async {
    if (ctrl.etudiant.value?.matricule != null) {
      try {
        // Charger les données financières et notes en arrière-plan
        await Future.wait([
          financeController.loadFraisEtudiant(ctrl.etudiant.value!.matricule!),
          examenController.loadNotesDevoirs(matricule: ctrl.etudiant.value!.matricule),
          examenController.loadNotesExamens(matricule: ctrl.etudiant.value!.matricule),
        ]);
      } catch (e) {
        // Gérer silencieusement les erreurs de pré-chargement
        print('Erreur de pré-chargement: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 1, 79, 156),
              Color.fromARGB(255, 8, 83, 18).withOpacity(0.3),
              Color.fromARGB(255, 1, 1, 2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                SizedBox(height: 32),
                _buildLogo(),
                SizedBox(height: 5),

                // Info étudiant actuel si disponible (améliorée)
                Obx(() => ctrl.etudiant.value != null
                    ? _buildStudentInfo()
                    : _buildSystemStatus()),

                SizedBox(height: 10),

                // Menu d'options groupées
                Expanded(child: _buildGroupedMenu()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        SizedBox(height: 8),
        Container(
          child: Image(
            image: AssetImage('assets/images/logo.png'),
            height: 100,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ESTIM Mobile\nAdministration',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 96,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // Widget amélioré pour les informations étudiant
  Widget _buildStudentInfo() {
    final student = ctrl.etudiant.value!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.nom ?? 'Non renseigné',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Matricule: ${student.matricule} • Classe: ${student.classeLibelle}',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              // Bouton d'actions rapides
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Color(0xFF10B981)),
                onSelected: (value) => _handleQuickAction(value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'notes',
                    child: Row(
                      children: [
                        Icon(Icons.grade, size: 18, color: Color(0xFFEC4899)),
                        SizedBox(width: 8),
                        Text('Voir Notes'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'finances',
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 18, color: Color(0xFF059669)),
                        SizedBox(width: 8),
                        Text('Voir Finances'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 18, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 8),
                        Text('Détails Complets'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Indicateurs de statut des données
          SizedBox(height: 12),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataIndicator(
                'Notes',
                examenController.notesDevoirs.length + examenController.notesExamens.length,
                Icons.grade,
                Color(0xFFEC4899),
              ),
              _buildDataIndicator(
                'Paiements',
                financeController.fraisEtudiants.length,
                Icons.payment,
                Color(0xFF059669),
              ),
              _buildDataIndicator(
                'Sessions',
                examenController.sessions.length,
                Icons.event,
                Color(0xFF3B82F6),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // Nouveau widget pour afficher le statut du système
  Widget _buildSystemStatus() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Obx(() => Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mainController.isInitialized.value ? Icons.check_circle : Icons.hourglass_empty,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainController.isInitialized.value 
                      ? 'Système Opérationnel'
                      : 'Initialisation...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Sessions: ${examenController.sessions.length} • Mois: ${financeController.moisDisponibles.length}',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  // Nouvel indicateur de données
  Widget _buildDataIndicator(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  // Gestionnaire d'actions rapides
  void _handleQuickAction(String action) {
    switch (action) {
      case 'notes':
        _navigateToModule(DashboardMenuOption(
          category: '', name: '', description: '', value: '', icon: Icons.grade,
          gradientColors: [], bgGradientColors: [], route: '/notes',
        ));
        break;
      case 'finances':
        _navigateToModule(DashboardMenuOption(
          category: '', name: '', description: '', value: '', icon: Icons.payment,
          gradientColors: [], bgGradientColors: [], route: '/finances',
        ));
        break;
      case 'details':
        Get.toNamed('/details');
        break;
    }
  }

  Widget _buildGroupedMenu() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedOptions.entries.map((entry) {
          String category = entry.key;
          List<DashboardMenuOption> options = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      category,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ...options.asMap().entries.map((optionEntry) {
                int index = optionEntry.key;
                DashboardMenuOption option = optionEntry.value;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: _buildMenuCard(option),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuCard(DashboardMenuOption option) {
    bool isSelected = selectedOption == option.name;
    bool isDisabled = option.requiresStudent && ctrl.etudiant.value == null;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Card(
          elevation: isSelected ? 12 : 6,
          shadowColor: option.gradientColors.isNotEmpty 
              ? option.gradientColors[0].withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSelected
                ? BorderSide(color: Color(0xFF3B82F6), width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: isDisabled ? null : () => handleMenuClick(option),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: option.bgGradientColors.isNotEmpty 
                      ? option.bgGradientColors
                      : [Colors.white, Colors.grey.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: option.gradientColors.isNotEmpty
                            ? option.gradientColors
                            : [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: option.gradientColors.isNotEmpty
                              ? option.gradientColors[0].withOpacity(0.3)
                              : Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(option.icon, size: 28, color: Colors.white),
                  ),

                  SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            if (option.requiresStudent && ctrl.etudiant.value == null)
                              Icon(
                                Icons.lock,
                                size: 16,
                                color: Color(0xFF6B7280),
                              )
                            else if (option.requiresStudent && ctrl.etudiant.value != null)
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          option.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: option.gradientColors.isNotEmpty
                                    ? option.gradientColors[0].withOpacity(0.1)
                                    : Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                option.value,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: option.gradientColors.isNotEmpty
                                      ? option.gradientColors[0]
                                      : Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                            Spacer(),
                            // Indicateur de nouveautés pour les nouvelles fonctionnalités
                            if (_isNewFeature(option.route))
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF3B82F6)
                          : Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: isSelected ? Colors.white : Color(0xFF6B7280),
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

  // Méthode pour identifier les nouvelles fonctionnalités
  bool _isNewFeature(String route) {
    final newFeatures = ['/examens', '/finances', '/analytics'];
    return newFeatures.contains(route);
  }
}

class DashboardMenuOption {
  final String category;
  final String name;
  final String description;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Color> bgGradientColors;
  final String route;
  final bool requiresStudent;

  DashboardMenuOption({
    required this.category,
    required this.name,
    required this.description,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.bgGradientColors,
    required this.route,
    this.requiresStudent = false,
  });
}
