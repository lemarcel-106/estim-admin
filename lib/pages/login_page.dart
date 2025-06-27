import 'package:estim_admin_photo/components/field.dart';
import 'package:estim_admin_photo/components/field_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Color.fromARGB(136, 0, 0, 0), BlendMode.color)),
            ),
            child: Column(
              children: [
                Expanded(
                    child: Container(
                  child: Column(
                    children: [
                      const Spacer(flex: 4),
                      Container(
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      Container(
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontFamily: 'font1',
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                          child: Column(
                            children: const [
                              Text(
                                "E.S.C",
                                style: TextStyle(fontSize: 28),
                              ),
                              Text(
                                "Estim Student Card",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                )),
                Expanded(
                    child: Container(
                  // height: do,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Field(
                              controller: username,
                              inptutType: TextInputType.text,
                              placeholder: "Nom de connexion",
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.person,
                              suffixIcon: Icons.info,
                              type: 'text',
                              description:
                                  "Veuillez renseigner votre nom de connexion.",
                            ),
                            Field(
                              controller: password,
                              inptutType: TextInputType.visiblePassword,
                              placeholder: "Mot de passe",
                              prefixIcon: Icons.key_outlined,
                              suffixIcon: Icons.remove_red_eye,
                              type: 'password',
                              description:
                                  "Veuillez renseigner votre mot de passe.",
                              hiddenText: true,
                            ),
                            buttonSubmit(username, password)
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                                fontFamily: 'font1',
                                color: Color.fromARGB(255, 238, 233, 233),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1),
                            child: Column(
                              children: const [
                                Text("Copyright ESTIM ECOLE"),
                                SizedBox(height: 5),
                                Text("Design by TTM"),
                              ],
                            ),
                          ))
                    ],
                  ),
                )),
              ],
            )),
      ),
    );
  }

  Container buttonSubmit(username, password) {
    return Container(
      margin: EdgeInsets.all(0).copyWith(top: 10),
      height: 50,
      width: 150,
      alignment: Alignment.topRight,
      child: ElevatedButton(
        style: const ButtonStyle(
            padding: MaterialStatePropertyAll(
              EdgeInsets.all(12),
            ),
            backgroundColor:
                MaterialStatePropertyAll(Color.fromARGB(255, 79, 170, 82))),
        onPressed: () {
          if (password.text.isEmpty || username.text.isEmpty) {
            Get.snackbar('Attention ! ', "Merci de remplir tous les champs ! ");
            return;
          }
          Get.toNamed('/home');
        },
        child: Container(
          width: double.infinity,
          child: const Text(
            'Se connecter',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'font1',
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
