// main.dart - Aroma Coffee Management App (ĐÃ FIX LỖI)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() {
  runApp(const AromaCoffeeApp());
}

// ==================== MODELS ====================

class Product {
  int? id;
  String name;
  String category;
  int price;
  String? imagePath;
  String description;
  bool isAvailable;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imagePath,
    this.description = '',
    this.isAvailable = true,
  });
}

class OrderItem {
  final Product product;
  int quantity;
  String? note;

  OrderItem({required this.product, this.quantity = 1, this.note});

  int get total => product.price * quantity;
}

class Order {
  int? id;
  String orderNumber;
  DateTime createdAt;
  List<OrderItem> items;
  int tableNumber;
  String customerName;
  String status;

  int get total => items.fold(0, (sum, item) => sum + item.total);

  Order({
    this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.items,
    this.tableNumber = 0,
    this.customerName = 'Khách vãng lai',
    this.status = 'pending',
  });
}

class Employee {
  int? id;
  String name;
  String position;
  String shift;
  String phone;
  bool isWorking;
  String? imagePath;

  Employee({
    this.id,
    required this.name,
    required this.position,
    required this.shift,
    required this.phone,
    this.isWorking = true,
    this.imagePath,
  });
}

class InventoryItem {
  int? id;
  String name;
  String category;
  double quantity;
  double minStock;
  String unit;
  String status;

  InventoryItem({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minStock,
    this.unit = 'kg',
    this.status = 'Bình thường',
  });

  void updateStatus() {
    if (quantity <= 0) {
      status = 'Hết hàng';
    } else if (quantity <= minStock) {
      status = 'Sắp hết';
    } else {
      status = 'Bình thường';
    }
  }
}

class Customer {
  String name;
  String phone;
  String email;
  int points;
  int totalOrders;

  Customer({
    required this.name,
    required this.phone,
    required this.email,
    this.points = 0,
    this.totalOrders = 0,
  });
}

// ==================== APP DATA PROVIDER ====================

class AppData extends ChangeNotifier {
  List<Product> _products = [];
  List<Order> _orders = [];
  List<Employee> _employees = [];
  List<InventoryItem> _inventoryItems = [];
  List<Customer> _customers = [];

  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Employee> get employees => _employees;
  List<InventoryItem> get inventoryItems => _inventoryItems;
  List<Customer> get customers => _customers;

  double get todayRevenue {
    final today = DateTime.now();
    return _orders
        .where(
          (order) =>
              order.status == 'completed' &&
              order.createdAt.year == today.year &&
              order.createdAt.month == today.month &&
              order.createdAt.day == today.day,
        )
        .fold(0, (sum, order) => sum + order.total);
  }

  int get todayOrders {
    final today = DateTime.now();
    return _orders
        .where(
          (order) =>
              order.createdAt.year == today.year &&
              order.createdAt.month == today.month &&
              order.createdAt.day == today.day,
        )
        .length;
  }

  AppData() {
    _initSampleData();
  }

  void _initSampleData() {
    _products = [
      Product(
        name: 'Espresso',
        category: 'Cà phê',
        price: 35000,
        description: 'Cà phê espresso đậm đà',
      ),
      Product(
        name: 'Cappuccino',
        category: 'Cà phê',
        price: 45000,
        description: 'Cappuccino với lớp bọt sữa mịn',
      ),
      Product(
        name: 'Latte',
        category: 'Cà phê',
        price: 49000,
        description: 'Latte thơm ngon',
      ),
      Product(
        name: 'Trà đào',
        category: 'Trà',
        price: 39000,
        description: 'Trà đào mát lạnh',
      ),
      Product(
        name: 'Trà xanh',
        category: 'Trà',
        price: 35000,
        description: 'Trà xanh matcha',
      ),
      Product(
        name: 'Bánh ngọt',
        category: 'Đồ ăn',
        price: 29000,
        description: 'Bánh ngọt các loại',
      ),
      Product(
        name: 'Sữa chua',
        category: 'Đồ ăn',
        price: 25000,
        description: 'Sữa chua trái cây',
      ),
      Product(
        name: 'Nước cam',
        category: 'Nước ép',
        price: 32000,
        description: 'Cam ép tươi',
      ),
    ];

    _employees = [
      Employee(
        name: 'Lê Thu Hà',
        position: 'Quản lý',
        shift: 'Sáng',
        phone: '0901234567',
        isWorking: true,
      ),
      Employee(
        name: 'Nguyễn Minh Quân',
        position: 'Barista',
        shift: 'Tối',
        phone: '0912345678',
        isWorking: true,
      ),
      Employee(
        name: 'Trần Văn Mạnh',
        position: 'Phục vụ',
        shift: 'Sáng',
        phone: '0987654321',
        isWorking: true,
      ),
      Employee(
        name: 'Hoàng Thị Lan',
        position: 'Thu ngân',
        shift: 'N/A',
        phone: '0933445566',
        isWorking: false,
      ),
    ];

    _inventoryItems = [
      InventoryItem(
        name: 'Hạt cà phê Robusta',
        category: 'Nguyên liệu',
        quantity: 45,
        minStock: 10,
        unit: 'kg',
      ),
      InventoryItem(
        name: 'Sữa tươi nguyên chất',
        category: 'Nguyên liệu',
        quantity: 5,
        minStock: 10,
        unit: 'lít',
      ),
      InventoryItem(
        name: 'Đường cát trắng',
        category: 'Phụ gia',
        quantity: 20,
        minStock: 5,
        unit: 'kg',
      ),
      InventoryItem(
        name: 'Ly giấy 12oz',
        category: 'Bao bì',
        quantity: 50,
        minStock: 100,
        unit: 'cái',
      ),
      InventoryItem(
        name: 'Cốc nhựa',
        category: 'Bao bì',
        quantity: 200,
        minStock: 50,
        unit: 'cái',
      ),
      InventoryItem(
        name: 'Siêu rô sầu riêng',
        category: 'Nguyên liệu',
        quantity: 3,
        minStock: 5,
        unit: 'lít',
      ),
    ];

    for (var item in _inventoryItems) {
      item.updateStatus();
    }

    _customers = [
      Customer(
        name: 'Nguyễn Văn A',
        phone: '0901234567',
        email: 'nguyenvana@email.com',
        points: 120,
        totalOrders: 8,
      ),
      Customer(
        name: 'Trần Thị B',
        phone: '0912345678',
        email: 'tranthib@email.com',
        points: 85,
        totalOrders: 5,
      ),
      Customer(
        name: 'Lê Văn C',
        phone: '0987654321',
        email: 'levanc@email.com',
        points: 250,
        totalOrders: 15,
      ),
      Customer(
        name: 'Phạm Thị D',
        phone: '0976543210',
        email: 'phamthid@email.com',
        points: 45,
        totalOrders: 3,
      ),
    ];

    _orders = [
      Order(
        orderNumber: 'ORD001',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        items: [OrderItem(product: _products[0], quantity: 2)],
        customerName: 'Nguyễn Văn A',
        status: 'completed',
      ),
      Order(
        orderNumber: 'ORD002',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        items: [
          OrderItem(product: _products[1], quantity: 1),
          OrderItem(product: _products[3], quantity: 1),
        ],
        customerName: 'Trần Thị B',
        status: 'completed',
      ),
    ];

    // Gán ID
    for (int i = 0; i < _products.length; i++) _products[i].id = i + 1;
    for (int i = 0; i < _employees.length; i++) _employees[i].id = i + 1;
    for (int i = 0; i < _inventoryItems.length; i++)
      _inventoryItems[i].id = i + 1;
    for (int i = 0; i < _orders.length; i++) _orders[i].id = i + 1;
  }

  void addProduct(Product product) {
    product.id = _products.length + 1;
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(int id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addOrder(Order order) {
    order.id = _orders.length + 1;
    _orders.add(order);
    notifyListeners();
  }

  void addEmployee(Employee employee) {
    employee.id = _employees.length + 1;
    _employees.add(employee);
    notifyListeners();
  }

  void toggleEmployeeStatus(int id) {
    final index = _employees.indexWhere((e) => e.id == id);
    if (index != -1) {
      _employees[index].isWorking = !_employees[index].isWorking;
      notifyListeners();
    }
  }

  void updateInventory(InventoryItem item) {
    final index = _inventoryItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _inventoryItems[index] = item;
      _inventoryItems[index].updateStatus();
      notifyListeners();
    }
  }

  int getLowStockCount() {
    return _inventoryItems.where((item) => item.status == 'Sắp hết').length;
  }

  double getInventoryValue() {
    return _inventoryItems.fold(
      0,
      (sum, item) => sum + (item.quantity * 50000),
    );
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }
}

// ==================== PROVIDER CLASSES ====================

class ChangeNotifierProvider extends StatefulWidget {
  final Widget child;
  final AppData Function(BuildContext) create;

  const ChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
  });

  @override
  State<ChangeNotifierProvider> createState() => _ChangeNotifierProviderState();
}

class _ChangeNotifierProviderState extends State<ChangeNotifierProvider> {
  late AppData _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider(notifier: _notifier, child: widget.child);
  }
}

class _InheritedProvider extends InheritedWidget {
  final AppData notifier;

  const _InheritedProvider({required this.notifier, required super.child});

  static _InheritedProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedProvider>();
  }

  @override
  bool updateShouldNotify(_InheritedProvider old) => notifier != old.notifier;
}

class Consumer<T extends AppData> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({super.key, required this.builder, this.child});

  static T of<T extends AppData>(BuildContext context) {
    final provider = _InheritedProvider.of(context);
    if (provider?.notifier is T) {
      return provider!.notifier as T;
    }
    throw Exception('No provider found for type $T');
  }

  @override
  Widget build(BuildContext context) {
    final provider = _InheritedProvider.of(context);
    if (provider?.notifier is T) {
      return AnimatedBuilder(
        animation: provider!.notifier,
        builder: (context, _) =>
            builder(context, provider.notifier as T, child),
      );
    }
    throw Exception('No provider found for type $T');
  }
}

// ==================== MAIN APP ====================

class AromaCoffeeApp extends StatelessWidget {
  const AromaCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppData(),
      child: MaterialApp(
        title: 'Aroma Coffee',
        theme: ThemeData(
          primaryColor: const Color(0xFF6F4E37),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F4E37)),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6F4E37),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const MainLayout(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const FloorPlanScreen(),
      const PosScreen(),
      const MenuManagementScreen(),
      const OrderScreen(),
      const ReportScreen(),
      const InventoryScreen(),
      const EmployeeScreen(),
      const CustomerScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Tổng quan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.table_restaurant),
                label: Text('Sơ đồ bàn'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.point_of_sale),
                label: Text('Đặt món'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book),
                label: Text('Thực đơn'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt),
                label: Text('Đơn hàng'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Báo cáo'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Kho hàng'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Nhân viên'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt),
                label: Text('Khách hàng'),
              ),
            ],
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD SCREEN ====================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aroma Coffee'), elevation: 0),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final lowStockCount = appData.getLowStockCount();
          final inventoryValue = appData.getInventoryValue();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                if (lowStockCount > 0)
                  _buildLowStockWarning(lowStockCount, inventoryValue),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Doanh thu hôm nay',
                        _formatMoney(appData.todayRevenue),
                        '+12%',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Đơn hàng',
                        '${appData.todayOrders}',
                        '+5%',
                        Icons.receipt,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Khách hàng mới',
                        '12',
                        '',
                        Icons.people,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Cà phê đã bán',
                        '156 ly',
                        '+18%',
                        Icons.coffee,
                        Colors.brown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildRecentOrders(appData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade700, Colors.brown.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào buổi sáng!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hôm nay quán của bạn đang hoạt động rất tốt.',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockWarning(int count, double value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'CẢNH BÁO TỒN KHO THẤP\n$count mặt hàng cần nhập thêm',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'GIÁ TRỊ TỒN KHO\n${_formatMoney(value)} đ',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              if (change.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(AppData appData) {
    final recentOrders = appData.orders.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đơn hàng gần đây',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final order = recentOrders[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: order.status == 'completed'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  child: Icon(
                    Icons.receipt,
                    color: order.status == 'completed'
                        ? Colors.green
                        : Colors.orange,
                    size: 20,
                  ),
                ),
                title: Text('#${order.orderNumber} - ${order.customerName}'),
                subtitle: Text('${order.items.length} món'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatMoney(order.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatMoney(num amount) {
    return NumberFormat('#,###').format(amount);
  }
}

// ==================== FLOOR PLAN SCREEN ====================

class FloorPlanScreen extends StatelessWidget {
  const FloorPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sơ đồ bàn'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Theo dõi tình trạng chỗ ngồi và phục vụ khách.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 12,
                itemBuilder: (context, index) =>
                    _buildTableCard(context, index + 1, index % 3 == 1),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Icons.people, 'Đang phục vụ', Colors.green),
                const SizedBox(width: 24),
                _buildLegend(Icons.table_restaurant, 'Bàn trống', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    int tableNumber,
    bool isOccupied,
  ) => GestureDetector(
    onTap: () => _showTableDialog(context, tableNumber, isOccupied),
    child: Container(
      decoration: BoxDecoration(
        color: isOccupied ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOccupied ? Colors.green.shade400 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOccupied ? Icons.people : Icons.table_restaurant,
            size: 40,
            color: isOccupied ? Colors.green.shade600 : Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          Text(
            'Bàn $tableNumber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isOccupied ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
          if (isOccupied)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Có khách',
                style: TextStyle(color: Colors.green.shade800, fontSize: 12),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildLegend(IconData icon, String label, Color color) => Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color)),
    ],
  );

  void _showTableDialog(
    BuildContext context,
    int tableNumber,
    bool isOccupied,
  ) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Bàn $tableNumber'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOccupied ? Icons.people : Icons.table_restaurant,
            size: 50,
            color: isOccupied ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(isOccupied ? 'Đang có khách' : 'Bàn trống'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        if (!isOccupied)
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Tạo đơn hàng'),
          ),
      ],
    ),
  );
}

// ==================== POS SCREEN ====================

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedCategory = 'Tất cả';
  final List<OrderItem> _cart = [];
  String _customerName = 'Khách vãng lai';
  int _selectedTable = 0;
  final List<String> _categories = [
    'Tất cả',
    'Cà phê',
    'Trà',
    'Đồ ăn',
    'Nước ép',
  ];

  @override
  Widget build(BuildContext context) {
    final appData = Consumer.of<AppData>(context);
    final filteredProducts = _selectedCategory == 'Tất cả'
        ? appData.products
        : appData.products
              .where((p) => p.category == _selectedCategory)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt món'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_restaurant),
            onPressed: () => _showTableDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showCustomerDialog(),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildCategoryFilter(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(filteredProducts[index]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            child: _buildCartPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.brown.shade600 : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.brown.shade600
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildProductCard(Product product) => GestureDetector(
    onTap: () => _addToCart(product),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.brown.shade100,
              ),
              child: Center(
                child: Icon(
                  Icons.coffee,
                  size: 50,
                  color: Colors.brown.shade300,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${NumberFormat('#,###').format(product.price)}₫',
                      style: TextStyle(
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCartPanel() {
    final total = _cart.fold(0, (sum, item) => sum + item.total);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết đơn hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_customerName != 'Khách vãng lai')
                Chip(
                  label: Text(_customerName),
                  avatar: const Icon(Icons.person, size: 16),
                  onDeleted: () =>
                      setState(() => _customerName = 'Khách vãng lai'),
                ),
              if (_selectedTable > 0)
                Chip(
                  label: Text('Bàn $_selectedTable'),
                  avatar: const Icon(Icons.table_restaurant, size: 16),
                  onDeleted: () => setState(() => _selectedTable = 0),
                ),
            ],
          ),
        ),
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có món nào được chọn',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) =>
                      _buildCartItem(_cart[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tạm tính', style: TextStyle(fontSize: 16)),
                  Text(
                    NumberFormat('#,###').format(total),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat('#,###').format(total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cart.isEmpty
                          ? null
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã in tạm tính')),
                            ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('In tạm tính'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cart.isEmpty ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Thanh toán'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(OrderItem item, int index) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (item.note != null)
                Text(
                  item.note!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () => setState(() {
                if (item.quantity > 1)
                  item.quantity--;
                else
                  _cart.removeAt(index);
              }),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => setState(() => item.quantity++),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                NumberFormat('#,###').format(item.total),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  void _addToCart(Product product) => setState(() {
    final existingItem = _cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => OrderItem(product: product),
    );
    if (existingItem.product.id == product.id)
      existingItem.quantity++;
    else
      _cart.add(OrderItem(product: product));
  });

  void _checkout() {
    final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final appData = Consumer.of<AppData>(context);
    appData.addOrder(
      Order(
        orderNumber: orderNumber,
        createdAt: DateTime.now(),
        items: List.from(_cart),
        tableNumber: _selectedTable,
        customerName: _customerName,
        status: 'completed',
      ),
    );
    setState(() {
      _cart.clear();
      _customerName = 'Khách vãng lai';
      _selectedTable = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đơn hàng $orderNumber đã được tạo')),
    );
  }

  void _showTableDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chọn bàn'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              setState(() => _selectedTable = index + 1);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _selectedTable == index + 1
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedTable == index + 1
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedTable == index + 1
                        ? Colors.green
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );

  void _showCustomerDialog() {
    final controller = TextEditingController(text: _customerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin khách hàng'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên khách hàng',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => _customerName = controller.text.trim().isEmpty
                    ? 'Khách vãng lai'
                    : controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

// ==================== MENU MANAGEMENT SCREEN ====================

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Cà phê';
  File? _selectedImage;
  final List<String> _categories = [
    'Cà phê',
    'Trà',
    'Đồ ăn',
    'Nước ép',
    'Sinh tố',
  ];

  @override
  Widget build(BuildContext context) {
    final appData = Consumer.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thực đơn'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: appData.products.length,
        itemBuilder: (context, index) =>
            _buildProductCard(appData.products[index]),
      ),
    );
  }

  Widget _buildProductCard(Product product) => Dismissible(
    key: Key(product.id.toString()),
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    direction: DismissDirection.endToStart,
    onDismissed: (_) {
      final appData = Consumer.of<AppData>(context);
      appData.deleteProduct(product.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xóa ${product.name}')));
    },
    child: GestureDetector(
      onTap: () => _showAddEditDialog(product: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.brown.shade100,
                ),
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 50,
                    color: Colors.brown.shade400,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          NumberFormat('#,###').format(product.price),
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.isAvailable
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.isAvailable ? 'Còn hàng' : 'Hết hàng',
                            style: TextStyle(
                              color: product.isAvailable
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showAddEditDialog({Product? product}) {
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _descriptionController.text = product.description;
      _selectedCategory = product.category;
    } else {
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _selectedCategory = 'Cà phê';
      _selectedImage = null;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Thêm món mới' : 'Sửa món'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null)
                      setState(() => _selectedImage = File(picked.path));
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40),
                                SizedBox(height: 8),
                                Text('Chọn ảnh'),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên món',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Vui lòng nhập tên món' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Giá (VNĐ)',
                    border: OutlineInputBorder(),
                    prefixText: '₫',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v?.isEmpty == true ? 'Vui lòng nhập giá' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newProduct = Product(
                  id: product?.id,
                  name: _nameController.text,
                  category: _selectedCategory,
                  price: int.parse(_priceController.text),
                  imagePath: _selectedImage?.path,
                  description: _descriptionController.text,
                );
                final appData = Consumer.of<AppData>(context);
                if (product == null) {
                  appData.addProduct(newProduct);
                } else {
                  appData.updateProduct(newProduct);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      product == null ? 'Đã thêm món mới' : 'Đã cập nhật món',
                    ),
                  ),
                );
              }
            },
            child: Text(product == null ? 'Thêm' : 'Lưu'),
          ),
        ],
      ),
    );
  }
}

// ==================== ORDER SCREEN ====================

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng'), elevation: 0),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final orders = appData.orders.reversed.toList();
          if (orders.isEmpty)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có đơn hàng nào',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) =>
                _buildOrderCard(context, orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: order.status == 'completed'
            ? Colors.green
            : Colors.orange,
        child: Icon(
          order.status == 'completed' ? Icons.check_circle : Icons.pending,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        '#${order.orderNumber}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${order.customerName} - ${order.tableNumber > 0 ? 'Bàn ${order.tableNumber}' : 'Mang đi'}',
          ),
          Text(
            DateFormat('HH:mm dd/MM/yyyy').format(order.createdAt),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
      trailing: Text(
        NumberFormat('#,###').format(order.total),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.brown.shade700,
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.note != null)
                              Text(
                                item.note!,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat('#,###').format(item.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng cộng:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    NumberFormat('#,###').format(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã in hóa đơn')),
                          ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('In hóa đơn'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==================== REPORT SCREEN ====================

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Consumer.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildCard(
                  'Doanh thu',
                  NumberFormat('#,###').format(appData.todayRevenue),
                  Icons.attach_money,
                  Colors.green,
                  '+12%',
                ),
                _buildCard(
                  'Đơn hàng',
                  '${appData.todayOrders}',
                  Icons.receipt,
                  Colors.blue,
                  '+5%',
                ),
                _buildCard(
                  'Khách hàng',
                  '156',
                  Icons.people,
                  Colors.purple,
                  '+8%',
                ),
                _buildCard(
                  'Sản phẩm',
                  '${appData.products.length}',
                  Icons.coffee,
                  Colors.brown,
                  '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            if (change.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const Spacer(),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

// ==================== INVENTORY SCREEN ====================

// ==================== INVENTORY SCREEN (ĐÃ SỬA LỖI) ====================

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả',
    'Nguyên liệu',
    'Phụ gia',
    'Bao bì',
  ];

  @override
  Widget build(BuildContext context) {
    final appData = Consumer.of<AppData>(context);
    final lowStockCount = appData.getLowStockCount();
    final inventoryValue = appData.getInventoryValue();

    var filteredItems = appData.inventoryItems
        .where(
          (item) =>
              (_searchQuery.isEmpty ||
                  item.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  )) &&
              (_selectedCategory == 'Tất cả' ||
                  item.category == _selectedCategory),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý kho hàng'), elevation: 0),
      body: Column(
        children: [
          if (lowStockCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CẢNH BÁO TỒN KHO THẤP\n$lowStockCount mặt hàng cần nhập thêm',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                  Text(
                    'GIÁ TRỊ TỒN KHO\n${NumberFormat('#,###').format(inventoryValue)} đ',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm mặt hàng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.brown.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.brown.shade600
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // SỬA PHẦN NÀY - Bỏ Expanded bên ngoài DataTable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Mặt hàng')),
                DataColumn(label: Text('Danh mục')),
                DataColumn(label: Text('Số lượng tồn')),
                DataColumn(label: Text('Hạn mức')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Thao tác')),
              ],
              rows: filteredItems.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.name)),
                    DataCell(Text(item.category)),
                    DataCell(Text('${item.quantity} ${item.unit}')),
                    DataCell(Text('${item.minStock} ${item.unit}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.status == 'Sắp hết'
                              ? Colors.orange.shade100
                              : (item.status == 'Hết hàng'
                                    ? Colors.red.shade100
                                    : Colors.green.shade100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: item.status == 'Sắp hết'
                                ? Colors.orange.shade700
                                : (item.status == 'Hết hàng'
                                      ? Colors.red.shade700
                                      : Colors.green.shade700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _showImportDialog(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Nhập hàng'),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(InventoryItem item) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập hàng - ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Số lượng hiện tại: ${item.quantity} ${item.unit}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Số lượng nhập (${item.unit})',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(controller.text);
              if (qty != null && qty > 0) {
                final appData = Consumer.of<AppData>(context);
                appData.updateInventory(
                  InventoryItem(
                    id: item.id,
                    name: item.name,
                    category: item.category,
                    quantity: item.quantity + qty,
                    minStock: item.minStock,
                    unit: item.unit,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã nhập $qty ${item.unit} ${item.name}'),
                  ),
                );
              }
            },
            child: const Text('Nhập hàng'),
          ),
        ],
      ),
    );
  }
}

// ==================== EMPLOYEE SCREEN ====================

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPosition = 'Phục vụ';
  String _selectedShift = 'Sáng';
  final List<String> _positions = ['Quản lý', 'Barista', 'Phục vụ', 'Thu ngân'];
  final List<String> _shifts = ['Sáng', 'Chiều', 'Tối', 'N/A'];

  @override
  Widget build(BuildContext context) {
    final appData = Consumer.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhân viên'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 20),
                        SizedBox(width: 8),
                        Text('Tổng số: 4 nhân viên'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Đang làm: ${appData.employees.where((e) => e.isWorking).length}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appData.employees.length,
              itemBuilder: (context, index) =>
                  _buildEmployeeCard(appData.employees[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee emp) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.brown.shade100,
            child: Text(
              emp.name[0],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emp.position,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emp.shift,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(emp.phone, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: emp.isWorking
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  emp.isWorking ? 'Đang làm' : 'Nghỉ',
                  style: TextStyle(
                    color: emp.isWorking
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  final appData = Consumer.of<AppData>(context);
                  appData.toggleEmployeeStatus(emp.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        emp.isWorking
                            ? '${emp.name} đã nghỉ làm'
                            : '${emp.name} đã bắt đầu làm việc',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 32),
                ),
                child: Text(emp.isWorking ? 'Chấm công ra' : 'Chấm công vào'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  void _showAddEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhân viên'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Chức vụ',
                  border: OutlineInputBorder(),
                ),
                items: _positions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPosition = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedShift,
                decoration: const InputDecoration(
                  labelText: 'Ca làm',
                  border: OutlineInputBorder(),
                ),
                items: _shifts
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedShift = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final appData = Consumer.of<AppData>(context);
              appData.addEmployee(
                Employee(
                  name: _nameController.text,
                  position: _selectedPosition,
                  shift: _selectedShift,
                  phone: _phoneController.text,
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm nhân viên')),
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

// ==================== CUSTOMER SCREEN ====================

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Consumer.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý khách hàng'), elevation: 0),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tổng khách hàng',
                    '${appData.customers.length}',
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Khách hàng mới',
                    '12',
                    Icons.person_add,
                  ),
                ),
                Expanded(
                  child: _buildStatItem('Điểm thưởng', '2,450', Icons.star),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appData.customers.length,
              itemBuilder: (context, index) =>
                  _buildCustomerCard(appData.customers[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.brown, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _buildCustomerCard(Customer c) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.brown.shade100,
            child: Text(
              c.name[0],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(c.phone, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.email, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(c.email, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${c.points} điểm',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đã mua: ${c.totalOrders} đơn',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  void _showAddCustomerDialog(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm khách hàng mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final appData = Consumer.of<AppData>(context);
              appData.addCustomer(
                Customer(name: name.text, phone: phone.text, email: email.text),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã thêm khách hàng ${name.text}')),
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
