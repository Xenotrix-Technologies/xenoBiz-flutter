import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../widgets/app_card.dart';

class AddProductsPage extends StatefulWidget {
  final List<InvoiceItemEntity> initialItems;

  const AddProductsPage({
    super.key,
    required this.initialItems,
  });

  @override
  State<AddProductsPage> createState() => _AddProductsPageState();
}

class _AddProductsPageState extends State<AddProductsPage>
    with WidgetsBindingObserver {
  late List<InvoiceItemEntity> _cartItems;
  final TextEditingController _searchCtrl = TextEditingController();
  List<ProductEntity> _allProducts = [];

  // Barcode Scanner controls & state
  late final MobileScannerController _scannerController;
  bool _isCameraOn = true;
  bool _isFlashOn = false;
  DateTime? _lastScanTime;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cartItems = List.from(widget.initialItems);
    _loadProducts();

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      torchEnabled: false,
      autoStart: true,
    );
  }

  void _loadProducts() async {
    try {
      final products = await getIt<ProductRepository>().getProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
        });
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed && _isCameraOn) {
      _scannerController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
      if (_isCameraOn) {
        _scannerController.start();
      } else {
        _scannerController.stop();
      }
    });
  }

  void _toggleFlash() async {
    await _scannerController.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final now = DateTime.now();
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code == null || code.trim().isEmpty) continue;

      if (_lastScannedCode == code &&
          _lastScanTime != null &&
          now.difference(_lastScanTime!) < const Duration(milliseconds: 1500)) {
        continue;
      }

      _lastScanTime = now;
      _lastScannedCode = code;

      final cleanCode = code.trim().toLowerCase();
      final matchedProduct = _allProducts.cast<ProductEntity?>().firstWhere(
        (p) =>
            p != null &&
            (p.sku.trim().toLowerCase() == cleanCode ||
                p.id.trim().toLowerCase() == cleanCode ||
                p.name.trim().toLowerCase() == cleanCode),
        orElse: () => null,
      );

      if (matchedProduct != null) {
        _addProductToCart(matchedProduct);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found matching barcode: $code'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      break;
    }
  }

  List<ProductEntity> get _searchResults {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _allProducts.where((p) {
      final nameMatch = p.name.toLowerCase().contains(query);
      final skuMatch = p.sku.toLowerCase().contains(query);
      final categoryMatch = p.category.toLowerCase().contains(query);
      return nameMatch || skuMatch || categoryMatch;
    }).toList();
  }

  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _taxTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get _grandTotal => _subtotal + _taxTotal;
  int get _totalItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void _addProductToCart(ProductEntity prod) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.productId == prod.id);
    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${prod.name} already added'),
          backgroundColor: AppColors.darkBlueText,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _cartItems.add(
          InvoiceItemEntity(
            productId: prod.id,
            productName: prod.name,
            sku: prod.sku,
            quantity: 1,
            unitPrice: prod.sellingPrice,
            taxPercentage: 18.0,
          ),
        );
      });
      _searchCtrl.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final currentQty = _cartItems[index].quantity;
      final newQty = currentQty + delta;
      if (newQty <= 0) {
        final removedName = _cartItems[index].productName;
        _cartItems.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$removedName removed'),
            backgroundColor: AppColors.darkBlueText,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQty);
      }
    });
  }

  void _removeCartItem(int index) {
    final removedName = _cartItems[index].productName;
    setState(() {
      _cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removedName removed'),
        backgroundColor: AppColors.darkBlueText,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editQuantityDialog(int index) {
    final item = _cartItems[index];
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        title: Text(
          'Edit Quantity - ${item.productName}',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface),
        ),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newQty = int.tryParse(qtyCtrl.text.trim()) ?? item.quantity;
              if (newQty > 0) {
                setState(() {
                  _cartItems[index] = item.copyWith(quantity: newQty);
                });
              } else {
                _removeCartItem(index);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onSaveCart() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one product'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.pop(context, _cartItems);
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchResults;
    final isSearching = _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context, widget.initialItems),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMedium),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        border:
                            Border.all(color: AppColors.surfaceContainerHigh),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Add Products',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // 1. BARCODE SCANNER CAMERA PREVIEW (AT TOP OF SCREEN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildScannerHeader(),
            ),
            const SizedBox(height: 12),

            // 2. PRODUCT SEARCH FIELD (DIRECTLY UNDER SCANNER)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        border:
                            Border.all(color: AppColors.surfaceContainerHigh),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search product name or SKU...',
                          hintStyle: const TextStyle(
                              color: AppColors.outline, fontSize: 14),
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.outline, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 18, color: AppColors.outline),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Camera Toggle Quick Button
                  InkWell(
                    onTap: _toggleCamera,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMedium),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isCameraOn
                            ? AppColors.primary
                            : AppColors.surfaceContainerHigh,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isCameraOn
                            ? Icons.qr_code_scanner
                            : Icons.videocam_off_outlined,
                        color: _isCameraOn ? Colors.white : AppColors.outline,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. MAIN CONTENT AREA (SEARCH RESULTS OR CART LIST)
            Expanded(
              child: isSearching
                  ? _buildSearchResultsList(searchResults)
                  : _buildCartList(),
            ),

            // 4. STICKY BOTTOM SUMMARY BAR & SAVE BUTTON
            _buildStickySummaryBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerHeader() {
    if (!_isCameraOn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.videocam_off_outlined,
                  color: AppColors.outline, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Camera Scanner OFF',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Tap to enable camera barcode scanning',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _toggleCamera,
              icon: const Icon(Icons.videocam_rounded, size: 16),
              label: const Text('Turn ON',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium - 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Live Scanner View
            MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
              errorBuilder: (context, error) {
                return Container(
                  color: AppColors.surfaceCard,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: AppColors.error, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'Camera unavailable or permission denied',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _scannerController.start(),
                        child: const Text('Retry Camera',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Barcode Scan Box Area
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 220,
              height: 90,
              child: Center(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.primary,
                ),
              ),
            ),

            // Indicator Text
            Positioned(
              bottom: 8,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Align Barcode / SKU in box',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),

            // Controls (Flash & Camera Toggle)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  // Flash Toggle
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleFlash,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isFlashOn
                              ? AppColors.warning
                              : Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _isFlashOn
                                  ? AppColors.warning
                                  : Colors.white30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFlashOn
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: _isFlashOn ? Colors.black : Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isFlashOn ? 'Flash ON' : 'Flash OFF',
                              style: TextStyle(
                                color: _isFlashOn ? Colors.black : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Camera OFF Toggle
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleCamera,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_off,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Cam OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSearchResultsList(List<ProductEntity> searchResults) {
    if (searchResults.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.search_off_outlined,
                  size: 48, color: AppColors.outline),
              SizedBox(height: 12),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Try searching with a different keyword or SKU',
                style: TextStyle(fontSize: 13, color: AppColors.outline),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final prod = searchResults[idx];
        final isInCart = _cartItems.any((item) => item.productId == prod.id);

        return AppCard(
          padding: const EdgeInsets.all(14),
          border: Border.all(
            color: isInCart
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.surfaceContainerHigh,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prod.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          'SKU: ${prod.sku}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${prod.stockQuantity} ${prod.unit} in stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: prod.isLowStock
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${prod.sellingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _addProductToCart(prod),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isInCart
                            ? AppColors.surfaceContainerHigh
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isInCart ? 'Added' : '＋ Add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isInCart ? AppColors.outline : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartList() {
    if (_cartItems.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.blueTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your Cart is Empty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Scan product barcode above or search product name/SKU to add to the invoice.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.outline,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Products (${_cartItems.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _cartItems.clear();
                });
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Cart Items
        ...List.generate(_cartItems.length, (idx) {
          final item = _cartItems[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              border: Border.all(color: AppColors.surfaceContainerHigh),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Product Name & Unit Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${item.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                    ],
                  ),
                  if (item.sku.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${item.sku}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Bottom Controls Row: [- Qty +] and Subtotal / Delete
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => _updateQuantity(idx, -1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(9),
                                bottomLeft: Radius.circular(9),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: const Icon(Icons.remove,
                                    size: 16, color: AppColors.onSurface),
                              ),
                            ),
                            InkWell(
                              onTap: () => _editQuantityDialog(idx),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 40),
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _updateQuantity(idx, 1),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(9),
                                bottomRight: Radius.circular(9),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: const Icon(Icons.add,
                                    size: 16, color: AppColors.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Subtotal Text & Remove Icon
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Sub: ₹${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: AppColors.error),
                        onPressed: () => _removeCartItem(idx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStickySummaryBar() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_totalItemCount Item${_totalItemCount == 1 ? '' : 's'} Selected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                ),
              ),
              Text(
                'Subtotal: ₹${_subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '₹${_grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              onPressed: _onSaveCart,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
