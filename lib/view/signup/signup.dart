import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/core/utils/responsive_size.dart';
import 'package:flutterlogin/router/app_routes.dart';
import 'package:flutterlogin/view/signup/controller/signup_controller.dart';
import 'package:flutterlogin/widgets/Text_field.dart';
import 'package:flutterlogin/widgets/button.dart';
import 'package:flutterlogin/widgets/title_text.dart';
import 'package:flutterlogin/widgets/top_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    double width = Get.width;
    String title = "Register";
    String imgPath = "assets/images/logo.png";
    final SignUpController controller = Get.find();
    String? selectedRole; // Variable to hold the selected value
    final List<DropdownMenuItem<String>> roleItems = [
      // Define dropdown items
      DropdownMenuItem(value: "Student", child: Text("Student")),
      DropdownMenuItem(value: "Faculty", child: Text("Faculty")),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                leading: GestureDetector(
                  child: const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
                  onTap: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Colors.transparent, //You can make this transparent
                elevation: 0.0, //No shadow
              ),
            ),
            SingleChildScrollView(
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TopImage(
                    imgPath: imgPath,
                    size: Responsive.horizontalSize(360 * 0.55),
                  ),
                  SizedBox(
                    height: Responsive.verticalSize(15),
                  ),
                  TitleText(title: title),
                  SizedBox(
                    height: Responsive.verticalSize(15),
                  ),
                  SizedBox(
                    width: width * 0.8,
                    child: DropdownButtonFormField<String>(
                      value: selectedRole, // Bind the selected value
                      hint: Text("Select Role"), // Placeholder when nothing is selected
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue; // Update the selected value on change
                          controller.roleController.text = newValue ?? "student"; // Update the selected value on change
                        });
                      },
                      items: roleItems, // Use the list of dropdown items defined earlier
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.school), // Icon for the dropdown
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Responsive.verticalSize(15),
                  ),
                  MyTextField(
                    controller: controller.nameController,
                    hintText: "name",
                    keyboardType: TextInputType.name,
                    width: width * 0.8,
                    icon: const Icon(FontAwesomeIcons.user, size: 17),
                  ),
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
                    height: Responsive.verticalSize(15),
                  ),
                  MyTextField(
                    hintText: "password",
                    controller: controller.passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    width: width * 0.8,
                    icon: const Icon(Icons.lock_outline_rounded, size: 19),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: Responsive.verticalSize(15), bottom: Responsive.verticalSize(15), left: width * 0.1, right: width * 0.1),
                    child: Text.rich(
                      TextSpan(
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                          children: [
                            TextSpan(
                              text: "By signing up, you're agree to our ",
                              style: GoogleFonts.poppins(),
                            ),
                            TextSpan(
                              text: "Terms & Conditions ",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: mainColor),
                            ),
                            TextSpan(
                              text: "and ",
                              style: GoogleFonts.poppins(),
                            ),
                            TextSpan(
                              text: "Privacy Policy.",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: mainColor),
                            ),
                          ]),
                    ),
                  ),
                  GetBuilder<SignUpController>(builder: (cont) {
                    return MyButton(
                      showCircularBar: cont.isLoading.value,
                      onTap: () => cont.register(),
                      text: "Register",
                    );
                  }),
                  SizedBox(
                    height: Responsive.verticalSize(15),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          "Login",
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
          ],
        ),
      ),
    );
  }
}
