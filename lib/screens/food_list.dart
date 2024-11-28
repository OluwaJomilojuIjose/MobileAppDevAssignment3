import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'order_plans.dart';

class FoodListScreen extends StatefulWidget {
  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> foodItems = [];
  Set<int> selectedItemIds = {}; // Use a Set to store selected item IDs
  double targetCost = 0.0;
  String selectedDate = '';

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await dbHelper.fetchFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  void _saveOrderPlan() async {
    if (selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one item!')),
      );
      return;
    }

    if (selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date!')),
      );
      return;
    }

    // Get selected items from foodItems list
    final selectedItems = foodItems
        .where((item) => selectedItemIds.contains(item['id']))
        .toList();

    final selectedNames = selectedItems.map((item) => item['name']).join(', ');
    final totalCost =
    selectedItems.fold(0.0, (sum, item) => sum + item['cost']);

    await dbHelper.saveOrderPlan(selectedDate, selectedNames, totalCost);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order plan saved successfully!')),
    );

    setState(() {
      selectedItemIds.clear();
      targetCost = 0.0;
      selectedDate = '';
    });
  }

  void _addFoodItem() {
    final nameController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Food Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: costController,
              decoration: InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final cost = double.tryParse(costController.text.trim());
              if (name.isNotEmpty && cost != null) {
                await dbHelper.insertFoodItem(name, cost);
                _loadFoodItems();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid input!')),
                );
              }
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderPlansScreen()),
    );
  }

  double _calculateSelectedTotalCost() {
    return foodItems
        .where((item) => selectedItemIds.contains(item['id']))
        .fold(0.0, (sum, item) => sum + item['cost']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Ordering'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _navigateToOrderPlans,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFoodItem,
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Target Cost'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                targetCost = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            onChanged: (value) {
              setState(() {
                selectedDate = value;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                final itemId = item['id'] as int;
                final isSelected = selectedItemIds.contains(itemId);

                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('\$${item['cost'].toStringAsFixed(2)}'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          final newTotalCost =
                              _calculateSelectedTotalCost() + item['cost'];
                          if (newTotalCost <= targetCost) {
                            selectedItemIds.add(itemId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Target cost exceeded!')),
                            );
                          }
                        } else {
                          selectedItemIds.remove(itemId);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _saveOrderPlan,
            child: Text('Save Order Plan'),
          ),
        ],
      ),
    );
  }
}
