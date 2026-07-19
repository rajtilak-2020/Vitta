import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VITTA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
          error: Color(0xFFFF1E1E),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF808080),
          thickness: 1,
          space: 1,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF808080), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF808080), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFFF1E1E), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFFF1E1E), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFFAAAAAA), fontFamily: 'monospace'),
          hintStyle: TextStyle(color: Color(0xFF808080), fontFamily: 'monospace'),
          errorStyle: TextStyle(
            color: Color(0xFFFF1E1E),
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('transactions');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        List<Transaction> loaded =
            decoded.map((item) => Transaction.fromJson(item)).toList();

        // Sort chronologically ascending to calculate running balance correctly
        loaded.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        _recalculateRunningBalances(loaded);
      } else {
        setState(() {
          _transactions = [];
          _balance = 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If error occurs, fallback to clean state
      setState(() {
        _transactions = [];
        _balance = 0.0;
        _isLoading = false;
      });
    }
  }

  void _recalculateRunningBalances(List<Transaction> list) {
    double runningBalance = 0.0;
    for (var tx in list) {
      if (tx.isCredit) {
        runningBalance += tx.amount;
      } else {
        runningBalance -= tx.amount;
      }
      tx.balanceAfter = runningBalance;
    }

    setState(() {
      _transactions = list;
      _balance = runningBalance;
      _isLoading = false;
    });
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr =
        jsonEncode(_transactions.map((tx) => tx.toJson()).toList());
    await prefs.setString('transactions', jsonStr);
  }

  Future<void> _addTransaction(double amount, bool isCredit, String note) async {
    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      isCredit: isCredit,
      note: note.trim().isEmpty ? 'Untitled' : note.trim(),
      timestamp: DateTime.now(),
    );

    List<Transaction> updated = List.from(_transactions)..add(newTx);
    updated.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _recalculateRunningBalances(updated);
    await _saveTransactions();
  }

  Future<void> _deleteTransaction(String id) async {
    List<Transaction> updated =
        _transactions.where((tx) => tx.id != id).toList();
    updated.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _recalculateRunningBalances(updated);
    await _saveTransactions();
  }

  void _showAddTransactionSheet({required bool isCredit}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCredit ? 'ADD CREDIT' : 'ADD DEBIT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isCredit
                            ? const Color(0xFF00FF66)
                            : const Color(0xFFFF1E1E),
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'AMOUNT',
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'AMOUNT REQUIRED';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'ENTER A VALID AMOUNT';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'NOTE / LABEL (OPTIONAL)',
                    hintText: 'e.g. Salary, Groceries',
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(amountController.text);
                      final note = noteController.text.trim();
                      _addTransaction(amount, isCredit, note);
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? const Color(0xFF00FF66)
                          : const Color(0xFFFF1E1E),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      'CONFIRM',
                      style: TextStyle(
                        color: isCredit ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationSheet(Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        final formattedAmount =
            '${tx.isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}';
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'DELETE TRANSACTION?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF808080), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      tx.note,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: tx.isCredit
                            ? const Color(0xFF00FF66)
                            : const Color(0xFFFF1E1E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border:
                              Border.all(color: const Color(0xFF808080), width: 1.5),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _deleteTransaction(tx.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1E1E),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Text(
            'LOADING...',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final displayedTransactions = _transactions.reversed.toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Image.asset(
                    'logo/vitta.png',
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if asset isn't loaded yet
                      return const Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 24);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'VITTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Balance Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF808080), width: 1.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL LEDGER BALANCE',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_balance >= 0 ? '+' : ''}\$${_balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: _balance >= 0
                            ? const Color(0xFF00FF66)
                            : const Color(0xFFFF1E1E),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAddTransactionSheet(isCredit: true),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF66),
                        border: Border(
                          right: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: const Text(
                        'ADD CREDIT',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAddTransactionSheet(isCredit: false),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF1E1E),
                      ),
                      child: const Text(
                        'ADD DEBIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Thick Divider
            Container(height: 4, color: const Color(0xFF808080)),

            // Log List
            Expanded(
              child: displayedTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        '// NO TRANSACTIONS YET',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: displayedTransactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final tx = displayedTransactions[index];
                        final formattedDate =
                            DateFormat('yyyy-MM-dd HH:mm').format(tx.timestamp);
                        final formattedAmount =
                            '${tx.isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}';
                        final formattedBalance =
                            'BAL: \$${tx.balanceAfter.toStringAsFixed(2)}';

                        return GestureDetector(
                          onLongPress: () => _showDeleteConfirmationSheet(tx),
                          child: Container(
                            color: Colors.transparent, // Fix hit-testing
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            child: Row(
                              children: [
                                // CR/DR indicator block
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: tx.isCredit
                                          ? const Color(0xFF00FF66)
                                          : const Color(0xFFFF1E1E),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tx.isCredit ? 'CR' : 'DR',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: tx.isCredit
                                          ? const Color(0xFF00FF66)
                                          : const Color(0xFFFF1E1E),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Note & Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.note,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Color(0xFF888888),
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Amount & Balance after
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formattedAmount,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: tx.isCredit
                                            ? const Color(0xFF00FF66)
                                            : const Color(0xFFFF1E1E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedBalance,
                                      style: const TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
