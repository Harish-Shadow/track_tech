import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import 'package:collection/collection.dart';
import '../models/detail_model.dart';

class DetailListScreen extends StatefulWidget {
  const DetailListScreen({super.key});

  @override
  State<DetailListScreen> createState() => _DetailListScreenState();
}

class _DetailListScreenState extends State<DetailListScreen> {
  final HomeController controller = Get.find<HomeController>();
  String? selectedGroupingType;
  double? widthRange;
  double? shrinkageLengthRange;
  double? shrinkageWidthRange;
  String? shadeValue;
  bool _isLoading = true;
  List<DetailModel> _allDetails = [];

  @override
  void initState() {
    super.initState();
    controller.refreshData();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final initialData = await controller.detailsStream.first;
      if (mounted) {
        setState(() {
          _allDetails = initialData.map((d) => DetailModel.fromMap(d)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Failed to load data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
    }
  }

  Stream<List<DetailModel>> get _detailsStream {
    return controller.detailsStream.map((details) {
      return details.map((detail) => DetailModel.fromMap(detail)).toList();
    });
  }

  Map<String, List<DetailModel>> groupByWidth(List<DetailModel> details, double range) {
    final sortedDetails = List<DetailModel>.from(details)
      ..sort((a, b) => a.width.compareTo(b.width));
    
    Map<String, List<DetailModel>> groups = {};
    double currentMin = sortedDetails.first.width;
    
    while (currentMin <= sortedDetails.last.width) {
      double currentMax = currentMin + range;
      String groupName = '${currentMin.toStringAsFixed(2)}-${currentMax.toStringAsFixed(2)}';
      
      groups[groupName] = sortedDetails
          .where((detail) => detail.width >= currentMin && detail.width < currentMax)
          .toList();
      
      currentMin = currentMax;
    }
    
    return groups;
  }

  Map<String, List<DetailModel>> groupByInternal(
    List<DetailModel> details, 
    double lengthRange, 
    double widthRange
  ) {
    Map<String, List<DetailModel>> groups = {};
    
    for (var detail in details) {
      String lengthGroup = (detail.shrinkageLength / lengthRange).floor().toString();
      String widthGroup = (detail.shrinkageWidth / widthRange).floor().toString();
      String groupName = 'L:$lengthGroup-W:$widthGroup';
      
      groups.putIfAbsent(groupName, () => []);
      groups[groupName]!.add(detail);
    }
    
    return groups;
  }

  Map<String, List<DetailModel>> groupByShade(List<DetailModel> details, String shade) {
    return groupBy(details, (DetailModel d) => d.shade);
  }

  Widget _buildGroupingControls() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Data By:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedGroupingType,
                  hint: const Text('Select Grouping Type'),
                  items: const [
                    DropdownMenuItem(value: 'width', child: Text('Width Grouping')),
                    DropdownMenuItem(value: 'internal', child: Text('Internal Grouping')),
                    DropdownMenuItem(value: 'shade', child: Text('Shade Grouping')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGroupingType = value;
                      // Reset values when changing grouping type
                      widthRange = null;
                      shrinkageLengthRange = null;
                      shrinkageWidthRange = null;
                      shadeValue = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedGroupingType != null) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildGroupingInputs(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupingInputs() {
    switch (selectedGroupingType) {
      case 'width':
        return _buildRangeInput(
          label: 'Width Range',
          onChanged: (value) {
            setState(() {
              widthRange = double.tryParse(value);
            });
          },
        );
      case 'internal':
        return Column(
          children: [
            _buildRangeInput(
              label: 'Shrinkage Length Range',
              onChanged: (value) {
                setState(() {
                  shrinkageLengthRange = double.tryParse(value);
                });
              },
            ),
            const SizedBox(height: 8),
            _buildRangeInput(
              label: 'Shrinkage Width Range',
              onChanged: (value) {
                setState(() {
                  shrinkageWidthRange = double.tryParse(value);
                });
              },
            ),
          ],
        );
      case 'shade':
        return _buildRangeInput(
          label: 'Shade Value',
          isNumeric: false,
          onChanged: (value) {
            setState(() {
              shadeValue = value;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRangeInput({
    required String label,
    required Function(String) onChanged,
    bool isNumeric = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail List',
          style: TextStyle(fontSize: Get.width * 0.05),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              controller.refreshData();
              _loadInitialData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGroupingControls(),
          if (selectedGroupingType != null) _buildGroupingStatus(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDetailsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allDetails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No details available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    Map<String, List<DetailModel>> groupedData = {};
    if (selectedGroupingType != null) {
      switch (selectedGroupingType) {
        case 'width':
          if (widthRange != null) {
            groupedData = groupByWidth(_allDetails, widthRange!);
          }
          break;
        case 'internal':
          if (shrinkageLengthRange != null && shrinkageWidthRange != null) {
            groupedData = groupByInternal(
              _allDetails,
              shrinkageLengthRange!,
              shrinkageWidthRange!,
            );
          }
          break;
        case 'shade':
          if (shadeValue != null) {
            groupedData = groupByShade(_allDetails, shadeValue!);
          }
          break;
      }
    }

    if (groupedData.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          controller.refreshData();
          await _loadInitialData();
        },
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: _allDetails.length,
          itemBuilder: (context, index) {
            return _buildDetailTile(_allDetails[index]);
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshData();
        await _loadInitialData();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: groupedData.length,
        itemBuilder: (context, index) {
          String groupName = groupedData.keys.elementAt(index);
          List<DetailModel> groupItems = groupedData[groupName]!;
          return _buildGroupDisplay(groupName, groupItems);
        },
      ),
    );
  }

  Widget _buildGroupDisplay(String groupName, List<DetailModel> items) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.folder, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group: $groupName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${items.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: items.map((detail) => _buildDetailTile(detail)).toList(),
      ),
    );
  }

  Widget _buildDetailTile(DetailModel detail) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Item Number and DC Number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Item: ${detail.itemNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'DC: ${detail.dcNumber}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Color and Roll Number
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Color',
                    detail.color,
                    Icons.color_lens,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Roll',
                    detail.rollDetails['rollNumber'].toString(),
                    Icons.rotate_right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Length and Width
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Length',
                    '${detail.rollDetails['length']} ${detail.rollDetails['widthUnit']}',
                    Icons.straighten,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Width',
                    '${detail.width} ${detail.rollDetails['widthUnit']}',
                    Icons.width_normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Shrinkage Measurements
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Shrinkage L',
                    detail.shrinkageLength.toString(),
                    Icons.height,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Shrinkage W',
                    detail.shrinkageWidth.toString(),
                    Icons.width_normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Shade and Date
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Shade',
                    detail.shade,
                    Icons.palette,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Date',
                    _formatDate(detail.timestamp),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update the info row to handle longer text
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to format date
  String _formatDate(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Add visual feedback for grouping status
  Widget _buildGroupingStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue[50],
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20, color: Colors.blue[700]),
          SizedBox(width: 8),
          Text(
            'Grouped by: ${selectedGroupingType!.capitalizeFirst}',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                selectedGroupingType = null;
                widthRange = null;
                shrinkageLengthRange = null;
                shrinkageWidthRange = null;
                shadeValue = null;
              });
            },
            child: Text('Clear', style: TextStyle(color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }
}
