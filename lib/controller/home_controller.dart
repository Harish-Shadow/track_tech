import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'login_controller.dart';

class HomeController extends GetxController {
  final box = GetStorage();
  
  // Form Controllers
  final itemNumberController = TextEditingController();
  final colorController = TextEditingController();
  final dcNumberController = TextEditingController();
  final rollNumberController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final shadeController = TextEditingController();
  final internalLengthController = TextEditingController();
  final internalWidthController = TextEditingController();
  
  // Selected measurement unit
  RxString selectedUnit = 'INCH'.obs;
  
  // Add this RxList to store the data
  final _fabricData = <Map<String, dynamic>>[].obs;
  
  void submitForm() {
    if (validateForm()) {
      if (!isUnique()) {
        Get.snackbar(
          'Error',
          'Duplicate entry found. Please check Item Number, DC Number, and Roll Number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      String? currentUser = Get.find<LoginController>().getCurrentUser();
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'User not logged in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Map<String, dynamic> formData = {
        'itemNumber': itemNumberController.text,
        'color': colorController.text,
        'dcNumber': dcNumberController.text,
        'rollDetails': {
          'rollNumber': rollNumberController.text,
          'length': double.parse(lengthController.text),
          'width': double.parse(widthController.text),
          'widthUnit': selectedUnit.value,
          'shade': shadeController.text,
          'internalLength': double.parse(internalLengthController.text),
          'internalWidth': double.parse(internalWidthController.text),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update both local storage and reactive list
      List<Map<String, dynamic>> existingData = getAllData();
      existingData.add(formData);
      box.write('${currentUser}_fabricData', existingData);
      _fabricData.value = existingData;  // Update the reactive list

      Get.snackbar(
        'Success',
        'Details added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      clearForm();
    }
  }
  
  bool isUnique() {
    String? currentUser = Get.find<LoginController>().getCurrentUser();
    if (currentUser == null) return false;
    
    List<Map<String, dynamic>> existingData = 
        (box.read('${currentUser}_fabricData') ?? []).cast<Map<String, dynamic>>();
    
    String newItemNumber = itemNumberController.text;
    String newColor = colorController.text;
    String newDcNumber = dcNumberController.text;
    String newRollNumber = rollNumberController.text;

    for (var item in existingData) {
      // Check for duplicate DC number within same color and item number
      if (item['itemNumber'] == newItemNumber &&
          item['color'] == newColor &&
          item['dcNumber'] == newDcNumber) {
        return false;
      }
      
      // Check for duplicate roll number within same DC number
      if (item['dcNumber'] == newDcNumber &&
          item['rollDetails']['rollNumber'] == newRollNumber) {
        return false;
      }
    }
    return true;
  }
  
  bool validateForm() {
    if (itemNumberController.text.isEmpty ||
        colorController.text.isEmpty ||
        dcNumberController.text.isEmpty ||
        rollNumberController.text.isEmpty ||
        lengthController.text.isEmpty ||
        widthController.text.isEmpty ||
        shadeController.text.isEmpty ||
        internalLengthController.text.isEmpty ||
        internalWidthController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    // Validate numeric fields
    try {
      double.parse(lengthController.text);
      double.parse(widthController.text);
      double.parse(internalLengthController.text);
      double.parse(internalWidthController.text);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Please enter valid numbers for measurements',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    return true;
  }
  
  void clearForm() {
    itemNumberController.clear();
    colorController.clear();
    dcNumberController.clear();
    rollNumberController.clear();
    lengthController.clear();
    widthController.clear();
    shadeController.clear();
    internalLengthController.clear();
    internalWidthController.clear();
  }
  
  List<Map<String, dynamic>> getAllData() {
    String? currentUser = Get.find<LoginController>().getCurrentUser();
    if (currentUser == null) return [];
    
    try {
      final data = (box.read('${currentUser}_fabricData') ?? [])
          .cast<Map<String, dynamic>>();
      // Shuffle the data for random display
      data.shuffle();
      return data;
    } catch (e) {
      print('Error loading data: $e');
      return [];
    }
  }

  // Get data grouped by item number
  Map<String, List<Map<String, dynamic>>> getGroupedData() {
    List<Map<String, dynamic>> allData = getAllData();
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var item in allData) {
      String itemNumber = item['itemNumber'];
      if (!grouped.containsKey(itemNumber)) {
        grouped[itemNumber] = [];
      }
      grouped[itemNumber]!.add(item);
    }
    
    return grouped;
  }
  
  @override
  void onClose() {
    itemNumberController.dispose();
    colorController.dispose();
    dcNumberController.dispose();
    rollNumberController.dispose();
    lengthController.dispose();
    widthController.dispose();
    shadeController.dispose();
    internalLengthController.dispose();
    internalWidthController.dispose();
    super.onClose();
  }

  // Update your stream to use DetailModel
  Stream<List<Map<String, dynamic>>> get detailsStream {
    if (_fabricData.isEmpty) {
      refreshData(); // Load data if empty
    }
    return _fabricData.stream;
  }

  // Add a method to refresh the data
  void refreshData() {
    final data = getAllData();
    _fabricData.value = data;
  }

  @override
  void onInit() {
    super.onInit();
    refreshData(); // Load initial data
  }
}
