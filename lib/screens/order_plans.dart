import 'package:flutter/material.dart';
import '../db_helper.dart';

class OrderPlansScreen extends StatefulWidget {
  @override
  _OrderPlansScreenState createState() => _OrderPlansScreenState();
}

class _OrderPlansScreenState extends State<OrderPlansScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> orderPlans = [];

  @override
  void initState() {
    super.initState();
    _loadOrderPlans();
  }

  Future<void> _loadOrderPlans() async {
    // Fetch order plans from the database
    final plans = await dbHelper.fetchAllOrderPlans();
    setState(() {
      orderPlans = plans;
    });
  }

  Future<void> _deleteOrderPlan(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Order Plan'),
        content: Text('Are you sure you want to delete this plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await dbHelper.deleteOrderPlan(id);
      _loadOrderPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order plan deleted successfully!')),
      );
    }
  }

  Future<void> _updateOrderPlan(int id) async {
    final newDateController = TextEditingController();
    final newTargetCostController = TextEditingController();

    final plan = orderPlans.firstWhere((plan) => plan['id'] == id);

    newDateController.text = plan['date'];
    newTargetCostController.text = plan['target_cost'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newDateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: newTargetCostController,
              decoration: InputDecoration(labelText: 'Target Cost'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newDate = newDateController.text.trim();
              final newTargetCost = double.tryParse(newTargetCostController.text.trim());

              if (newDate.isEmpty || newTargetCost == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid input!')),
                );
                return;
              }

              await dbHelper.updateOrderPlan(
                id,
                newDate,
                plan['food_items'],
                newTargetCost,
              );
              Navigator.pop(context);
              _loadOrderPlans();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order plan updated successfully!')),
              );
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Plans'),
      ),
      body: orderPlans.isEmpty
          ? Center(child: Text('No order plans found!'))
          : ListView.builder(
        itemCount: orderPlans.length,
        itemBuilder: (context, index) {
          final plan = orderPlans[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Date: ${plan['date']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items: ${plan['food_items']}'),
                  Text('Total Cost: \$${plan['target_cost'].toStringAsFixed(2)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _updateOrderPlan(plan['id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteOrderPlan(plan['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
