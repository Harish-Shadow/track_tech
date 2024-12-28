import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(Get.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Icon
              Icon(
                Icons.account_circle,
                size: Get.width * 0.2,
                color: Colors.blue[700],
              ),
              SizedBox(height: Get.height * 0.04),
              // Username field
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.02),
              // Password field
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.04),
              // Login button
              ElevatedButton(
                onPressed: controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: Get.height * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(color:Colors.white,
                    fontSize: Get.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}