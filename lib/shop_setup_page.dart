import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'main.dart';

// Page for the initial shop setup.

class ShopSetupPage extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const ShopSetupPage({super.key, required this.onSetupComplete});

  @override
  State<ShopSetupPage> createState() => _ShopSetupPageState();
}

class _ShopSetupPageState extends State<ShopSetupPage> {
  final TextEditingController _shopNameController = TextEditingController();

  void _saveShopName() {
    if (_shopNameController.text.isNotEmpty) {
      final shopOwner = ShopOwner(shopName: _shopNameController.text);

      Hive.box<ShopOwner>('shopOwner').add(shopOwner);

      widget.onSetupComplete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your shop name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Text(
                'Welcome',

                textAlign: TextAlign.center,

                style: GoogleFonts.montserrat(
                  fontSize: 32,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Let\'s get your account set up.',

                textAlign: TextAlign.center,

                style: GoogleFonts.montserrat(
                  fontSize: 16,

                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 48),

              Text(
                'Shop Name',

                style: GoogleFonts.montserrat(
                  fontSize: 16,

                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _shopNameController,

                style: GoogleFonts.montserrat(),

                decoration: InputDecoration(
                  hintText: 'Enter your shop name',

                  hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),

                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,

                      width: 2.0,
                    ),

                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,

                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveShopName,

                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    50,
                  ), // Increased height for better tapability

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(
                  'Save',

                  style: GoogleFonts.montserrat(
                    fontSize: 18,

                    fontWeight: FontWeight.w600,

                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
