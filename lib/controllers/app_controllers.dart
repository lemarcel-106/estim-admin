// lib/controllers/app_controllers.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_services.dart';
import '../services/data_rest.dart';
import '../utils/app_utils.dart';

/// Controller principal pour la gestion des examens et notes
class ExamenController extends GetxController {
  // Observables pour les données
  final RxList<SessionExamen> sessions = <SessionExamen>[].obs;
  final RxList<Devoir> devoirs = <Devoir>[].obs;
  final RxList<Examen> examens = <Examen>[].obs;
  final RxList<NoteDevoir> notesDevoirs = <NoteDevoir>[].obs;
  final RxList<NoteExamen> notesExamens = <NoteExamen>[].obs;
  final Rx<StatistiquesExamen?> statistiques = Rx<StatistiquesExamen?>(null);
  
  // États de chargement
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  
  // Filtres et sélections
  final Rx<SessionExamen?> sessionSelectionnee = Rx<SessionExamen?>(null);
  final RxInt matiereSelectionnee = 0.obs;
  final RxString etudiantRecherche = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Charge les données initiales
  Future<void> loadInitialData() async {
    await loadSessions();
    await loadDevoirs();
    await loadExamens();
  }

  /// Charge toutes les sessions
  Future<void> loadSessions() async {
    try {
      isLoading.value = true;
      sessions.value = await ExamenService.getSessions();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les sessions');
    } finally {
      isLoading.value = false;
    }
  }

  /// Crée une nouvelle session
  Future<void> createSession({
    required String titre,
    required String anneeScolaire,
  }) async {
    try {
      isSaving.value = true;
      final session = SessionExamen(
        id: 0,
        titre: titre,
        anneeScolaire: anneeScolaire,
        dateDebut: DateTime.now().toString().split(' ')[0],
        codeSession: '',
      );
      
      final nouvelleSession = await ExamenService.createSession(session);
      sessions.add(nouvelleSession);
      Get.back(); // Fermer le dialog
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la session');
    } finally {
      isSaving.value = false;
    }
  }

  /// Charge tous les devoirs
  Future<void> loadDevoirs() async {
    try {
      devoirs.value = await ExamenService.getDevoirs();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les devoirs');
    }
  }

  /// Crée un nouveau devoir
  Future<void> createDevoir({
    required int matiereId,
    required int sessionId,
  }) async {
    try {
      isSaving.value = true;
      final devoir = Devoir(
        id: 0,
        matiereId: matiereId,
        matiere: '',
        sessionId: sessionId,
        session: '',
      );
      
      final nouveauDevoir = await ExamenService.createDevoir(devoir);
      devoirs.add(nouveauDevoir);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer le devoir');
    } finally {
      isSaving.value = false;
    }
  }

  /// Charge tous les examens
  Future<void> loadExamens() async {
    try {
      examens.value = await ExamenService.getExamens();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les examens');
    }
  }

  /// Crée un nouvel examen
  Future<void> createExamen({
    required int matiereId,
    required int sessionId,
  }) async {
    try {
      isSaving.value = true;
      final examen = Examen(
        id: 0,
        matiereId: matiereId,
        matiere: '',
        sessionId: sessionId,
        session: '',
      );
      
      final nouvelExamen = await ExamenService.createExamen(examen);
      examens.add(nouvelExamen);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer l\'examen');
    } finally {
      isSaving.value = false;
    }
  }

  /// Charge les notes de devoirs
  Future<void> loadNotesDevoirs({String? matricule}) async {
    try {
      isLoading.value = true;
      if (matricule != null) {
        notesDevoirs.value = await ExamenService.getNotesEtudiantDevoirs(matricule);
      } else {
        notesDevoirs.value = await ExamenService.getNotesDevoirs();
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les notes de devoirs');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les notes d'examens
  Future<void> loadNotesExamens({String? matricule}) async {
    try {
      isLoading.value = true;
      if (matricule != null) {
        notesExamens.value = await ExamenService.getNotesEtudiantExamens(matricule);
      } else {
        notesExamens.value = await ExamenService.getNotesExamens();
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les notes d\'examens');
    } finally {
      isLoading.value = false;
    }
  }

  /// Saisie en masse des notes de devoirs
  Future<void> saisirNotesDevoirs({
    required int evaluationId,
    required List<NoteBulk> notes,
  }) async {
    try {
      await ExamenService.createNotesDevoirs(
        evaluationId: evaluationId,
        notes: notes,
      );
      // Recharger les notes après la saisie
      await loadNotesDevoirs();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la saisie des notes');
    }
  }

  /// Saisie en masse des notes d'examens
  Future<void> saisirNotesExamens({
    required int evaluationId,
    required List<NoteBulk> notes,
  }) async {
    try {
      await ExamenService.createNotesExamens(
        evaluationId: evaluationId,
        notes: notes,
      );
      // Recharger les notes après la saisie
      await loadNotesExamens();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la saisie des notes');
    }
  }

  /// Charge les statistiques d'un examen
  Future<void> loadStatistiquesExamen(int examenId) async {
    try {
      isLoading.value = true;
      statistiques.value = await ExamenService.getStatistiquesExamen(examenId);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les statistiques');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les statistiques d'un devoir
  Future<void> loadStatistiquesDevoir(int devoirId) async {
    try {
      isLoading.value = true;
      statistiques.value = await ExamenService.getStatistiquesDevoir(devoirId);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les statistiques');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtrer les devoirs par session
  List<Devoir> get devoirsFiltres {
    if (sessionSelectionnee.value == null) return devoirs;
    return devoirs.where((d) => d.sessionId == sessionSelectionnee.value!.id).toList();
  }

  /// Filtrer les examens par session
  List<Examen> get examensFiltres {
    if (sessionSelectionnee.value == null) return examens;
    return examens.where((e) => e.sessionId == sessionSelectionnee.value!.id).toList();
  }
}

/// Controller pour la gestion des finances
class FinanceController extends GetxController {
  // Observables pour les données
  final RxList<FraisScolarite> fraisEtudiants = <FraisScolarite>[].obs;
  final RxList<String> moisDisponibles = <String>[].obs;
  final Rx<RapportFinancierMensuel?> rapportMensuel = Rx<RapportFinancierMensuel?>(null);
  final RxMap<String, dynamic> etatFinancier = <String, dynamic>{}.obs;
  
  // États de chargement
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  
  // Filtres
  final RxString moisSelectionne = ''.obs;
  final RxString anneeSelectionnee = DateTime.now().year.toString().obs;
  final RxInt classeSelectionnee = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMoisDisponibles();
  }

  /// Charge les mois disponibles
  Future<void> loadMoisDisponibles() async {
    try {
      moisDisponibles.value = await FinanceService.getMoisDisponibles();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les mois disponibles');
    }
  }

  /// Charge les frais d'un étudiant
  Future<void> loadFraisEtudiant(String matricule) async {
    try {
      isLoading.value = true;
      fraisEtudiants.value = await FinanceService.getFraisEtudiant(matricule);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les frais de l\'étudiant');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les frais d'une classe
  Future<void> loadFraisClasse(int classeId, {String? mois}) async {
    try {
      isLoading.value = true;
      fraisEtudiants.value = await FinanceService.getFraisClasse(classeId, mois: mois);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les frais de la classe');
    } finally {
      isLoading.value = false;
    }
  }

  /// Valide un paiement
  Future<void> validerPaiement({
    required int etudiantId,
    required String mois,
    required double montant,
    required bool isComplet,
  }) async {
    try {
      isSaving.value = true;
      final nouveauPaiement = await FinanceService.validerPaiement(
        etudiantId: etudiantId,
        mois: mois,
        montant: montant,
        isComplet: isComplet,
      );
      
      // Mettre à jour la liste locale
      fraisEtudiants.add(nouveauPaiement);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de valider le paiement');
    } finally {
      isSaving.value = false;
    }
  }

  /// Modifie un paiement
  Future<void> modifierPaiement(int fraisId, double montant, bool isComplet) async {
    try {
      isSaving.value = true;
      final paiementModifie = await FinanceService.modifierPaiement(
        fraisId, montant, isComplet);
      
      // Mettre à jour la liste locale
      final index = fraisEtudiants.indexWhere((f) => f.id == fraisId);
      if (index != -1) {
        fraisEtudiants[index] = paiementModifie;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le paiement');
    } finally {
      isSaving.value = false;
    }
  }

  /// Supprime un paiement
  Future<void> supprimerPaiement(int fraisId) async {
    try {
      await FinanceService.supprimerPaiement(fraisId);
      
      // Supprimer de la liste locale
      fraisEtudiants.removeWhere((f) => f.id == fraisId);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le paiement');
    }
  }

  /// Charge le rapport mensuel
  Future<void> loadRapportMensuel(String mois, String annee) async {
    try {
      isLoading.value = true;
      rapportMensuel.value = await FinanceService.getRapportMensuel(mois, annee);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le rapport mensuel');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge l'état financier d'un étudiant
  Future<void> loadEtatFinancierEtudiant(String matricule) async {
    try {
      isLoading.value = true;
      etatFinancier.value = await FinanceService.getEtatFinancierEtudiant(matricule);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger l\'état financier');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calcule le montant total payé
  double get totalPaye {
    return fraisEtudiants.fold(0.0, (sum, frais) => sum + frais.montant);
  }

  /// Calcule le nombre de paiements complets
  int get nombrePaiementsComplets {
    return fraisEtudiants.where((f) => f.isComplet).length;
  }

  /// Calcule le nombre de paiements partiels
  int get nombrePaiementsPartiels {
    return fraisEtudiants.where((f) => !f.isComplet).length;
  }
}

/// Controller principal pour orchestrer toutes les fonctionnalités
class MainAppController extends GetxController {
  // Controllers des différents modules
  final ExamenController examenController = Get.put(ExamenController());
  final FinanceController financeController = Get.put(FinanceController());
  
  // État global de l'application
  final RxBool isInitialized = false.obs;
  final RxString currentModule = 'dashboard'.obs;
  final RxMap<String, dynamic> appMetrics = <String, dynamic>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }
  
  /// Initialisation de l'application avec chargement des données essentielles
  Future<void> initializeApp() async {
    try {
      isInitialized.value = false;
      
      // Charger les données de base
      await Future.wait([
        _loadBasicData(),
        _loadAppMetrics(),
      ]);
      
      isInitialized.value = true;
      Get.snackbar(
        'Succès',
        'Application initialisée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'initialisation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> _loadBasicData() async {
    // Charger les sessions d'examens
    await examenController.loadSessions();
    
    // Charger les mois disponibles pour les finances
    await financeController.loadMoisDisponibles();
  }
  
  Future<void> _loadAppMetrics() async {
    // Simuler le chargement des métriques globales
    appMetrics.value = {
      'total_etudiants': 1234,
      'total_classes': 42,
      'examens_ce_mois': 18,
      'taux_reussite_global': 87.5,
      'total_recettes': 15000000.0,
      'derniere_mise_a_jour': DateTime.now().toIso8601String(),
    };
  }
  
  /// Navigation vers un module spécifique avec pré-chargement des données
  Future<void> navigateToModule(String module, {Map<String, dynamic>? params}) async {
    currentModule.value = module;
    
    switch (module) {
      case 'examens':
        await examenController.loadInitialData();
        Get.toNamed('/examens');
        break;
      case 'finances':
        if (params?['etudiant_matricule'] != null) {
          await financeController.loadFraisEtudiant(params!['etudiant_matricule']);
        }
        Get.toNamed('/finances');
        break;
      case 'notes':
        Get.toNamed('/notes');
        break;
      case 'classes':
        Get.toNamed('/classes');
        break;
      default:
        Get.toNamed('/dashboard');
    }
  }
  
  /// Recherche rapide d'étudiant avec navigation automatique
  Future<void> quickStudentSearch(String matricule) async {
    try {
      final etudiantController = Get.find<EtudiantController>();
      final etudiant = await etudiantController.getEtudiant(int.parse(matricule));
      
      // Afficher un dialog avec les options
      Get.dialog(
        AlertDialog(
          title: Text('Étudiant trouvé: ${etudiant.nom}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Matricule: ${etudiant.matricule}'),
              Text('Classe: ${etudiant.classeLibelle ?? 'Non définie'}'),
              const SizedBox(height: 16),
              const Text('Que souhaitez-vous faire ?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                navigateToModule('finances', params: {'etudiant_matricule': matricule});
              },
              child: const Text('Voir Finances'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/notes');
              },
              child: const Text('Voir Notes'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/details');
              },
              child: const Text('Profil Complet'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Étudiant non trouvé',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  /// Génération de rapport global de l'établissement
  Future<Map<String, dynamic>> generateGlobalReport() async {
    try {
      // Récupérer les données de tous les modules
      final sessions = await ExamenService.getSessions();
      final moisDisponibles = await FinanceService.getMoisDisponibles();
      
      // Construire le rapport
      final rapport = {
        'date_generation': DateTime.now().toIso8601String(),
        'sessions_actives': sessions.length,
        'mois_geres': moisDisponibles.length,
        'metriques_globales': appMetrics.value,
        'modules_actifs': [
          'Gestion des Examens',
          'Gestion Financière',
          'Gestion des Étudiants',
          'Statistiques et Rapports',
        ],
      };
      
      return rapport;
    } catch (e) {
      throw Exception('Erreur lors de la génération du rapport: $e');
    }
  }
  
  /// Mise à jour en masse des données
  Future<void> bulkDataUpdate() async {
    try {
      // Recharger toutes les données
      await Future.wait([
        examenController.loadInitialData(),
        financeController.loadMoisDisponibles(),
        _loadAppMetrics(),
      ]);
      
      Get.snackbar(
        'Succès',
        'Toutes les données ont été mises à jour',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

/// Service de cache local
class CacheService extends GetxService {
  final RxMap<String, dynamic> _cache = <String, dynamic>{}.obs;
  
  /// Stocke une valeur dans le cache
  void store(String key, dynamic value) {
    _cache[key] = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  /// Récupère une valeur du cache
  T? get<T>(String key, {Duration? maxAge}) {
    final cached = _cache[key];
    if (cached == null) return null;
    
    if (maxAge != null) {
      final timestamp = cached['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > maxAge.inMilliseconds) {
        _cache.remove(key);
        return null;
      }
    }
    
    return cached['value'] as T?;
  }
  
  /// Supprime une valeur du cache
  void remove(String key) {
    _cache.remove(key);
  }
  
  /// Vide le cache
  void clear() {
    _cache.clear();
  }
  
  /// Vérifie si une clé existe dans le cache
  bool hasKey(String key) {
    return _cache.containsKey(key);
  }
  
  Future<CacheService> init() async {
    return this;
  }
}

/// Service de synchronisation des données
class SyncService extends GetxService {
  final RxBool isSyncing = false.obs;
  final RxString lastSyncTime = ''.obs;
  
  /// Synchronise toutes les données
  Future<void> syncAll() async {
    if (isSyncing.value) return;
    
    isSyncing.value = true;
    try {
      // Synchroniser les différents modules
      await Future.wait([
        _syncExamens(),
        _syncFinances(),
        _syncEtudiants(),
      ]);
      
      lastSyncTime.value = DateTime.now().toIso8601String();
      Get.snackbar(
        'Succès',
        'Synchronisation terminée',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la synchronisation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSyncing.value = false;
    }
  }
  
  Future<void> _syncExamens() async {
    // Logique de synchronisation des examens
    await ExamenService.getSessions();
    await ExamenService.getDevoirs();
    await ExamenService.getExamens();
  }
  
  Future<void> _syncFinances() async {
    // Logique de synchronisation des finances
    await FinanceService.getMoisDisponibles();
  }
  
  Future<void> _syncEtudiants() async {
    // Logique de synchronisation des étudiants
    // Implementation dépendante des besoins spécifiques
  }
  
  /// Synchronisation automatique périodique
  void startAutoSync({Duration interval = const Duration(minutes: 30)}) {
    Timer.periodic(interval, (timer) {
      if (!isSyncing.value) {
        syncAll();
      }
    });
  }
  
  Future<SyncService> init() async {
    return this;
  }
}

/// Controller étendu pour les matières
class MatiereController extends GetxController {
  final RxList<Map<String, dynamic>> matieres = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatieres();
    loadClasses();
  }

  /// Charge toutes les matières
  Future<void> loadMatieres() async {
    try {
      isLoading.value = true;
      matieres.value = await MatiereService.getMatieres();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les matières');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge toutes les classes
  Future<void> loadClasses() async {
    try {
      isLoading.value = true;
      classes.value = await MatiereService.getClasses();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les classes');
    } finally {
      isLoading.value = false;
    }
  }

  /// Crée une nouvelle matière
  Future<void> createMatiere(Map<String, dynamic> matiere) async {
    try {
      final nouvelleMatiere = await MatiereService.createMatiere(matiere);
      matieres.add(nouvelleMatiere);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la matière');
    }
  }
}

/// Controller pour les inscriptions
class InscriptionController extends GetxController {
  final RxList<Map<String, dynamic>> demandesInscription = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDemandesInscription();
  }

  /// Charge les demandes d'inscription
  Future<void> loadDemandesInscription() async {
    try {
      isLoading.value = true;
      demandesInscription.value = await InscriptionService.getDemandesInscription();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les demandes d\'inscription');
    } finally {
      isLoading.value = false;
    }
  }

  /// Crée une demande d'inscription
  Future<void> createDemandeInscription(Map<String, dynamic> demande) async {
    try {
      final nouvelleDemande = await InscriptionService.createDemandeInscription(demande);
      demandesInscription.add(nouvelleDemande);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la demande d\'inscription');
    }
  }

  /// Valide une inscription
  Future<void> validerInscription(Map<String, dynamic> validation) async {
    try {
      await InscriptionService.validerInscription(validation);
      // Recharger les demandes après validation
      await loadDemandesInscription();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de valider l\'inscription');
    }
  }
}