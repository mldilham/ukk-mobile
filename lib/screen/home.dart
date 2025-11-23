import 'package:flutter/material.dart';
import 'package:ukk_mobile_maulid/screen/DetailProduct.dart';
import 'package:ukk_mobile_maulid/screen/TambahProduk.dart';
import 'package:ukk_mobile_maulid/screen/kategori.dart';
import 'package:ukk_mobile_maulid/screen/produk.dart';
import 'package:ukk_mobile_maulid/screen/profile.dart';
import 'package:ukk_mobile_maulid/screen/toko.dart';
import '../services/ProductService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardHome(),
      ProdukTokoScreen(),
      TokoScreen(),
      CategoryScreen(),
      ProfileScreen(),
    ];
  }

  void _onNavTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: "Produk",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: "Toko",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: "Kategori",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// ====================================================================
//  DASHBOARD HOME UI — BERGAYA MARKETPLACE
// ====================================================================

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  bool showStoreProducts = true;

  final String defaultImageUrl = "https://learncode.biz.id/images/no-image.png";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _filterProducts(_searchController.text));
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);

    List<dynamic> data = showStoreProducts
        ? await _productService.getStoreProducts()
        : await _productService.getProducts();

    if (!mounted) return;
    setState(() {
      products = data;
      filteredProducts = data;
      isLoading = false;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = query.isEmpty
          ? products
          : products
              .where((p) => (p['nama_produk'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
    });
  }

  void _toggleProductType(bool store) {
    setState(() => showStoreProducts = store);
    fetchProducts();
  }

  // ====================================================================
  //  PRODUCT CARD
  // ====================================================================

  Widget _productCard(dynamic item) {
    final price = int.tryParse(item["harga"]?.toString() ?? "0") ?? 0;
    final stock = int.tryParse(item["stok"]?.toString() ?? "0") ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailProductScreen(
              idProduk: item["id_produk"].toString(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: Column(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                defaultImageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // TEXT
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["nama_produk"] ?? "-",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp $price",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Stok: $stock",
                    style: TextStyle(
                      fontSize: 12,
                      color: stock < 10 ? Colors.red : Colors.grey.shade600,
                      fontWeight: stock < 10 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ====================================================================
  //  BUILD UI DASHBOARD
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: fetchProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER ====================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Text(
                      "Marketplace",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // SEARCH ====================================================
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari produk...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // TOGGLE PRODUK ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleProductType(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: showStoreProducts ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.shade400,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Produk Toko",
                            style: TextStyle(
                              color: showStoreProducts ? Colors.white : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleProductType(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: !showStoreProducts ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.shade400,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Semua Produk",
                            style: TextStyle(
                              color: !showStoreProducts ? Colors.white : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // GRID PRODUK ==============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : filteredProducts.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Text("Tidak ada produk"),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.70,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (_, i) =>
                                _productCard(filteredProducts[i]),
                          ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
