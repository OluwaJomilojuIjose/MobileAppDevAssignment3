import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/db_helper.dart';

void main() {
  test('Add a food item to the database', () async {
    final dbHelper = DBHelper();
    await dbHelper.insertFoodItem('Pizza', 10.0);

    final foodItems = await dbHelper.fetchFoodItems();
    expect(foodItems.isNotEmpty, true);
    expect(foodItems.first['name'], 'Pizza');
    expect(foodItems.first['cost'], 10.0);
  });
}
