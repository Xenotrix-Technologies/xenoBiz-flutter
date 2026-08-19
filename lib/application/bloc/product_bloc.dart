import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final String? query;
  final String? category;
  final String? stockFilter;
  final String? sortBy;

  const FetchProductsEvent({
    this.query,
    this.category,
    this.stockFilter,
    this.sortBy,
  });

  @override
  List<Object?> get props => [query, category, stockFilter, sortBy];
}

class CreateProductEvent extends ProductEvent {
  final ProductEntity product;
  const CreateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final ProductEntity product;
  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class AdjustStockEvent extends ProductEvent {
  final String productId;
  final int change;
  final String reason;

  const AdjustStockEvent({
    required this.productId,
    required this.change,
    required this.reason,
  });

  @override
  List<Object?> get props => [productId, change, reason];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;
  final bool permanent;

  const DeleteProductEvent({
    required this.productId,
    this.permanent = false,
  });

  @override
  List<Object?> get props => [productId, permanent];
}

class FetchStockMovementsEvent extends ProductEvent {
  final String productId;
  const FetchStockMovementsEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitialState extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductsLoadedState extends ProductState {
  final List<ProductEntity> allProducts;
  final List<ProductEntity> filteredProducts;
  final String searchQuery;
  final String selectedStockFilter;
  final String selectedCategory;
  final String sortBy;
  final List<InventoryMovement> movements;

  const ProductsLoadedState({
    required this.allProducts,
    required this.filteredProducts,
    this.searchQuery = '',
    this.selectedStockFilter = 'All',
    this.selectedCategory = 'All',
    this.sortBy = 'Name',
    this.movements = const [],
  });

  // Backward compatibility alias for single-list widgets
  List<ProductEntity> get products => filteredProducts;

  List<String> get categories {
    final set = <String>{'All'};
    for (final p in allProducts) {
      if (p.isActive && p.category.isNotEmpty) set.add(p.category);
    }
    return set.toList();
  }

  int get totalProducts => allProducts.where((p) => p.isActive).length;

  int get totalItems => allProducts
      .where((p) => p.isActive)
      .fold(0, (sum, p) => sum + p.stockQuantity);

  int get lowStockCount => allProducts
      .where((p) => p.isActive && p.isLowStock)
      .length;

  int get outOfStockCount => allProducts
      .where((p) => p.isActive && p.isOutOfStock)
      .length;

  int get healthyCount => allProducts
      .where((p) => p.isActive && p.isHealthy)
      .length;

  double get stockValue => allProducts
      .where((p) => p.isActive)
      .fold(0.0, (sum, p) => sum + (p.stockQuantity * (p.purchasePrice > 0 ? p.purchasePrice : p.sellingPrice)));

  double get potentialSalesValue => allProducts
      .where((p) => p.isActive)
      .fold(0.0, (sum, p) => sum + (p.stockQuantity * p.sellingPrice));

  @override
  List<Object?> get props => [
        allProducts,
        filteredProducts,
        searchQuery,
        selectedStockFilter,
        selectedCategory,
        sortBy,
        movements,
      ];
}

class ProductErrorState extends ProductState {
  final String message;
  const ProductErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitialState()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<AdjustStockEvent>(_onAdjustStock);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<FetchStockMovementsEvent>(_onFetchStockMovements);
  }

  List<ProductEntity> _applyFilterAndSort(
    List<ProductEntity> source, {
    required String query,
    required String stockFilter,
    required String category,
    required String sortBy,
  }) {
    List<ProductEntity> list = source;

    if (stockFilter == 'Inactive') {
      list = list.where((p) => !p.isActive).toList();
    } else {
      list = list.where((p) => p.isActive).toList();

      if (stockFilter == 'In Stock') {
        list = list.where((p) => p.isHealthy).toList();
      } else if (stockFilter == 'Low Stock') {
        list = list.where((p) => p.isLowStock).toList();
      } else if (stockFilter == 'Out of Stock') {
        list = list.where((p) => p.isOutOfStock).toList();
      }
    }

    if (category != 'All' && category.isNotEmpty) {
      list = list.where((p) => p.category == category).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.barcode.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }

    switch (sortBy) {
      case 'Stock Quantity':
        list.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case 'Price':
        list.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'Low Stock First':
        list.sort((a, b) {
          if (a.isOutOfStock != b.isOutOfStock) return a.isOutOfStock ? -1 : 1;
          if (a.isLowStock != b.isLowStock) return a.isLowStock ? -1 : 1;
          return a.stockQuantity.compareTo(b.stockQuantity);
        });
        break;
      case 'Recently Updated':
        list.sort((a, b) {
          final tA = a.updatedAt ?? a.createdAt;
          final tB = b.updatedAt ?? b.createdAt;
          return tB.compareTo(tA);
        });
        break;
      case 'Name':
      default:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }

    return list;
  }

  Future<void> _onFetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    final currentState = state;
    String currentQuery = event.query ?? (currentState is ProductsLoadedState ? currentState.searchQuery : '');
    String currentStockFilter = event.stockFilter ?? (currentState is ProductsLoadedState ? currentState.selectedStockFilter : 'All');
    String currentCategory = event.category ?? (currentState is ProductsLoadedState ? currentState.selectedCategory : 'All');
    String currentSortBy = event.sortBy ?? (currentState is ProductsLoadedState ? currentState.sortBy : 'Name');
    List<InventoryMovement> currentMovements = currentState is ProductsLoadedState ? currentState.movements : const [];

    if (currentState is! ProductsLoadedState) {
      emit(ProductLoadingState());
    }

    try {
      final allProducts = await productRepository.getProducts();
      final filtered = _applyFilterAndSort(
        allProducts,
        query: currentQuery,
        stockFilter: currentStockFilter,
        category: currentCategory,
        sortBy: currentSortBy,
      );

      emit(ProductsLoadedState(
        allProducts: allProducts,
        filteredProducts: filtered,
        searchQuery: currentQuery,
        selectedStockFilter: currentStockFilter,
        selectedCategory: currentCategory,
        sortBy: currentSortBy,
        movements: currentMovements,
      ));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
      CreateProductEvent event, Emitter<ProductState> emit) async {
    try {
      await productRepository.createProduct(event.product);
      add(const FetchProductsEvent());
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProductEvent event, Emitter<ProductState> emit) async {
    try {
      await productRepository.updateProduct(event.product);
      add(const FetchProductsEvent());
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onAdjustStock(
      AdjustStockEvent event, Emitter<ProductState> emit) async {
    try {
      await productRepository.adjustStock(event.productId, event.change, event.reason);
      add(FetchStockMovementsEvent(event.productId));
      add(const FetchProductsEvent());
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProductEvent event, Emitter<ProductState> emit) async {
    try {
      await productRepository.deleteProduct(event.productId, permanent: event.permanent);
      add(const FetchProductsEvent());
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onFetchStockMovements(
      FetchStockMovementsEvent event, Emitter<ProductState> emit) async {
    try {
      final movements = await productRepository.getStockMovements(event.productId);
      if (state is ProductsLoadedState) {
        final current = state as ProductsLoadedState;
        emit(ProductsLoadedState(
          allProducts: current.allProducts,
          filteredProducts: current.filteredProducts,
          searchQuery: current.searchQuery,
          selectedStockFilter: current.selectedStockFilter,
          selectedCategory: current.selectedCategory,
          sortBy: current.sortBy,
          movements: movements,
        ));
      }
    } catch (_) {}
  }
}
