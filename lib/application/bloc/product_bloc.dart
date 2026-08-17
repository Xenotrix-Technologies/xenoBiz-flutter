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
  const FetchProductsEvent({this.query, this.category});

  @override
  List<Object?> get props => [query, category];
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

// States
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitialState extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductsLoadedState extends ProductState {
  final List<ProductEntity> products;
  const ProductsLoadedState(this.products);

  @override
  List<Object?> get props => [products];
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
  }

  Future<void> _onFetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final products = await productRepository.getProducts(
        query: event.query,
        category: event.category,
      );
      emit(ProductsLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
      CreateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      await productRepository.createProduct(event.product);
      final products = await productRepository.getProducts();
      emit(ProductsLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      await productRepository.updateProduct(event.product);
      final products = await productRepository.getProducts();
      emit(ProductsLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onAdjustStock(
      AdjustStockEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      await productRepository.adjustStock(event.productId, event.change, event.reason);
      final products = await productRepository.getProducts();
      emit(ProductsLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }
}
