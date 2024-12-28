import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../controller/home_controller.dart';

class LoginController extends GetxController {
  var box = GetStorage();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    String? savedUsername = box.read('currentUser');
    if (savedUsername != null) {
      usernameController.text = savedUsername;
      String? savedPassword = box.read('${savedUsername}_password');
      if (savedPassword != null) {
        passwordController.text = savedPassword;
        // Initialize HomeController before navigation
        Get.put(HomeController());
        Get.off(() => HomeScreen());
      }
    }
  }

  void login() async {
    String name = usernameController.text;
    String password = passwordController.text;
    if (name.isNotEmpty && password.isNotEmpty) {
      // Store current user
      box.write('currentUser', name);
      box.write('${name}_password', password);
      
      // Initialize user's data array if it doesn't exist
      if (box.read('${name}_fabricData') == null) {
        box.write('${name}_fabricData', []);
      }
      
      // Initialize HomeController before navigation
      Get.put(HomeController());
      
      Get.snackbar(
        "Success", 
        "Login Successful",
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
      Get.off(() => HomeScreen());
    } else {
      Get.snackbar(
        "Error", 
        "Enter the Username & Password",
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void logout() {
    // Clear current user
    box.remove('currentUser');
    usernameController.clear();
    passwordController.clear();
    // Delete HomeController instance when logging out
    Get.delete<HomeController>();
    // Navigate back to login screen and remove all previous routes
    Get.offAll(() => LoginScreen());
    update();
  }

  String? getCurrentUser() {
    return box.read('currentUser');
  }

  @override
  void onClose() {
    // Clean up controllers
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}