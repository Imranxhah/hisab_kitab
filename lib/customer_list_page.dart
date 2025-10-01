import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'customer_detail_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _customerBox = Hive.box<Customer>('customers');
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _togglePinStatus(int index) {
    final customer = _customerBox.getAt(index);
    if (customer != null) {
      customer.isPinned = !customer.isPinned;
      _customerBox.putAt(index, customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'All Customers',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {});
              },
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                hintStyle: GoogleFonts.roboto(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Customer List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _customerBox.listenable(),
              builder: (context, Box<Customer> box, _) {
                final query = _searchController.text.toLowerCase();
                final allCustomers = box.values.toList();

                // Sort customers: Pinned customers first, then by name
                allCustomers.sort((a, b) {
                  if (a.isPinned && !b.isPinned) {
                    return -1;
                  } else if (!a.isPinned && b.isPinned) {
                    return 1;
                  }
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });

                final filteredCustomers = allCustomers.where((customer) {
                  return customer.name.toLowerCase().contains(query);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          query.isEmpty
                              ? Icons.person_add_outlined
                              : Icons.search_off_rounded,
                          size: 80,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          query.isEmpty
                              ? 'No customers yet'
                              : 'No customers found',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          query.isEmpty
                              ? 'Add your first customer to get started'
                              : 'Try a different search term',
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

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    final originalIndex = box.values.toList().indexOf(customer);
                    final isPositive = customer.totalAmountOwed >= 0;
                    final currencyFormat =
                        NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailPage(
                                  customer: customer,
                                  customerIndex: originalIndex,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar with gradient
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPositive
                                          ? [
                                              colorScheme.primary,
                                              colorScheme.primary
                                                  .withOpacity(0.7)
                                            ]
                                          : [
                                              Colors.green[600]!,
                                              Colors.green[500]!
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isPositive
                                                ? colorScheme.primary
                                                : Colors.green[600]!)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      customer.name[0].toUpperCase(),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Customer Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currencyFormat.format(
                                            customer.totalAmountOwed.abs()),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isPositive
                                              ? colorScheme.primary
                                              : Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Pin Button
                                IconButton(
                                  icon: Icon(
                                    customer.isPinned
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    color: customer.isPinned
                                        ? colorScheme.primary
                                        : colorScheme.onSurface
                                            .withOpacity(0.4),
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      _togglePinStatus(originalIndex),
                                  tooltip: customer.isPinned
                                      ? 'Unpin'
                                      : 'Pin to top',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
