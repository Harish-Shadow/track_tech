import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import 'detaillist_screen.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Tech',
          style: TextStyle(
            fontSize: Get.width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.blue[800]),
            tooltip: 'View Details List',
            onPressed: () => Get.to(() => DetailListScreen()),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.blue[800]),
            tooltip: 'Logout',
            onPressed: () => Get.find<LoginController>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Get.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Item Details'),
              _buildItemDetailsCard(),
              SizedBox(height: Get.height * 0.02),
              _buildSectionTitle('Measurements'),
              _buildMeasurementsCard(),
              SizedBox(height: Get.height * 0.02),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Get.width * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildItemDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: controller.itemNumberController,
              label: 'Item Number',
              icon: Icons.inventory,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: controller.colorController,
              label: 'Color',
              icon: Icons.color_lens,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: controller.dcNumberController,
              label: 'DC Number',
              icon: Icons.numbers,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: controller.rollNumberController,
              label: 'Roll Number',
              icon: Icons.rotate_right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.lengthController,
                    label: 'Length',
                    icon: Icons.straighten,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: controller.widthController,
                    label: 'Width',
                    icon: Icons.width_normal,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildUnitSelector(),
            SizedBox(height: 12),
            _buildTextField(
              controller: controller.shadeController,
              label: 'Shade',
              icon: Icons.palette,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.internalLengthController,
                    label: 'Internal Length',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: controller.internalWidthController,
                    label: 'Internal Width',
                    icon: Icons.width_normal,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedUnit.value,
          items: ['INCH', 'CM'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            controller.selectedUnit.value = value!;
          },
        ),
      )),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          padding: EdgeInsets.symmetric(vertical: Get.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(color:Colors.white,
            fontSize: Get.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}