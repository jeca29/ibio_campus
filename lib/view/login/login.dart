import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/core/utils/responsive_size.dart';
import 'package:flutterlogin/home.dart';
import 'package:flutterlogin/models/user_data.dart';
import 'package:flutterlogin/router/app_routes.dart';
import 'package:flutterlogin/view/login/controller/login_controller.dart';
import 'package:flutterlogin/view/pages/species_page.dart';
import 'package:flutterlogin/widgets/Text_field.dart';
import 'package:flutterlogin/widgets/button.dart';
import 'package:flutterlogin/widgets/outlined_button.dart';
import 'package:flutterlogin/widgets/title_text.dart';
import 'package:flutterlogin/widgets/top_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    double width = Get.width;
    String title = "Login";
    String imgPath = "assets/images/ibio.png";
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopImage(
                imgPath: imgPath,
                size: Responsive.horizontalSize(360 * 0.67),
              ),
              SizedBox(
                height: Responsive.verticalSize(15),
              ),
              TitleText(title: title),
              SizedBox(
                height: Responsive.verticalSize(15),
              ),
              MyTextField(
                controller: controller.emailController,
                hintText: "email address",
                keyboardType: TextInputType.emailAddress,
                width: width * 0.8,
                icon: const Icon(FontAwesomeIcons.at, size: 17),
              ),
              SizedBox(
                height: Responsive.verticalSize(20),
              ),
              MyTextField(
                controller: controller.passwordController,
                hintText: "password",
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                width: width * 0.8,
                icon: const Icon(Icons.lock_outline_rounded, size: 19),
                suffixText: "Forgot?",
                onSuffixTap: () => Get.toNamed(AppRoutes.forgot),
              ),
              SizedBox(
                height: Responsive.verticalSize(30),
              ),
              GetBuilder<LoginController>(builder: (cont) {
                return MyButton(
                  showCircularBar: cont.isLoading.value,
                  onTap: () =>
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => SpeciesPage(uid: "asd"),
                      //   ),
                      // ),
                      cont.login(),
                  text: "Login",
                );
              }),
              SizedBox(
                height: Responsive.verticalSize(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.signup),
                    child: Text(
                      "Register",
                      style: GoogleFonts.poppins(color: mainColor),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: Responsive.verticalSize(15),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
