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
        final userData = response.data['data']['user'] ?? {};
        final bizData = response.data['data']['business'];

        final user = UserEntity(
          id: (userData['id'] ?? '').toString(),
          name: (userData['name'] ?? userData['full_name'] ?? 'Business Owner').toString(),
          email: (userData['email'] ?? '').toString(),
          phone: (userData['phone'] ?? '').toString(),
          businessId: bizData != null ? bizData['id']?.toString() : null,
          role: (userData['role'] ?? 'OWNER').toString(),
          createdAt: DateTime.tryParse(userData['createdAt']?.toString() ?? userData['created_at']?.toString() ?? '') ?? DateTime.now(),
        );

        final boxBiz = hiveService.getBox(HiveService.boxBusiness);
        if (bizData != null) {
          await boxBiz.put('id', bizData['id']?.toString() ?? '');
          await boxBiz.put('name', bizData['name']?.toString() ?? '');
          await boxBiz.put('email', bizData['email']?.toString());
          await boxBiz.put('gstin', (bizData['gstin'] ?? bizData['tax_number'])?.toString());
          await boxBiz.put('category', (bizData['category'] ?? bizData['business_type'] ?? '').toString());
          await boxBiz.put('currency', (bizData['currency'] ?? '₹').toString());
          await boxBiz.put('phone', bizData['phone']?.toString() ?? '');
          await boxBiz.put('address', bizData['address']?.toString() ?? '');
          await boxBiz.put('logoUrl', (bizData['logoUrl'] ?? bizData['logo'])?.toString());
        } else {
          await boxBiz.clear();
        }

        return user;
      }
    } catch (e) {
      // Fallback to cached Hive user if offline
      final box = hiveService.getBox(HiveService.boxAuth);
      final userId = box.get('userId')?.toString();
      if (userId != null && userId.isNotEmpty) {
        return UserEntity(
          id: userId,
          name: box.get('userName')?.toString() ?? 'Business Owner',
          email: box.get('userEmail')?.toString() ?? 'owner@xenobiz.com',
          phone: box.get('userPhone')?.toString() ?? '+91 98470 11223',
          businessId: box.get('businessId')?.toString() ?? 'biz_101',
          role: 'OWNER',
          createdAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  @override
  Future<BusinessEntity?> getBusinessProfile() async {
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await dioClient.dio.get(ApiEndpoints.me);
        if (response.data != null && response.data['success'] == true) {
          final bizData = response.data['data']['business'];
          if (bizData != null) {
            return BusinessEntity(
              id: (bizData['id'] ?? '').toString(),
              name: (bizData['name'] ?? '').toString(),
              email: bizData['email']?.toString(),
              gstin: (bizData['gstin'] ?? bizData['tax_number'])?.toString(),
              category: (bizData['category'] ?? bizData['business_type'] ?? '').toString(),
              currency: (bizData['currency'] ?? '₹').toString(),
              phone: bizData['phone']?.toString() ?? '',
              address: bizData['address']?.toString() ?? '',
              logoUrl: (bizData['logoUrl'] ?? bizData['logo'])?.toString(),
              createdAt: DateTime.tryParse(bizData['createdAt']?.toString() ?? bizData['created_at']?.toString() ?? '') ?? DateTime.now(),
            );
          } else {
            return null;
          }
        }
      } catch (_) {}
    }

    final box = hiveService.getBox(HiveService.boxBusiness);
    final id = box.get('id')?.toString();
    final name = box.get('name')?.toString();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      return null;
    }

    return BusinessEntity(
      id: id,
      name: name,
      email: box.get('email')?.toString(),
      gstin: box.get('gstin')?.toString(),
      category: box.get('category')?.toString() ?? '',
      currency: box.get('currency')?.toString() ?? '₹',
      phone: box.get('phone')?.toString() ?? '',
      address: box.get('address')?.toString() ?? '',
      logoUrl: box.get('logoUrl')?.toString(),
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
        final token = response.data['data']['token']?.toString();
        final userData = response.data['data']['user'] ?? {};
        final bizData = response.data['data']['business'];

        if (token != null) {
          await secureStorage.saveAccessToken(token);
        }

        final user = UserEntity(
          id: (userData['id'] ?? '').toString(),
          name: (userData['name'] ?? userData['full_name'] ?? 'Business Owner').toString(),
          email: (userData['email'] ?? emailOrPhone).toString(),
          phone: (userData['phone'] ?? emailOrPhone).toString(),
          businessId: bizData != null ? bizData['id']?.toString() : null,
          role: (userData['role'] ?? 'OWNER').toString(),
          createdAt: DateTime.tryParse(userData['createdAt']?.toString() ?? userData['created_at']?.toString() ?? '') ?? DateTime.now(),
        );

        final boxAuth = hiveService.getBox(HiveService.boxAuth);
        await boxAuth.put('userId', user.id);
        await boxAuth.put('userName', user.name);
        await boxAuth.put('userEmail', user.email);
        await boxAuth.put('userPhone', user.phone);
        if (user.businessId != null) {
          await boxAuth.put('businessId', user.businessId);
        } else {
          await boxAuth.delete('businessId');
        }

        final boxBiz = hiveService.getBox(HiveService.boxBusiness);
        if (bizData != null) {
          await boxBiz.put('id', bizData['id']?.toString() ?? '');
          await boxBiz.put('name', bizData['name']?.toString() ?? '');
          await boxBiz.put('email', bizData['email']?.toString());
          await boxBiz.put('gstin', (bizData['gstin'] ?? bizData['tax_number'])?.toString());
          await boxBiz.put('category', (bizData['category'] ?? bizData['business_type'] ?? 'Retail Store').toString());
          await boxBiz.put('currency', (bizData['currency'] ?? '₹').toString());
          await boxBiz.put('phone', bizData['phone']?.toString() ?? '');
          await boxBiz.put('address', bizData['address']?.toString() ?? '');
        } else {
          await boxBiz.clear();
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
          'shopName': name,
          'ownerName': name,
          'email': email,
          'phone': phone,
          'emailOrPhone': email.isNotEmpty ? email : phone,
          'password': password,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final token = response.data['data']['token']?.toString();
        final userData = response.data['data']['user'] ?? {};

        if (token != null) {
          await secureStorage.saveAccessToken(token);
        }

        final user = UserEntity(
          id: (userData['id'] ?? '').toString(),
          name: (userData['name'] ?? userData['full_name'] ?? name).toString(),
          email: (userData['email'] ?? email).toString(),
          phone: (userData['phone'] ?? phone).toString(),
          businessId: null,
          role: (userData['role'] ?? 'OWNER').toString(),
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
      if (e.response == null) {
        // Offline / server unreachable fallback
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        final user = UserEntity(
          id: userId,
          name: name.isNotEmpty ? name : 'Merchant',
          email: email.isNotEmpty ? email : (phone.isNotEmpty ? '$phone@xenobiz.local' : 'merchant@xenobiz.local'),
          phone: phone,
          businessId: null,
          role: 'OWNER',
          createdAt: DateTime.now(),
        );

        final offlineToken = 'offline_token_$userId';
        await secureStorage.saveAccessToken(offlineToken);

        final boxAuth = hiveService.getBox(HiveService.boxAuth);
        await boxAuth.put('userId', user.id);
        await boxAuth.put('userName', user.name);
        await boxAuth.put('userEmail', user.email);
        await boxAuth.put('userPhone', user.phone);

        return user;
      }

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
        final b = response.data['data'] ?? {};
        final saved = BusinessEntity(
          id: (b['id'] ?? business.id).toString(),
          name: (b['name'] ?? business.name).toString(),
          email: b['email']?.toString() ?? business.email,
          gstin: (b['gstin'] ?? b['tax_number'])?.toString() ?? business.gstin,
          category: (b['category'] ?? b['business_type'] ?? business.category).toString(),
          currency: (b['currency'] ?? '₹').toString(),
          phone: (b['phone'] ?? business.phone).toString(),
          address: (b['address'] ?? business.address).toString(),
          createdAt: DateTime.tryParse(b['createdAt']?.toString() ?? b['created_at']?.toString() ?? '') ?? DateTime.now(),
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
