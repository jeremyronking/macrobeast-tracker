import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/types.dart';
import '../providers/app_state.dart';
import '../services/gemini_service.dart';

class AddScanScreen extends ConsumerStatefulWidget {
  const AddScanScreen({super.key});

  @override
  ConsumerState<AddScanScreen> createState() => _AddScanScreenState();
}

class _AddScanScreenState extends ConsumerState<AddScanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;

  // Scanner Controller
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isSearching = true);

    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please configure GEMINI_API_KEY')),
      );
      return;
    }

    final service = GeminiService(apiKey);
    final results = await service.searchFoodAI(_searchController.text);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isScanning) return; // Prevent multiple triggers
    _isScanning = true;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) {
      _isScanning = false;
      return;
    }

    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      _isScanning = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please configure GEMINI_API_KEY')),
      );
      return;
    }

    // Pause camera
    // cameraController.stop();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    final service = GeminiService(apiKey);
    final food = await service.identifyBarcodeFood(barcode);

    if (mounted) {
      Navigator.pop(context); // Close loading
      if (food != null) {
        _showAddFoodDialog(food);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not identify food.')),
        );
      }
      _isScanning = false;
    }
  }

  void _showAddFoodDialog(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              food.brand ?? 'Unknown Brand',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _MacroRow(macros: food.macros),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final entry = LogEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    food: food,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                    date: DateTime.now().toIso8601String().split('T')[0],
                  );
                  ref.read(dailyLogProvider.notifier).addEntry(entry);
                  Navigator.pop(context);
                  // Optional: Navigate to log
                  // ref.read(activeTabProvider.notifier).setTab(AppTab.FOOD_LOG); // Maybe don't auto switch in native app
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${food.name} to log')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add to Log",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Food",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: "Search", icon: Icon(LucideIcons.search)),
            Tab(text: "Scan Barcode", icon: Icon(LucideIcons.scanLine)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Search Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _handleSearch(),
                        decoration: InputDecoration(
                          hintText: "Search food (e.g. 'Avocado Toast')",
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF27272A)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(LucideIcons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _handleSearch,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(LucideIcons.arrowRight),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return InkWell(
                      onTap: () => _showAddFoodDialog(item),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF27272A)
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${item.macros.calories.toStringAsFixed(0)} kcal • ${item.servingSize}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.plusCircle,
                              color: Theme.of(context).colorScheme.primary,
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

          // Scan Tab
          Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: _handleBarcode,
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Point camera at a barcode",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final Macros macros;
  const _MacroRow({required this.macros});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Badge("Calories", "${macros.calories.toStringAsFixed(0)}", Colors.red),
        _Badge(
          "Protein",
          "${macros.protein.toStringAsFixed(0)}g",
          Colors.orange,
        ),
        _Badge("Carbs", "${macros.carbs.toStringAsFixed(0)}g", Colors.blue),
        _Badge("Fat", "${macros.fat.toStringAsFixed(0)}g", Colors.purple),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Badge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
