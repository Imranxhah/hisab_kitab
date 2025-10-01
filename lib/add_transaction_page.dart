// add_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';
import 'transaction_history_page.dart';

enum TransactionDirection {
  customerOwes,
  youOweCustomer,
}

class AddTransactionPage extends StatefulWidget {
  final Customer customer;
  final int customerIndex;

  const AddTransactionPage({
    super.key,
    required this.customer,
    required this.customerIndex,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _customerBox = Hive.box<Customer>('customers');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionDirection _transactionDirection =
      TransactionDirection.customerOwes;

  void _addTransaction(
    double amount,
    String? note,
    TransactionDirection direction,
  ) {
    final customer = _customerBox.getAt(widget.customerIndex)!;

    final finalAmount =
        direction == TransactionDirection.customerOwes ? amount : -amount;

    final Map<String, dynamic> newTransaction = {
      'amount': finalAmount,
      'date': DateTime.now().toIso8601String(),
      'note': note,
    };

    final updatedTransactions = customer.transactions
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    updatedTransactions.add(newTransaction);

    customer.transactions = updatedTransactions;
    customer.totalAmountOwed = updatedTransactions.fold(
      0.0,
      (double sum, tx) => sum + ((tx['amount'] as num).toDouble()),
    );

    _customerBox.putAt(widget.customerIndex, customer);

    _amountController.clear();
    _noteController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction recorded: Rs ${finalAmount.toStringAsFixed(2)}',
        ),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryPage(
          customer: customer,
          customerIndex: widget.customerIndex,
        ),
      ),
      (Route<dynamic> route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount TextField
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  prefixText: 'Rs ',
                  prefixStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Note TextField
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Transaction Type Selector - IMPROVED VERSION
              Text(
                'Transaction Type:',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Two Card Buttons Side by Side
              Row(
                children: [
                  // Customer Owes (Gave/Debit)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _transactionDirection =
                              TransactionDirection.customerOwes;
                        });
                      },
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _transactionDirection ==
                                  TransactionDirection.customerOwes
                              ? colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[850]
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _transactionDirection ==
                                    TransactionDirection.customerOwes
                                ? colorScheme.primary
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                            width: _transactionDirection ==
                                    TransactionDirection.customerOwes
                                ? 3
                                : 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _transactionDirection ==
                                        TransactionDirection.customerOwes
                                    ? colorScheme.primary
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You Gave',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _transactionDirection ==
                                        TransactionDirection.customerOwes
                                    ? colorScheme.primary
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customer owes you',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // You Owe Customer (Got/Credit)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _transactionDirection =
                              TransactionDirection.youOweCustomer;
                        });
                      },
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _transactionDirection ==
                                  TransactionDirection.youOweCustomer
                              ? Colors.green.withOpacity(0.1)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[850]
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _transactionDirection ==
                                    TransactionDirection.youOweCustomer
                                ? Colors.green
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                            width: _transactionDirection ==
                                    TransactionDirection.youOweCustomer
                                ? 3
                                : 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _transactionDirection ==
                                        TransactionDirection.youOweCustomer
                                    ? Colors.green
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You Got',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _transactionDirection ==
                                        TransactionDirection.youOweCustomer
                                    ? Colors.green[700]
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customer paid you',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Add Transaction Button
              ElevatedButton(
                onPressed: () {
                  final double? amount =
                      double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    _addTransaction(
                      amount,
                      _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                      _transactionDirection,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enter a valid amount greater than zero.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Record Transaction',
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
