import 'package:estim_admin_photo/components/field.dart';
import 'package:estim_admin_photo/services/data_rest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController matricule = TextEditingController();

  // Injection du controller GetX
  final EtudiantController ctrl = Get.put(EtudiantController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On superpose le contenu et le loader
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
              child: Column(
                children: [
                  Expanded(
                    flex: 10,
                    child: Center(
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              "Bienvenue sur ESTIM ADMIN | PHOTO \n\nUtilisez l'application pour l'insertion de photo sur les cartes étudiants",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'font1',
                                fontSize: 18,
                                height: 1.4,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.all(20),
                            color: const Color.fromARGB(255, 84, 97, 85),
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.grey,
                                  alignment: Alignment.center,
                                  height: 40,
                                  child: const Text(
                                    "Matricule de l'étudiant",
                                    style: TextStyle(
                                      fontFamily: 'font1',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Field(
                                      inptutType: TextInputType.number,
                                      suffixIcon: Icons.school,
                                      prefixIcon: Icons.keyboard,
                                      placeholder: "Ex : 1234",
                                      description:
                                          "Renseigner le matricule de l'étudiant",
                                      controller: matricule,
                                    ),
                                  ),
                                ),
                                buttonSubmit(),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontFamily: 'font1',
                        color: Color.fromARGB(255, 238, 233, 233),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                      child: Column(
                        children: const [
                          Text("Copyright ESTIM ECOLE"),
                          SizedBox(height: 5),
                          Text("Design by TTM"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loader fullscreen si isLoading=true
          Obx(() {
            if (ctrl.isLoading.value) {
              return Container(
                color: Colors.black38,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget buttonSubmit() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 50,
      width: 150,
      child: ElevatedButton(
        style: const ButtonStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.all(12)),
          backgroundColor: MaterialStatePropertyAll(
            Color.fromARGB(255, 79, 170, 82),
          ),
        ),
        onPressed: () async {
          FocusScope.of(context).unfocus();

          if (matricule.text.isEmpty) {
            Get.snackbar(
              'Attention !',
              "Renseigner le matricule de l'étudiant",
            );
            return;
          }

          final id = int.tryParse(matricule.text);
          if (id == null) {
            Get.snackbar('Erreur', 'Le matricule doit être un nombre');
            return;
          }

          EasyLoading.show(status: 'loading...');

          await ctrl.getEtudiant(id);

          EasyLoading.dismiss();

          if (ctrl.etudiant.value != null) {
            Get.toNamed('/details', arguments: ctrl.etudiant.value);
          } else if (ctrl.errorMessage.value.isNotEmpty) {
            Get.snackbar('Erreur', ctrl.errorMessage.value);
          }
        },
        child: Obx(() {
          // Affiche un mini-loader dans le bouton si uploading
          print("isUploading : ${ctrl.isUploading.value}");
          return CtrlButtonChild();
        }),
      ),
    );
  }
}

/// Sépare le contenu du bouton pour gérer isUploading
class CtrlButtonChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EtudiantController>();
    return ctrl.isUploading.value
        ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
        : const Text(
          'Vérifier',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'font1',
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        );
  }
}
