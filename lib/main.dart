import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'shop_setup_page.dart';
import 'customer_list_page.dart';
import 'add_customer_page.dart';
import 'transaction_history_page.dart';
import 'app_theme.dart';
import 'about.dart';
import 'home_page.dart'; // Import the new home page

// --------------------- Hive Models ---------------------

@HiveType(typeId: 0)
class Customer {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late double totalAmountOwed;

  @HiveField(2)
  late List<Map<String, dynamic>> transactions;

  @HiveField(3)
  late bool isPinned;

  Customer({
    required this.name,
    required this.totalAmountOwed,
    required this.transactions,
    this.isPinned = false,
  });
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 0;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final rawTransactions = fields[2] as List<dynamic>?;
    final transactions = rawTransactions == null
        ? <Map<String, dynamic>>[]
        : rawTransactions
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .toList();

    return Customer(
      name: fields[0] as String,
      totalAmountOwed: (fields[1] as num).toDouble(),
      transactions: transactions,
      isPinned: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.totalAmountOwed)
      ..writeByte(2)
      ..write(obj.transactions)
      ..writeByte(3)
      ..write(obj.isPinned);
  }
}

@HiveType(typeId: 1)
class ShopOwner {
  @HiveField(0)
  late String shopName;

  ShopOwner({required this.shopName});
}

class ShopOwnerAdapter extends TypeAdapter<ShopOwner> {
  @override
  final int typeId = 1;

  @override
  ShopOwner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopOwner(shopName: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, ShopOwner obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.shopName);
  }
}

// --------------------- Main App ---------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(ShopOwnerAdapter());
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<ShopOwner>('shopOwner');
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settingsBox = Hive.box('settings');
  ThemeMode? _themeMode;
  bool _isThemeLoaded = false;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      _settingsBox.put('themeMode', _themeMode!.name);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final savedTheme = _settingsBox.get('themeMode');
    setState(() {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      _isThemeLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThemeLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return MaterialApp(
      title: 'Hisab kitab',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: WrapperPage(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --------------------- Wrapper ---------------------

class WrapperPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const WrapperPage({super.key, required this.onToggleTheme});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  final _shopOwnerBox = Hive.box<ShopOwner>('shopOwner');
  late bool _isSetupComplete;

  @override
  void initState() {
    super.initState();
    _isSetupComplete = _shopOwnerBox.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSetupComplete) {
      return DebtTrackerPage(onToggleTheme: widget.onToggleTheme);
    } else {
      return ShopSetupPage(
        onSetupComplete: () {
          setState(() {
            _isSetupComplete = true;
          });
        },
      );
    }
  }
}

// --------------------- Debt Tracker ---------------------

class DebtTrackerPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DebtTrackerPage({super.key, required this.onToggleTheme});

  @override
  State<DebtTrackerPage> createState() => _DebtTrackerPageState();
}

class _DebtTrackerPageState extends State<DebtTrackerPage> {
  final _customerBox = Hive.box<Customer>('customers');
  final _shopOwnerBox = Hive.box<ShopOwner>('shopOwner');
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(), // Home page as first page
      const CustomerListPage(), // Customer list as second page
      AddCustomerPage(
        onCustomerAdded: () {
          setState(() {
            _selectedIndex = 1; // Go back to customer list after adding
          });
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: _shopOwnerBox.listenable(),
          builder: (context, Box<ShopOwner> box, _) {
            final shopName =
                box.isNotEmpty ? box.getAt(0)!.shopName : 'Your Shop';
            final firstName = shopName.split(' ').first;
            return Text(
              'Hisab Kitab for $firstName',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Hisab Kitab',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Customers'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Add Customer'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (_) {
                  widget.onToggleTheme();
                },
              ),
              onTap: () {
                widget.onToggleTheme();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined),
            activeIcon: Icon(Icons.person_add),
            label: 'Add',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
