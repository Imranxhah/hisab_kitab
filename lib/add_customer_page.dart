import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import the package
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';
import 'app_theme.dart';

class AddCustomerPage extends StatefulWidget {
  final VoidCallback onCustomerAdded;

  const AddCustomerPage({super.key, required this.onCustomerAdded});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final TextEditingController _nameController = TextEditingController();
  final _customerBox = Hive.box<Customer>('customers');

  void _addCustomer() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a customer name')),
      );
      return;
    }

    final isNameExists = _customerBox.values.any(
      (customer) => customer.name.toLowerCase() == name.toLowerCase(),
    );

    if (isNameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A customer with this name already exists'),
        ),
      );
    } else {
      final newCustomer = Customer(
        name: name,
        totalAmountOwed: 0.0,
        transactions: [],
      );
      _customerBox.add(newCustomer);

      _nameController.clear();

      widget.onCustomerAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Customer",
          style: GoogleFonts.montserrat(
            // Professional font for the title
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Customer Name",
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.montserrat(
                  // Consistent font for the label
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCustomer,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  50,
                ), // Make the button taller
              ),
              child: Text(
                "Save",
                style: GoogleFonts.montserrat(
                  // Consistent font for the button
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
