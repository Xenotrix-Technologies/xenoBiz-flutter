import 'package:dio/dio.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';
import '../storage/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.secureStorage,
  });

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await dioClient.dio.get(ApiEndpoints.me);
      if (response.data != null && response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final bizData = response.data['data']['business'];

        final user = UserEntity(
          id: userData['id'],
          name: userData['name'] ?? 'Business Owner',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          businessId: bizData != null ? bizData['id'] : null,
          role: userData['role'] ?? 'OWNER',
          createdAt: DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
        );

        if (bizData != null) {
          final box = hiveService.getBox(HiveService.boxBusiness);
          await box.put('id', bizData['id']);
          await box.put('name', bizData['name']);
          await box.put('email', bizData['email']);
          await box.put('gstin', bizData['gstin']);
          await box.put('category', bizData['category']);
          await box.put('currency', '₹');
          await box.put('phone', bizData['phone']);
          await box.put('address', bizData['address']);
        }

        return user;
      }
    } catch (e) {
      // Fallback to cached Hive user if offline
      final box = hiveService.getBox(HiveService.boxAuth);
      final userId = box.get('userId');
      if (userId != null) {
        return UserEntity(
          id: userId,
          name: box.get('userName', defaultValue: 'Business Owner'),
          email: box.get('userEmail', defaultValue: 'owner@xenobiz.com'),
          phone: box.get('userPhone', defaultValue: '+91 98470 11223'),
          businessId: box.get('businessId', defaultValue: 'biz_101'),
          role: 'OWNER',
          createdAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  @override
  Future<BusinessEntity?> getBusinessProfile() async {
    final box = hiveService.getBox(HiveService.boxBusiness);
    final name = box.get('name');
    if (name == null) {
      // Check backend for business profile if token is available
      final token = await secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        try {
          final response = await dioClient.dio.get(ApiEndpoints.me);
          if (response.data != null && response.data['data']['business'] != null) {
            final b = response.data['data']['business'];
            return BusinessEntity(
              id: b['id'],
              name: b['name'],
              email: b['email'],
              gstin: b['gstin'],
              category: b['category'] ?? 'Retail Store',
              currency: '₹',
              phone: b['phone'] ?? '',
              address: b['address'] ?? '',
              createdAt: DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now(),
            );
          }
        } catch (_) {}
      }
      return null;
    }

    return BusinessEntity(
      id: box.get('id', defaultValue: ''),
      name: name,
      email: box.get('email'),
      gstin: box.get('gstin'),
      category: box.get('category', defaultValue: 'Retail Store'),
      currency: box.get('currency', defaultValue: '₹'),
      phone: box.get('phone', defaultValue: ''),
      address: box.get('address', defaultValue: ''),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserEntity> login(String emailOrPhone, String password) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final token = response.data['data']['token'];
        final userData = response.data['data']['user'];
        final bizData = response.data['data']['business'];

        await secureStorage.saveAccessToken(token);

        final user = UserEntity(
          id: userData['id'],
          name: userData['name'] ?? 'Business Owner',
          email: userData['email'] ?? emailOrPhone,
          phone: userData['phone'] ?? emailOrPhone,
          businessId: bizData != null ? bizData['id'] : null,
          role: userData['role'] ?? 'OWNER',
          createdAt: DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
        );

        final boxAuth = hiveService.getBox(HiveService.boxAuth);
        await boxAuth.put('userId', user.id);
        await boxAuth.put('userName', user.name);
        await boxAuth.put('userEmail', user.email);
        await boxAuth.put('userPhone', user.phone);
        if (user.businessId != null) {
          await boxAuth.put('businessId', user.businessId);
        }

        if (bizData != null) {
          final boxBiz = hiveService.getBox(HiveService.boxBusiness);
          await boxBiz.put('id', bizData['id']);
          await boxBiz.put('name', bizData['name']);
          await boxBiz.put('email', bizData['email']);
          await boxBiz.put('gstin', bizData['gstin']);
          await boxBiz.put('category', bizData['category']);
          await boxBiz.put('currency', '₹');
          await boxBiz.put('phone', bizData['phone']);
          await boxBiz.put('address', bizData['address']);
        }

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Authentication failed';
      throw Exception(msg);
    }
  }

  @override
  Future<UserEntity> register(String name, String email, String phone, String password) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'emailOrPhone': email.isNotEmpty ? email : phone,
          'password': password,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final token = response.data['data']['token'];
        final userData = response.data['data']['user'];

        await secureStorage.saveAccessToken(token);

        final user = UserEntity(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'] ?? email,
          phone: userData['phone'] ?? phone,
          businessId: null,
          role: userData['role'] ?? 'OWNER',
          createdAt: DateTime.now(),
        );

        final boxAuth = hiveService.getBox(HiveService.boxAuth);
        await boxAuth.put('userId', user.id);
        await boxAuth.put('userName', user.name);
        await boxAuth.put('userEmail', user.email);
        await boxAuth.put('userPhone', user.phone);

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Registration failed';
      throw Exception(msg);
    }
  }

  @override
  Future<BusinessEntity> setupBusiness(BusinessEntity business) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.businessSetup,
        data: {
          'name': business.name,
          'phone': business.phone,
          'email': business.email,
          'address': business.address,
          'gstin': business.gstin,
          'category': business.category,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final b = response.data['data'];
        final saved = BusinessEntity(
          id: b['id'],
          name: b['name'],
          email: b['email'],
          gstin: b['gstin'],
          category: b['category'] ?? 'Retail Store',
          currency: '₹',
          phone: b['phone'] ?? business.phone,
          address: b['address'] ?? business.address,
          createdAt: DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now(),
        );

        final box = hiveService.getBox(HiveService.boxBusiness);
        await box.put('id', saved.id);
        await box.put('name', saved.name);
        await box.put('email', saved.email);
        await box.put('gstin', saved.gstin);
        await box.put('category', saved.category);
        await box.put('currency', saved.currency);
        await box.put('phone', saved.phone);
        await box.put('address', saved.address);

        return saved;
      }
    } catch (_) {}

    // Local save fallback
    final box = hiveService.getBox(HiveService.boxBusiness);
    await box.put('id', business.id);
    await box.put('name', business.name);
    await box.put('email', business.email);
    await box.put('gstin', business.gstin);
    await box.put('category', business.category);
    await box.put('currency', business.currency);
    await box.put('phone', business.phone);
    await box.put('address', business.address);

    return business;
  }

  @override
  Future<void> logout() async {
    await secureStorage.clearTokens();
    final boxAuth = hiveService.getBox(HiveService.boxAuth);
    await boxAuth.clear();
    final boxBiz = hiveService.getBox(HiveService.boxBusiness);
    await boxBiz.clear();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
