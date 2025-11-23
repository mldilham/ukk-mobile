import 'package:flutter/material.dart';
import 'package:ukk_mobile_maulid/services/CategoriesService.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  final CategoryService _categoryService = CategoryService();
  List<dynamic> categories = [];
  List<dynamic> filteredCategories = [];
  bool isLoading = true;
  bool isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);
    final data = await _categoryService.getCategories();
    setState(() {
      categories = data;
      filteredCategories = data;
      isLoading = false;
    });
    _animationController.forward();
  }

  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCategories = categories;
      });
    } else {
      setState(() {
        filteredCategories = categories.where((category) {
          final categoryName = category['nama_kategori']?.toString().toLowerCase() ?? '';
          return categoryName.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Widget _buildCategoryCard(int index) {
    final item = filteredCategories[index];
    final productCount = item["jumlah_produk"] ?? 0;
    final color = _getCategoryColor(index);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // TODO: buka produk berdasarkan kategori
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Menampilkan produk di kategori ${item["nama_kategori"]}"),
                backgroundColor: Colors.blue.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category,
                    size: 30,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Category Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["nama_kategori"] ?? "-",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$productCount produk",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Cari kategori...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.grey.shade800),
                onChanged: _filterCategories,
              )
            : Text(
                "Kategori Produk",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        leading: isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    _searchController.clear();
                    _filterCategories('');
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade700),
                  onPressed: () {
                    _searchController.clear();
                    _filterCategories('');
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search, color: Colors.grey.shade700),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),
          if (!isSearching)
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.blue.shade700),
              onPressed: () {
                // TODO: Navigate to add category
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Fitur tambah kategori akan segera hadir"),
                    backgroundColor: Colors.blue.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchCategories,
        color: Colors.blue.shade700,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          categories.isEmpty
                              ? "Tidak ada kategori"
                              : "Tidak ada kategori yang cocok dengan pencarian",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                        if (categories.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to add category
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Fitur tambah kategori akan segera hadir"),
                                  backgroundColor: Colors.blue.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Tambah Kategori"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (ctx, index) => _buildCategoryCard(index),
                    ),
                  ),
      ),
    );
  }
}