import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StockItem {
  final String id;
  String name;
  double quantity;
  String unit;
  String status;

  StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.status = 'En stock',
  });
}

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  List<StockItem> _stockItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStockItems();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStockItems() {
    // Simulate fetching stock items
    setState(() {
      _stockItems = [
        StockItem(id: 'P001', name: 'Tomates', quantity: 150, unit: 'kg'),
        StockItem(id: 'P002', name: 'Pommes de terre', quantity: 200, unit: 'kg'),
        StockItem(id: 'P003', name: 'Maïs', quantity: 500, unit: 'kg', status: 'Faible stock'),
        StockItem(id: 'P004', name: 'Laitues', quantity: 50, unit: 'pièces', status: 'Épuisé'),
        StockItem(id: 'P005', name: 'Carottes', quantity: 120, unit: 'kg'),
      ];
    });
  }

  List<StockItem> get _filteredStockItems {
    if (_searchQuery.isEmpty) {
      return _stockItems;
    }
    return _stockItems.where((item) {
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addStockItem() {
    // TODO: Implement add stock item form/dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajouter un nouvel article en stock')),
    );
  }

  void _editStockItem(StockItem item) {
    // TODO: Implement edit stock item form/dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modifier ${item.name}')),
    );
  }

  void _deleteStockItem(String id) {
    setState(() {
      _stockItems.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Article supprimé du stock')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          Expanded(
            child: _filteredStockItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun article en stock trouvé.',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredStockItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredStockItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.status == 'En stock'
                                  ? Colors.green.withOpacity(0.1)
                                  : item.status == 'Faible stock'
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.status == 'En stock'
                                  ? Icons.check_circle_rounded
                                  : item.status == 'Faible stock'
                                      ? Icons.warning_rounded
                                      : Icons.cancel_rounded,
                              color: item.status == 'En stock'
                                  ? Colors.green
                                  : item.status == 'Faible stock'
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            '${item.quantity} ${item.unit} - ${item.status}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                                onPressed: () => _editStockItem(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                onPressed: () => _deleteStockItem(item.id),
                              ),
                            ],
                          ),
                          onTap: () {
                            _editStockItem(item);
                          },
                        ),
                      ).animate().fade().slideX(
                            begin: 0.5,
                            duration: const Duration(milliseconds: 300),
                            delay: Duration(milliseconds: index * 50),
                          );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStockItem,
        label: const Text('Ajouter un Produit'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
