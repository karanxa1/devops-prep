import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/shopping_item.dart';
import '../providers/app_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();
  bool _isGenerating = false;

  Future<void> _generateShoppingList() async {
    setState(() => _isGenerating = true);

    final provider = context.read<AppProvider>();
    final meals = provider.meals;

    if (meals.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Add some meals first to generate a list'),
              ],
            ),
            backgroundColor: AppTheme.warningAmber,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      setState(() => _isGenerating = false);
      return;
    }

    await provider.generateAndSaveShoppingList(meals.take(10).toList());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Shopping list generated! 🛒'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() => _isGenerating = false);
  }

  Future<void> _addItem() async {
    if (_itemController.text.isEmpty) return;

    final provider = context.read<AppProvider>();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final item = ShoppingItem(
      name: _itemController.text,
      quantity: '',
      unit: '',
      category: 'Other',
      weekStart: weekStart,
    );

    await provider.addShoppingItem(item);
    _itemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              final items = provider.shoppingItems;
              final checkedItems = items.where((i) => i.isChecked).length;

              // Group by category
              final groupedItems = <String, List<ShoppingItem>>{};
              for (final item in items) {
                groupedItems.putIfAbsent(item.category, () => []).add(item);
              }

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.tealGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Shopping List',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (items.isNotEmpty)
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                ],
                              ),
                              child: Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.warning_rounded, color: AppTheme.errorRed),
                                      const SizedBox(width: 8),
                                      const Text('Clear List?'),
                                    ],
                                  ),
                                  content: const Text('This will remove all items from your shopping list.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                context.read<AppProvider>().clearShoppingList();
                              }
                            },
                          ),
                      ],
                    ),
                  ),

                  // Progress card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GradientCard(
                      gradient: AppTheme.tealGradient,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.checklist_rounded, color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${items.length} items',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$checkedItems checked off ✓',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              ],
                            ),
                          ),
                          AnimatedProgressRing(
                            progress: items.isEmpty ? 0 : checkedItems / items.length,
                            size: 70,
                            strokeWidth: 6,
                            color: Colors.white,
                            child: Text(
                              '${items.isEmpty ? 0 : ((checkedItems / items.length) * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Add item input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _itemController,
                              decoration: InputDecoration(
                                hintText: 'Add an item...',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                prefixIcon: Icon(Icons.add_shopping_cart_rounded, color: AppTheme.accentTeal),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onSubmitted: (_) => _addItem(),
                            ),
                          ),
                          GestureDetector(
                            onTap: _addItem,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.tealGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Items list
                  Expanded(
                    child: items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: groupedItems.keys.length,
                            itemBuilder: (context, index) {
                              final category = groupedItems.keys.elementAt(index);
                              final categoryItems = groupedItems[category]!;
                              return _buildCategorySection(category, categoryItems, provider);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: PulsingFAB(
        icon: Icons.auto_awesome_rounded,
        label: _isGenerating ? 'Generating...' : 'AI Generate',
        onPressed: _generateShoppingList,
        isLoading: _isGenerating,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.tealGradient.scale(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_basket_rounded, size: 48, color: AppTheme.accentTeal),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty 🛒',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items manually or generate from meals',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingItem> items, AppProvider provider) {
    final categoryIcons = {
      'Produce': Icons.eco_rounded,
      'Dairy': Icons.egg_rounded,
      'Meat': Icons.restaurant_rounded,
      'Pantry': Icons.kitchen_rounded,
      'Frozen': Icons.ac_unit_rounded,
      'Bakery': Icons.bakery_dining_rounded,
      'Other': Icons.category_rounded,
    };

    final categoryColors = {
      'Produce': AppTheme.tealGradient,
      'Dairy': AppTheme.blueGradient,
      'Meat': AppTheme.sunsetGradient,
      'Pantry': AppTheme.purpleGradient,
      'Frozen': AppTheme.oceanGradient,
      'Bakery': AppTheme.primaryGradient,
      'Other': AppTheme.primaryGradient,
    };

    return AnimatedListItem(
      index: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: categoryColors[category] ?? AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcons[category] ?? Icons.category_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => Dismissible(
            key: Key(item.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            onDismissed: (_) => provider.deleteShoppingItem(item.id!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: GestureDetector(
                  onTap: () => provider.toggleShoppingItem(item.id!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: item.isChecked ? AppTheme.tealGradient : null,
                      color: item.isChecked ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: item.isChecked ? null : Border.all(color: Colors.grey.shade300),
                    ),
                    child: item.isChecked
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? Colors.grey.shade400 : AppTheme.textPrimary,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade300, size: 18),
                  onPressed: () => provider.deleteShoppingItem(item.id!),
                ),
              ),
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
