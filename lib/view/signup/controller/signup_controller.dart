import 'package:flutter/material.dart';
import 'package:flutterlogin/view/login/login.dart';
import 'package:get/get.dart';

import '../../../data/api/api.dart';

class SignUpController extends GetxController {
  final ApiClient api;

  SignUpController(this.api);

  TextEditingController nameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController roleController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> register() async {
    isLoading.value = true;
    update();
    try {
      final user = await api.registerUser(roleController.text, nameController.text, emailController.text, passwordController.text);
      if (user != null) {
        Get.snackbar('Success', 'User registered successfully!');
        Get.to(Login());
      } else {
        Get.snackbar('error', 'email or password or name are invalid');
      }
    } catch (error) {
      // Handle any errors that occurred while creating the user or updating their profile.
      Get.snackbar('error', 'email or password or name are invalid2');
    }
    isLoading.value = false;
    update();
  }
}
