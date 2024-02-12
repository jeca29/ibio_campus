import 'package:flutterlogin/core/utils/responsive_size.dart';
import 'package:flutterlogin/view/reset_password/controller/change_password_controller.dart';
import 'package:flutterlogin/widgets/Text_field.dart';
import 'package:flutterlogin/widgets/button.dart';
import 'package:flutterlogin/widgets/title_text.dart';
import 'package:flutterlogin/widgets/top_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    double width = Get.width;
    String title = "Change\nPassword";
    String imgPath = "assets/images/reset.png";
    ChangePasswordController controller = Get.find();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
                Padding(
                  padding: EdgeInsets.only(top: Responsive.verticalSize(25.0)),
                  child: TopImage(
                    imgPath: imgPath,
                    size: Responsive.horizontalSize(360 * 0.7),
                  ),
                ),
                TitleText(title: title),
                SizedBox(
                  height: Responsive.verticalSize(15),
                ),
                MyTextField(
                  controller: controller.oldPasswordController,
                  hintText: "Old password",
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  width: width * 0.8,
                  icon: const Icon(Icons.lock, size: 17),
                ),
                SizedBox(
                  height: Responsive.verticalSize(15),
                ),
                MyTextField(
                  controller: controller.newPasswordController,
                  hintText: "New password",
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  width: width * 0.8,
                  icon: const Icon(Icons.lock, size: 17),
                ),
                SizedBox(
                  height: Responsive.verticalSize(30),
                ),
                GetBuilder<ChangePasswordController>(builder: (cont) {
                  return MyButton(
                    showCircularBar: cont.isLoading.value,
                    onTap: () => cont.change(),
                    text: "Submit",
                  );
                }),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
