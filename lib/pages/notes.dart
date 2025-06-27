import 'dart:convert';
import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class NotesController extends GetxController {
  final RxList<ClasseModel> classes = <ClasseModel>[].obs;
  final Rx<NotesEtudiantModel?> notesEtudiant = Rx<NotesEtudiantModel?>(null);
  final Rx<StatistiquesModel?> statistiques = Rx<StatistiquesModel?>(null);
  final RxBool isLoading = false.obs;

  Future<void> loadClasses() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('$HOST/api/classes/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        classes.value = data.map((json) => ClasseModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les classes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getNotesEtudiant(String matricule) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$HOST/api/notes/etudiant/$matricule')
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        notesEtudiant.value = NotesEtudiantModel.fromJson(data);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les notes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getStatistiquesClasse(int classeId, {int? sessionId}) async {
    isLoading.value = true;
    try {
      String url = '$HOST/api/notes/statistiques/classe/$classeId';
      if (sessionId != null) url += '?session_id=$sessionId';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        statistiques.value = StatistiquesModel.fromJson(data);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les statistiques');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saisirNotesEnMasse(String type, int evaluationId, List<NoteInput> notes) async {
    try {
      EasyLoading.show(status: 'Enregistrement...');
      
      final response = await http.post(
        Uri.parse('$HOST/api/notes/bulk-create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': type,
          'evaluation_id': evaluationId,
          'notes': notes.map((n) => n.toJson()).toList(),
        }),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Notes enregistrées avec succès',
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw Exception('Erreur lors de l\'enregistrement');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'enregistrement des notes');
    } finally {
      EasyLoading.dismiss();
    }
  }
}

class EstimNotesPage extends StatefulWidget {
  const EstimNotesPage({super.key});

  @override
  State<EstimNotesPage> createState() => _EstimNotesPageState();
}

class _EstimNotesPageState extends State<EstimNotesPage>
    with TickerProviderStateMixin {
  final NotesController controller = Get.put(NotesController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _matriculeController = TextEditingController();
  int selectedTabIndex = 0;
  ClasseModel? selectedClasse;

  final List<NotesTab> tabs = [
    NotesTab(title: 'Notes Étudiant', icon: Icons.person),
    NotesTab(title: 'Statistiques Classe', icon: Icons.bar_chart),
    NotesTab(title: 'Saisie Notes', icon: Icons.edit_note),
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
    
    controller.loadClasses();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _matriculeController.dispose();
    super.dispose();
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
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
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
              child: Icon(Icons.arrow_back, color: Color(0xFF374151), size: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des Notes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Notes, statistiques et évaluations',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assessment, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          NotesTab tab = entry.value;
          bool isSelected = selectedTabIndex == index;
          
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedTabIndex = index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      tab.icon,
                      color: isSelected ? Colors.white : Color(0xFF6B7280),
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      tab.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildNotesEtudiantTab();
      case 1:
        return _buildStatistiquesTab();
      case 2:
        return _buildSaisieNotesTab();
      default:
        return Container();
    }
  }

  Widget _buildNotesEtudiantTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSearchCard(),
          SizedBox(height: 24),
          Obx(() {
            if (controller.notesEtudiant.value != null) {
              return _buildNotesEtudiantCard();
            }
            return _buildNotesPlaceholder();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
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
                child: Icon(Icons.search, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Rechercher un étudiant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _matriculeController,
                  decoration: InputDecoration(
                    hintText: "Entrer le matricule",
                    prefixIcon: Icon(Icons.badge, color: Color(0xFF6B7280)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_matriculeController.text.isNotEmpty) {
                    controller.getNotesEtudiant(_matriculeController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Rechercher'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesEtudiantCard() {
    final notes = controller.notesEtudiant.value!;
    
    return Container(
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
          // Info étudiant
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notes.etudiant.nomPrenom,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Matricule: ${notes.etudiant.matricule} • ${notes.etudiant.classe}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Moy: ${notes.moyenneGenerale.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Notes devoirs
          if (notes.notesDevoirs.isNotEmpty) ...[
            Text(
              'Notes de Devoirs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12),
            ...notes.notesDevoirs.map((note) => _buildNoteItem(note, Color(0xFF3B82F6))),
            SizedBox(height: 20),
          ],
          
          // Notes examens
          if (notes.notesExamens.isNotEmpty) ...[
            Text(
              'Notes d\'Examens',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12),
            ...notes.notesExamens.map((note) => _buildNoteItem(note, Color(0xFF8B5CF6))),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteItem(NoteModel note, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.matiere,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Session: ${note.session} • Coef: ${note.coefficient}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${note.note}/20',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPlaceholder() {
    return Container(
      padding: EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B7280).withOpacity(0.1), Color(0xFF9CA3AF).withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_outlined, size: 40, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 16),
          Text(
            'Aucune note trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Entrez un matricule pour afficher les notes',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistiquesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildClasseSelector(),
          SizedBox(height: 24),
          Obx(() {
            if (controller.statistiques.value != null) {
              return _buildStatistiquesCard();
            }
            return _buildStatistiquesPlaceholder();
          }),
        ],
      ),
    );
  }

  Widget _buildClasseSelector() {
    return Container(
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
                child: Icon(Icons.class_, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Sélectionner une classe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<ClasseModel>(
            value: selectedClasse,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: Text('Choisir une classe'),
            items: controller.classes.map((classe) {
              return DropdownMenuItem<ClasseModel>(
                value: classe,
                child: Text('${classe.nom} - ${classe.niveau}'),
              );
            }).toList(),
            onChanged: (ClasseModel? newValue) {
              setState(() {
                selectedClasse = newValue;
              });
              if (newValue != null) {
                controller.getStatistiquesClasse(newValue.id);
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildStatistiquesCard() {
    final stats = controller.statistiques.value!;
    
    return Container(
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
          Text(
            'Statistiques de la Classe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 20),
          
          // Métriques principales
          Row(
            children: [
              Expanded(child: _buildStatCard('Étudiants', '${stats.nombreEtudiants}', Icons.people, Color(0xFF3B82F6))),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Moyenne', '${stats.moyenneClasse.toStringAsFixed(2)}', Icons.trending_up, Color(0xFF10B981))),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Taux Réussite', '${stats.tauxReussite.toStringAsFixed(1)}%', Icons.check_circle, Color(0xFF8B5CF6))),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Admis', '${stats.nombreAdmis}', Icons.school, Color(0xFFF59E0B))),
            ],
          ),
          SizedBox(height: 20),
          
          // Répartition des mentions
          Text(
            'Répartition des Mentions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12),
          ...stats.repartitionMentions.entries.map((entry) => 
            _buildMentionItem(entry.key, entry.value, stats.nombreEtudiants)
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentionItem(String mention, int nombre, int total) {
    double percentage = (nombre / total) * 100;
    Color color = _getMentionColor(mention);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              mention,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Text(
            '$nombre (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMentionColor(String mention) {
    switch (mention) {
      case 'Très Bien': return Color(0xFF10B981);
      case 'Bien': return Color(0xFF3B82F6);
      case 'Assez Bien': return Color(0xFF8B5CF6);
      case 'Passable': return Color(0xFFF59E0B);
      case 'Échec': return Color(0xFFEF4444);
      default: return Color(0xFF6B7280);
    }
  }

  Widget _buildStatistiquesPlaceholder() {
    return Container(
      padding: EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B7280).withOpacity(0.1), Color(0xFF9CA3AF).withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bar_chart_outlined, size: 40, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 16),
          Text(
            'Aucune statistique disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sélectionnez une classe pour voir les statistiques',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSaisieNotesTab() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6).withOpacity(0.1), Color(0xFF7C3AED).withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_note_outlined, size: 60, color: Color(0xFF8B5CF6)),
            ),
            SizedBox(height: 24),
            Text(
              'Saisie de Notes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fonctionnalité en cours de développement',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implémenter la saisie de notes
                Get.snackbar('Info', 'Fonctionnalité bientôt disponible');
              },
              icon: Icon(Icons.add),
              label: Text('Saisir des notes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class NotesTab {
  final String title;
  final IconData icon;
  
  NotesTab({required this.title, required this.icon});
}

class ClasseModel {
  final int id;
  final String nom;
  final int filiereId;
  final String niveau;

  ClasseModel({
    required this.id,
    required this.nom,
    required this.filiereId,
    required this.niveau,
  });

  factory ClasseModel.fromJson(Map<String, dynamic> json) {
    return ClasseModel(
      id: json['id'],
      nom: json['nom'],
      filiereId: json['filiere_id'],
      niveau: json['niveau'],
    );
  }
}

class NotesEtudiantModel {
  final EtudiantInfoModel etudiant;
  final List<NoteModel> notesDevoirs;
  final List<NoteModel> notesExamens;
  final double moyenneGenerale;
  final int nombreMatieres;

  NotesEtudiantModel({
    required this.etudiant,
    required this.notesDevoirs,
    required this.notesExamens,
    required this.moyenneGenerale,
    required this.nombreMatieres,
  });

  factory NotesEtudiantModel.fromJson(Map<String, dynamic> json) {
    return NotesEtudiantModel(
      etudiant: EtudiantInfoModel.fromJson(json['etudiant']),
      notesDevoirs: (json['notes_devoirs'] as List)
          .map((e) => NoteModel.fromJson(e))
          .toList(),
      notesExamens: (json['notes_examens'] as List)
          .map((e) => NoteModel.fromJson(e))
          .toList(),
      moyenneGenerale: json['moyenne_generale'].toDouble(),
      nombreMatieres: json['nombre_matieres'],
    );
  }
}

class EtudiantInfoModel {
  final int id;
  final String matricule;
  final String nomPrenom;
  final String classe;

  EtudiantInfoModel({
    required this.id,
    required this.matricule,
    required this.nomPrenom,
    required this.classe,
  });

  factory EtudiantInfoModel.fromJson(Map<String, dynamic> json) {
    return EtudiantInfoModel(
      id: json['id'],
      matricule: json['matricule'],
      nomPrenom: json['nom_prenom'],
      classe: json['classe'],
    );
  }
}

class NoteModel {
  final int id;
  final String matiere;
  final double note;
  final int coefficient;
  final String session;

  NoteModel({
    required this.id,
    required this.matiere,
    required this.note,
    required this.coefficient,
    required this.session,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      matiere: json['matiere'],
      note: json['note'].toDouble(),
      coefficient: json['coefficient'],
      session: json['session'],
    );
  }
}

class StatistiquesModel {
  final int classeId;
  final int nombreEtudiants;
  final double moyenneClasse;
  final double noteMax;
  final double noteMin;
  final int nombreAdmis;
  final double tauxReussite;
  final Map<String, int> repartitionMentions;

  StatistiquesModel({
    required this.classeId,
    required this.nombreEtudiants,
    required this.moyenneClasse,
    required this.noteMax,
    required this.noteMin,
    required this.nombreAdmis,
    required this.tauxReussite,
    required this.repartitionMentions,
  });

  factory StatistiquesModel.fromJson(Map<String, dynamic> json) {
    return StatistiquesModel(
      classeId: json['classe_id'],
      nombreEtudiants: json['nombre_etudiants'],
      moyenneClasse: json['moyenne_classe'].toDouble(),
      noteMax: json['note_max'].toDouble(),
      noteMin: json['note_min'].toDouble(),
      nombreAdmis: json['nombre_admis'],
      tauxReussite: json['taux_reussite'].toDouble(),
      repartitionMentions: Map<String, int>.from(json['repartition_mentions']),
    );
  }
}

class NoteInput {
  final int etudiantId;
  final double note;

  NoteInput({required this.etudiantId, required this.note});

  Map<String, dynamic> toJson() {
    return {
      'etudiant_id': etudiantId,
      'note': note,
    };
  }
}