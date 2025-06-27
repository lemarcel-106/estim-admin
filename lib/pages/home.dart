import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class EstimMainPage extends StatefulWidget {
  const EstimMainPage({super.key});

  @override
  State<EstimMainPage> createState() => _EstimMainPageState();
}

class _EstimMainPageState extends State<EstimMainPage>
    with TickerProviderStateMixin {
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController matriculeController = TextEditingController();

  // Injection du controller GetX
  final EtudiantController ctrl = Get.put(EtudiantController());

  final List<MenuOption> menuOptions = [
    MenuOption(
      name: "Photo Etudiant",
      description: "Ajouter une photo à la carte étudiante",
      value: "Photos d'identité",
      icon: Icons.camera_alt,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      bgGradientColors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
      route: "/photo",
      requiresStudent: true,
    ),

    MenuOption(
      name: "Menu Principal",
      description: "Accès au tableau de bord",
      value: "Vue d'ensemble",
      icon: Icons.dashboard,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      bgGradientColors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
      route: "/details",
      requiresStudent: true,
    ),
    MenuOption(
      name: "Rechercher Étudiant",
      description: "Nouveau matricule étudiant",
      value: "Changer d'étudiant",
      icon: Icons.search,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      bgGradientColors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      route: "/search",
      requiresStudent: false,
    ),
  ];

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleMenuClick(MenuOption option) {
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
      );
      return;
    }

    // Navigation vers la route appropriée
    Get.toNamed(option.route);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(children: [Text('Rechercher un étudiant')]),
          content: Container(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: matriculeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Matricule de l\'étudiant',
                    hintText: 'Ex: 1234',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2,
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
            ElevatedButton(
              onPressed: () => _searchStudent(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Rechercher'),
            ),
          ],
        );
      },
    );
  }

  void _searchStudent() async {
    if (matriculeController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer un matricule');
      return;
    }

    final id = int.tryParse(matriculeController.text);
    if (id == null) {
      Get.snackbar('Erreur', 'Le matricule doit être un nombre');
      return;
    }

    Navigator.of(context).pop(); // Fermer le dialog
    EasyLoading.show(status: 'Recherche...');

    try {
      await ctrl.getEtudiant(id);
      EasyLoading.dismiss();

      if (ctrl.etudiant.value != null) {
        setState(() {}); // Refresh UI
        Get.snackbar(
          'Succès',
          'Étudiant trouvé: ${ctrl.etudiant.value!.nom}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Erreur', 'Étudiant non trouvé');
    }

    matriculeController.clear();
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
              Color(0xFFF9FAFB),
              Color(0xFFEFF6FF).withOpacity(0.3),
              Color(0xFFF5F3FF).withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(height: 32),
                  _buildLogo(),
                  SizedBox(height: 24),

                  // Info étudiant actuel si disponible
                  Obx(
                    () =>
                        ctrl.etudiant.value != null
                            ? _buildStudentInfo()
                            : Container(),
                  ),

                  SizedBox(height: 24),

                  // Menu d'options
                  Expanded(
                    child: ListView.builder(
                      itemCount: menuOptions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: _buildMenuCard(menuOptions[index]),
                        );
                      },
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
          'ESTIM Mobile Administration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
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

  Widget _buildStudentInfo() {
    final student = ctrl.etudiant.value!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
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
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuOption option) {
    bool isSelected = selectedOption == option.name;
    bool isDisabled = option.requiresStudent && ctrl.etudiant.value == null;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Card(
          elevation: isSelected ? 12 : 6,
          shadowColor: option.gradientColors[0].withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isSelected
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
                  colors: option.bgGradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: option.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: option.gradientColors[0].withOpacity(0.3),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            if (option.requiresStudent &&
                                ctrl.etudiant.value == null)
                              Icon(
                                Icons.lock,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          option.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          option.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Color(0xFF3B82F6)
                              : Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow:
                          isSelected
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
}

class MenuOption {
  final String name;
  final String description;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Color> bgGradientColors;
  final String route;
  final bool requiresStudent;

  MenuOption({
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
