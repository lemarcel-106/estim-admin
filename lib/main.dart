import 'package:estim_admin_photo/pages/classe.dart';
import 'package:estim_admin_photo/pages/d_menu.dart';
import 'package:estim_admin_photo/pages/dashboard.dart';
import 'package:estim_admin_photo/pages/date_lieu.dart';
import 'package:estim_admin_photo/pages/details_page.dart';
import 'package:estim_admin_photo/pages/home.dart';
import 'package:estim_admin_photo/pages/notes.dart';
import 'package:estim_admin_photo/pages/photo.dart';
import 'package:estim_admin_photo/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      supportedLocales: const [
        Locale('fr', 'FR'), // <-- ajoute le support pour le français
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('fr', 'FR'), // <-- définis la locale par défaut
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        // GetPage(
        //   name: '/',
        //   page: () => const LoginPage(),
        // ),
        GetPage(name: '/', page: () => const EstimMainDashboard()),
        GetPage(name: '/classes', page: () => const EstimClassesPage()),
        GetPage(name: '/notes', page: () => const EstimNotesPage()),
        // GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/details', page: () => const EstimDetailsPage()),
        GetPage(name: '/photo', page: () => const EstimPhotoPage()),
        GetPage(name: '/date-lieu', page: () => const EstimDateLieuPage()),
      ],
    );
  }
}
