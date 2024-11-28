import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'food_ordering.db'),
      version: 3, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            cost REAL
          );
        ''');
        await db.execute('''
          CREATE TABLE order_plans(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            food_items TEXT,
            target_cost REAL
          );
        ''');
        await _populateDefaultFoodItems(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {

          await db.execute('DROP TABLE IF EXISTS food_items');
          await db.execute('DROP TABLE IF EXISTS order_plans');

          await db.execute('''
            CREATE TABLE food_items(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              cost REAL
            );
          ''');
          await db.execute('''
            CREATE TABLE order_plans(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              food_items TEXT,
              target_cost REAL
            );
          ''');
          // Repopulate initial data
          await _populateDefaultFoodItems(db);
        }
      },
    );
  }

  // Populate the database with initial food items
  Future<void> _populateDefaultFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Pizza', 'cost': 8.99},
      {'name': 'Burger', 'cost': 5.49},
      {'name': 'Pasta', 'cost': 7.99},
      {'name': 'Sushi', 'cost': 12.99},
      {'name': 'Taco', 'cost': 3.99},
      {'name': 'Sandwich', 'cost': 4.49},
      {'name': 'Steak', 'cost': 15.99},
      {'name': 'Salad', 'cost': 6.99},
      {'name': 'Soup', 'cost': 4.99},
      {'name': 'Ice Cream', 'cost': 2.99},
      {'name': 'Fried Rice', 'cost': 6.49},
      {'name': 'Noodles', 'cost': 5.99},
      {'name': 'Fish', 'cost': 9.49},
      {'name': 'Chicken Wings', 'cost': 7.49},
      {'name': 'Fries', 'cost': 2.99},
      {'name': 'Hot Dog', 'cost': 3.99},
      {'name': 'Ramen', 'cost': 8.49},
      {'name': 'Kebab', 'cost': 6.99},
      {'name': 'BBQ', 'cost': 14.99},
      {'name': 'Curry', 'cost': 9.99},
    ];
    for (var item in foodItems) {
      await db.insert('food_items', item);
    }
  }

  // Insert a new food item
  Future<void> insertFoodItem(String name, double cost) async {
    final db = await database;
    await db.insert('food_items', {'name': name, 'cost': cost});
  }

  // Fetch all food items
  Future<List<Map<String, dynamic>>> fetchFoodItems() async {
    final db = await database;
    return db.query('food_items');
  }

  // Save an order plan
  Future<void> saveOrderPlan(String date, String foodItems, double targetCost) async {
    final db = await database;
    await db.insert('order_plans', {
      'date': date,
      'food_items': foodItems,
      'target_cost': targetCost,
    });
  }

  // Fetch order plans by date
  Future<List<Map<String, dynamic>>> fetchOrderPlan(String date) async {
    final db = await database;
    return db.query('order_plans', where: 'date = ?', whereArgs: [date]);
  }

  // **This is the method you need**
  // Fetch all order plans
  Future<List<Map<String, dynamic>>> fetchAllOrderPlans() async {
    final db = await database;
    return db.query('order_plans');
  }

  // Update an order plan
  Future<void> updateOrderPlan(int id, String date, String foodItems, double targetCost) async {
    final db = await database;
    await db.update(
      'order_plans',
      {
        'date': date,
        'food_items': foodItems,
        'target_cost': targetCost,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete an order plan
  Future<void> deleteOrderPlan(int id) async {
    final db = await database;
    await db.delete('order_plans', where: 'id = ?', whereArgs: [id]);
  }
}
