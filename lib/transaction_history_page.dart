import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'main.dart';

class TransactionHistoryPage extends StatefulWidget {
  final Customer customer;
  final int customerIndex;

  const TransactionHistoryPage({
    super.key,
    required this.customer,
    required this.customerIndex,
  });

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _customerBox = Hive.box<Customer>('customers');

  void _deleteTransaction(int transactionIndex) {
    final customer = _customerBox.getAt(widget.customerIndex)!;
    final updatedTransactions = customer.transactions
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    updatedTransactions.removeAt(transactionIndex);
    final newTotal = updatedTransactions.fold<double>(
      0.0,
      (sum, tx) => sum + ((tx['amount'] as num).toDouble()),
    );
    customer.transactions = updatedTransactions;
    customer.totalAmountOwed = newTotal;
    _customerBox.putAt(widget.customerIndex, customer);
  }

  void _confirmDeleteTransaction(int transactionIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Transaction',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Do you really want to delete this transaction? This action cannot be undone.',
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTransaction(transactionIndex);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(
      int transactionIndex, double newAmount, String newNote) {
    final customer = _customerBox.getAt(widget.customerIndex)!;
    final updatedTransactions = customer.transactions
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    updatedTransactions[transactionIndex]['amount'] = newAmount;
    updatedTransactions[transactionIndex]['note'] = newNote;
    final newTotal = updatedTransactions.fold<double>(
      0.0,
      (sum, tx) => sum + ((tx['amount'] as num).toDouble()),
    );
    customer.transactions = updatedTransactions;
    customer.totalAmountOwed = newTotal;
    _customerBox.putAt(widget.customerIndex, customer);
  }

  void _showEditDialog(int transactionIndex) {
    final transaction = Map<String, dynamic>.from(
      widget.customer.transactions[transactionIndex] as Map,
    );
    final amountController = TextEditingController(
      text: (transaction['amount'] as num).toString(),
    );
    final noteController = TextEditingController(
      text: transaction['note'] as String?,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Transaction',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: const OutlineInputBorder(),
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = double.tryParse(amountController.text) ?? 0.0;
                final newNote = noteController.text;
                _editTransaction(transactionIndex, newAmount, newNote);
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetHistory() {
    final customer = _customerBox.getAt(widget.customerIndex)!;
    customer.totalAmountOwed = 0.0;
    customer.transactions = [];
    _customerBox.putAt(widget.customerIndex, customer);
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Transaction History',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all transactions for this customer? This action cannot be undone.',
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _resetHistory();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showShareOrSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Share or Save History',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'How would you like to handle this transaction history?',
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareAsPdf();
              },
              child: Text(
                'Share as PDF',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveAsPdf();
              },
              child: Text(
                'Save as PDF',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareAsPdf() async {
    try {
      final pdfBytes = await _generatePdfDocument();
      final directory = await getTemporaryDirectory();
      final fileName =
          '${widget.customer.name.replaceAll(' ', '-')}-transaction-history.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Transaction history for ${widget.customer.name}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sharing PDF: $e',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<List<int>> _generatePdfDocument() async {
    final pdf = pw.Document();
    final customerName = widget.customer.name;
    final transactions = widget.customer.transactions;
    final totalAmount = transactions.fold<double>(
      0.0,
      (sum, tx) =>
          sum +
          ((Map<String, dynamic>.from(tx as Map)['amount'] as num).toDouble()),
    );

    final List<List<String>> tableData = transactions.map((tx) {
      final transaction = Map<String, dynamic>.from(tx as Map);
      final amount = (transaction['amount'] as num).toDouble();
      final isDebit = amount > 0;
      return [
        'Rs ${amount.abs().toStringAsFixed(2)}',
        isDebit ? 'Debit' : 'Credit',
        DateFormat('MMM dd, yyyy\nhh:mm a').format(
          transaction['date'] is DateTime
              ? transaction['date'] as DateTime
              : DateTime.tryParse(transaction['date'].toString()) ??
                  DateTime.now(),
        ),
        (transaction['note'] as String?) ?? 'N/A',
      ];
    }).toList();

    const int maxRowsPerPage = 20;
    final List<List<List<String>>> pageChunks = [];
    for (int i = 0; i < tableData.length; i += maxRowsPerPage) {
      final endIndex = (i + maxRowsPerPage > tableData.length)
          ? tableData.length
          : i + maxRowsPerPage;
      pageChunks.add(tableData.sublist(i, endIndex));
    }

    for (int pageIndex = 0; pageIndex < pageChunks.length; pageIndex++) {
      final isFirstPage = pageIndex == 0;
      final isLastPage = pageIndex == pageChunks.length - 1;
      final currentChunk = pageChunks[pageIndex];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Stack(children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5,
                    child: pw.Opacity(
                      opacity: 0.1,
                      child: pw.Text(
                        'Hisab Kitab',
                        style: pw.TextStyle(
                          fontSize: 60,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (isFirstPage) ...[
                    pw.Text(
                      'Transaction History',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Customer: $customerName',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(thickness: 2),
                    pw.SizedBox(height: 10),
                  ] else ...[
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Transaction History - $customerName',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Page ${pageIndex + 1} of ${pageChunks.length}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                  ],
                  pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellAlignment: pw.Alignment.centerLeft,
                    cellPadding: const pw.EdgeInsets.all(4),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(80),
                      1: const pw.FixedColumnWidth(60),
                      2: const pw.FixedColumnWidth(100),
                      3: const pw.FlexColumnWidth(2),
                    },
                    headers: ['Amount', 'Type', 'Date & Time', 'Description'],
                    data: currentChunk,
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                  ),
                  pw.Spacer(),
                  if (isLastPage) ...[
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Transactions: ${transactions.length}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Total Amount: Rs ${totalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    pw.SizedBox(height: 10),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Page ${pageIndex + 1} of ${pageChunks.length}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ],
              )
            ]);
          },
        ),
      );
    }

    if (transactions.isEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Stack(children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5,
                    child: pw.Opacity(
                      opacity: 0.1,
                      child: pw.Text(
                        'Hisab Kitab',
                        style: pw.TextStyle(
                          fontSize: 60,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Transaction History',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Customer: $customerName',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text(
                      'No transactions found for this customer.',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    'Total Amount: Rs 0.00',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              )
            ]);
          },
        ),
      );
    }

    return await pdf.save();
  }

  Future<void> _saveAsPdf() async {
    try {
      final pdfBytes = await _generatePdfDocument();
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${widget.customer.name.replaceAll(' ', '-')}-transaction-history.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'History saved successfully!',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved to: App Documents/',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                'File: $fileName',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () {
              OpenFilex.open(file.path);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving PDF: $e',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customer.name,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Transaction History',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: _showShareOrSaveDialog,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _customerBox.listenable(),
        builder: (context, Box<Customer> box, _) {
          final customer = box.getAt(widget.customerIndex)!;
          if (customer.transactions.isEmpty) {
            return _buildEmptyState(context);
          }
          final reversedTransactions = customer.transactions.reversed.toList();
          final totalAmount = customer.transactions.fold<double>(
            0.0,
            (sum, tx) =>
                sum +
                ((Map<String, dynamic>.from(tx as Map)['amount'] as num)
                    .toDouble()),
          );
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customer.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = Map<String, dynamic>.from(
                      customer.transactions[index] as Map,
                    );
                    return _buildTransactionCard(context, transaction, index);
                  },
                ),
              ),
              _buildTotalBar(context, totalAmount),
              _buildResetButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> transaction, int index) {
       
    final colorScheme = Theme.of(context).colorScheme;
    final amount = (transaction['amount'] as num).toDouble();
    final note = transaction['note'] as String?;
    final dateRaw = transaction['date'];
    final date = dateRaw is DateTime
        ? dateRaw
        : DateTime.tryParse(dateRaw.toString()) ?? DateTime.now();

    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final absAmount = amount.abs();

    final isDebit = amount > 0;
    final currencyFormat = NumberFormat.currency(
      symbol: 'Rs ',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surfaceContainerHighest.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDebit
                          ? [
                              colorScheme.primary.withOpacity(0.2),
                              colorScheme.primary.withOpacity(0.1),
                            ]
                          : [
                              Colors.green.withOpacity(0.2),
                              Colors.green.withOpacity(0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isDebit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: isDebit ? colorScheme.primary : Colors.green[700],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note != null && note.isNotEmpty
                            ? note
                            : "No description",
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              "$formattedDate · $formattedTime",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error.withOpacity(0.7),
                    size: 22,
                  ),
                  onPressed: () => _confirmDeleteTransaction(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDebit
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDebit
                      ? colorScheme.primary.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDebit ? 'Debit' : 'Credit',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDebit ? colorScheme.primary : Colors.green[700],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      currencyFormat.format(absAmount),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDebit ? colorScheme.primary : Colors.green[700],
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBar(BuildContext context, double totalAmount) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = totalAmount >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05)
                ]
              : [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(
            color: isPositive
                ? colorScheme.primary.withOpacity(0.2)
                : Colors.green.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? colorScheme.primary.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPositive ? 'Customer Owes You' : 'You Owe Customer',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? colorScheme.primary : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),

          // Right side total (fixed to avoid overflow)
          Flexible(
            child: Text(
              'Rs ${totalAmount.abs().toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isPositive ? colorScheme.primary : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _showResetConfirmationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, size: 20),
            const SizedBox(width: 8),
            Text(
              'Reset History',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Transactions Yet',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Transaction history will appear here\nonce you add your first entry',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
