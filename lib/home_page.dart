import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerBox = Hive.box<Customer>('customers');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: customerBox.listenable(),
        builder: (context, Box<Customer> box, _) {
          // Calculate totals
          double totalOwedToYou = 0.0;
          double totalYouOwe = 0.0;
          int customersOweYou = 0;
          int customersYouOwe = 0;

          for (var customer in box.values) {
            if (customer.totalAmountOwed > 0) {
              totalOwedToYou += customer.totalAmountOwed;
              customersOweYou++;
            } else if (customer.totalAmountOwed < 0) {
              totalYouOwe += customer.totalAmountOwed.abs();
              customersYouOwe++;
            }
          }

          final netBalance = totalOwedToYou - totalYouOwe;
          final currencyFormat =
              NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Net Balance Card
                  _buildNetBalanceCard(
                    context,
                    netBalance,
                    currencyFormat,
                    colorScheme,
                  ),

                  const SizedBox(height: 24),

                  // Stacked Layout for Owed Cards
                  Column(
                    // Changed from Row to Column
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Ensure cards take full width
                    children: [
                      _buildOwedToYouCard(
                        // Removed Expanded
                        context,
                        totalOwedToYou,
                        customersOweYou,
                        currencyFormat,
                        colorScheme,
                      ),
                      const SizedBox(
                          height:
                              16), // Changed width: 16 to height: 16 for vertical spacing
                      _buildYouOweCard(
                        // Removed Expanded
                        context,
                        totalYouOwe,
                        customersYouOwe,
                        currencyFormat,
                        colorScheme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildStatisticsSection(
                    context,
                    box,
                    colorScheme,
                  ),

                  const SizedBox(height: 24),

                  // Recent Summary
                  _buildRecentSummary(
                    context,
                    box,
                    colorScheme,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetBalanceCard(
    BuildContext context,
    double netBalance,
    NumberFormat currencyFormat,
    ColorScheme colorScheme,
  ) {
    final isPositive = netBalance >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ]
              : [
                  Colors.orange[700]!,
                  Colors.orange[600]!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? colorScheme.primary : Colors.orange[700]!)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Net Balance',
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(netBalance.abs()),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPositive ? 'YOU ARE RECEIVING' : 'YOU ARE PAYING',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Updated: ${DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now())}',
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwedToYouCard(
    BuildContext context,
    double amount,
    int count,
    NumberFormat currencyFormat,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[600]!,
            Colors.green[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green[600]!.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You Will Receive',
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(amount),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count ${count == 1 ? 'Customer' : 'Customers'}',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouOweCard(
    BuildContext context,
    double amount,
    int count,
    NumberFormat currencyFormat,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red[600]!,
            Colors.red[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red[600]!.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You Will Pay',
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(amount),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count ${count == 1 ? 'Customer' : 'Customers'}',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    Box<Customer> box,
    ColorScheme colorScheme,
  ) {
    final totalCustomers = box.length;
    int totalTransactions = 0;

    for (var customer in box.values) {
      totalTransactions += customer.transactions.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Customers',
                totalCustomers.toString(),
                Icons.people,
                colorScheme.primary,
                colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Transactions',
                totalTransactions.toString(),
                Icons.receipt_long,
                Colors.blue[600]!,
                colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSummary(
    BuildContext context,
    Box<Customer> box,
    ColorScheme colorScheme,
  ) {
    // Get top 5 customers by absolute amount
    final customers = box.values.toList();
    customers.sort(
        (a, b) => b.totalAmountOwed.abs().compareTo(a.totalAmountOwed.abs()));
    final topCustomers = customers.take(5).toList();

    if (topCustomers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Customers Yet',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first customer to get started',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Customers',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: topCustomers.asMap().entries.map((entry) {
              final index = entry.key;
              final customer = entry.value;
              final isPositive = customer.totalAmountOwed >= 0;
              final currencyFormat =
                  NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);

              // Dynamic colors based on theme
              final bool isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              final avatarColors = isPositive
                  ? [
                      isDarkMode ? Colors.green[400]! : Colors.green[500]!,
                      isDarkMode ? Colors.green[500]! : Colors.green[600]!
                    ]
                  : [
                      isDarkMode ? Colors.red[400]! : Colors.red[500]!,
                      isDarkMode ? Colors.red[500]! : Colors.red[600]!
                    ];

              final amountColor = isPositive
                  ? (isDarkMode ? Colors.green[400] : Colors.green[700])
                  : (isDarkMode ? Colors.red[400] : Colors.red[700]);

              final badgeBackgroundColor = isPositive
                  ? (isDarkMode
                      ? Colors.green[900]!.withOpacity(0.3)
                      : Colors.green[50])
                  : (isDarkMode
                      ? Colors.red[900]!.withOpacity(0.3)
                      : Colors.red[50]);

              final badgeTextColor = isPositive
                  ? (isDarkMode ? Colors.green[300] : Colors.green[700])
                  : (isDarkMode ? Colors.red[300] : Colors.red[700]);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: index < topCustomers.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: colorScheme.outline.withOpacity(0.1),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: avatarColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${customer.transactions.length} ${customer.transactions.length == 1 ? 'transaction' : 'transactions'}',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currencyFormat.format(customer.totalAmountOwed.abs()),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPositive ? 'Owes You' : 'You Owe',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
