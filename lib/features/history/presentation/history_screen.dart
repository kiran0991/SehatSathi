import 'package:flutter/material.dart';

void main() {
  runApp(const SehatSathiApp());
}

class SehatSathiApp extends StatelessWidget {
  const SehatSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehat Sathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF064E3B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0A0A0A)),
        ),
      ),
      home: const HistoryScreen(),
    );
  }
}

// Dummy Data Model
class ScanHistoryItem {
  final String name;
  final String brand;
  final String status;
  final String time;
  final Color statusColor;

  ScanHistoryItem({
    required this.name,
    required this.brand,
    required this.status,
    required this.time,
    required this.statusColor,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _concernsOnly = false;

  // Design Tokens
  static const Color primaryColor = Color(0xFF064E3B);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF16A34A);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFF59E0B);

  // TODO: replace dummy items with ref.watch(historyControllerProvider)
  final List<ScanHistoryItem> dummyHistory = [
    ScanHistoryItem(
      name: 'Whole Grain Digestives',
      brand: "McVitie's Organic",
      status: 'EXCELLENT',
      time: '2h ago',
      statusColor: successColor,
    ),
    ScanHistoryItem(
      name: 'Classic Cola 500ml',
      brand: 'Sparkling Beverage',
      status: 'UNSAFE',
      time: '5h ago',
      statusColor: errorColor,
    ),
    ScanHistoryItem(
      name: 'Sea Salt Kettle Chips',
      brand: 'Farm Fresh Snacks',
      status: 'MODERATE',
      time: 'Yesterday',
      statusColor: warningColor,
    ),
    ScanHistoryItem(
      name: 'Non-Fat Greek Yogurt',
      brand: 'Daily Dairy Co.',
      status: 'EXCELLENT',
      time: 'Nov 12',
      statusColor: successColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.qr_code_scanner, color: primaryColor),
        title: const Text(
          'Sehat Sathi',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), // Light grey matching mockup
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search history...',
                  hintStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(Icons.search, color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Scans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Concerns Only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _concernsOnly,
                      onChanged: (val) {
                        setState(() {
                          _concernsOnly = val;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // History List
            Expanded(
              child: ListView.builder(
                itemCount: dummyHistory.length,
                itemBuilder: (context, index) {
                  final item = dummyHistory[index];
                  return _buildHistoryCard(item);
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1, // History is active
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondary,
          backgroundColor: surfaceColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.camera_alt_outlined),
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history, color: Colors.white),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.person_outline),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ScanHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Colored Border
              Container(width: 4, color: item.statusColor),
              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Placeholder icon since we don't have the actual assets
                        child: const Icon(
                          Icons.image,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.brand,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Status Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: item.statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right Side: Time & Chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF), // Lighter grey for time
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFD1D5DB),
                            size: 20,
                          ),
                          const SizedBox(height: 12),
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
  }
}
