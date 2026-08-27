import 'package:dio/dio.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../database/app_database.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final AppDatabase db;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.dioClient,
    required this.db,
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

        if (bizData != null) {
          await db.putKeyValue('biz_id', bizData['id']?.toString() ?? '');
          await db.putKeyValue('biz_name', bizData['name']?.toString() ?? '');
          await db.putKeyValue('biz_email', bizData['email']?.toString() ?? '');
          await db.putKeyValue('biz_gstin', (bizData['gstin'] ?? bizData['tax_number'])?.toString() ?? '');
          await db.putKeyValue('biz_category', (bizData['category'] ?? bizData['business_type'] ?? '').toString());
          await db.putKeyValue('biz_currency', (bizData['currency'] ?? '₹').toString());
          await db.putKeyValue('biz_phone', bizData['phone']?.toString() ?? '');
          await db.putKeyValue('biz_address', bizData['address']?.toString() ?? '');
          await db.putKeyValue('biz_logoUrl', (bizData['logoUrl'] ?? bizData['logo'])?.toString() ?? '');
        } else {
          await db.clearKeyValuesWithPrefix('biz_');
        }

        return user;
      }
    } catch (e) {
      final userId = await db.getKeyValue('auth_userId');
      if (userId != null && userId.isNotEmpty) {
        return UserEntity(
          id: userId,
          name: await db.getKeyValue('auth_userName') ?? 'Business Owner',
          email: await db.getKeyValue('auth_userEmail') ?? 'owner@xenobiz.com',
          phone: await db.getKeyValue('auth_userPhone') ?? '+91 98470 11223',
          businessId: await db.getKeyValue('auth_businessId') ?? 'biz_101',
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

    final id = await db.getKeyValue('biz_id');
    final name = await db.getKeyValue('biz_name');
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      return null;
    }

    return BusinessEntity(
      id: id,
      name: name,
      email: await db.getKeyValue('biz_email'),
      gstin: await db.getKeyValue('biz_gstin'),
      category: await db.getKeyValue('biz_category') ?? '',
      currency: await db.getKeyValue('biz_currency') ?? '₹',
      phone: await db.getKeyValue('biz_phone') ?? '',
      address: await db.getKeyValue('biz_address') ?? '',
      logoUrl: await db.getKeyValue('biz_logoUrl'),
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

        await db.putKeyValue('auth_userId', user.id);
        await db.putKeyValue('auth_userName', user.name);
        await db.putKeyValue('auth_userEmail', user.email);
        await db.putKeyValue('auth_userPhone', user.phone);
        if (user.businessId != null) {
          await db.putKeyValue('auth_businessId', user.businessId!);
        } else {
          await db.deleteKeyValue('auth_businessId');
        }

        if (bizData != null) {
          await db.putKeyValue('biz_id', bizData['id']?.toString() ?? '');
          await db.putKeyValue('biz_name', bizData['name']?.toString() ?? '');
          await db.putKeyValue('biz_email', bizData['email']?.toString() ?? '');
          await db.putKeyValue('biz_gstin', (bizData['gstin'] ?? bizData['tax_number'])?.toString() ?? '');
          await db.putKeyValue('biz_category', (bizData['category'] ?? bizData['business_type'] ?? 'Retail Store').toString());
          await db.putKeyValue('biz_currency', (bizData['currency'] ?? '₹').toString());
          await db.putKeyValue('biz_phone', bizData['phone']?.toString() ?? '');
          await db.putKeyValue('biz_address', bizData['address']?.toString() ?? '');
        } else {
          await db.clearKeyValuesWithPrefix('biz_');
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

        await db.putKeyValue('auth_userId', user.id);
        await db.putKeyValue('auth_userName', user.name);
        await db.putKeyValue('auth_userEmail', user.email);
        await db.putKeyValue('auth_userPhone', user.phone);

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response == null) {
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

        await db.putKeyValue('auth_userId', user.id);
        await db.putKeyValue('auth_userName', user.name);
        await db.putKeyValue('auth_userEmail', user.email);
        await db.putKeyValue('auth_userPhone', user.phone);

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

        await db.putKeyValue('biz_id', saved.id);
        await db.putKeyValue('biz_name', saved.name);
        await db.putKeyValue('biz_email', saved.email ?? '');
        await db.putKeyValue('biz_gstin', saved.gstin ?? '');
        await db.putKeyValue('biz_category', saved.category);
        await db.putKeyValue('biz_currency', saved.currency);
        await db.putKeyValue('biz_phone', saved.phone);
        await db.putKeyValue('biz_address', saved.address);

        return saved;
      }
    } catch (_) {}

    await db.putKeyValue('biz_id', business.id);
    await db.putKeyValue('biz_name', business.name);
    await db.putKeyValue('biz_email', business.email ?? '');
    await db.putKeyValue('biz_gstin', business.gstin ?? '');
    await db.putKeyValue('biz_category', business.category);
    await db.putKeyValue('biz_currency', business.currency);
    await db.putKeyValue('biz_phone', business.phone);
    await db.putKeyValue('biz_address', business.address);

    return business;
  }

  @override
  Future<BusinessEntity> updateBusinessProfile(BusinessEntity business) async {
    await db.putKeyValue('biz_id', business.id);
    await db.putKeyValue('biz_name', business.name);
    await db.putKeyValue('biz_email', business.email ?? '');
    await db.putKeyValue('biz_gstin', business.gstin ?? '');
    await db.putKeyValue('biz_category', business.category);
    await db.putKeyValue('biz_currency', business.currency);
    await db.putKeyValue('biz_phone', business.phone);
    await db.putKeyValue('biz_address', business.address);
    if (business.logoUrl != null && business.logoUrl!.isNotEmpty) {
      await db.putKeyValue('biz_logoUrl', business.logoUrl!);
    } else {
      await db.deleteKeyValue('biz_logoUrl');
    }

    try {
      final response = await dioClient.dio.put(
        ApiEndpoints.profile,
        data: {
          'id': business.id,
          'name': business.name,
          'phone': business.phone,
          'email': business.email,
          'address': business.address,
          'gstin': business.gstin,
          'category': business.category,
          'currency': business.currency,
          'logoUrl': business.logoUrl,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final b = response.data['data'] ?? {};
        final synced = BusinessEntity(
          id: (b['id'] ?? business.id).toString(),
          name: (b['name'] ?? business.name).toString(),
          email: b['email']?.toString() ?? business.email,
          gstin: (b['gstin'] ?? b['tax_number'])?.toString() ?? business.gstin,
          category: (b['category'] ?? b['business_type'] ?? business.category).toString(),
          currency: (b['currency'] ?? business.currency).toString(),
          phone: (b['phone'] ?? business.phone).toString(),
          address: (b['address'] ?? business.address).toString(),
          logoUrl: (b['logoUrl'] ?? b['logo'] ?? business.logoUrl)?.toString(),
          createdAt: business.createdAt,
        );
        return synced;
      }
    } catch (_) {}

    return business;
  }

  @override
  Future<UserEntity> updateUserCredentials({
    required String name,
    required String email,
    required String phone,
  }) async {
    await db.putKeyValue('auth_userName', name);
    await db.putKeyValue('auth_userEmail', email);
    await db.putKeyValue('auth_userPhone', phone);

    final userId = await db.getKeyValue('auth_userId') ?? '';
    final businessId = await db.getKeyValue('auth_businessId');

    final localUser = UserEntity(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      businessId: businessId,
      role: 'OWNER',
      createdAt: DateTime.now(),
    );

    try {
      final response = await dioClient.dio.put(
        ApiEndpoints.profile,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final u = response.data['data']['user'] ?? response.data['data'] ?? {};
        return UserEntity(
          id: (u['id'] ?? userId).toString(),
          name: (u['name'] ?? name).toString(),
          email: (u['email'] ?? email).toString(),
          phone: (u['phone'] ?? phone).toString(),
          businessId: businessId,
          role: (u['role'] ?? 'OWNER').toString(),
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}

    return localUser;
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.data != null && response.data['success'] == false) {
        throw Exception(response.data['message'] ?? 'Failed to update password');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to update password on backend';
      throw Exception(msg);
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.clearTokens();
    await db.clearKeyValuesWithPrefix('auth_');
    await db.clearKeyValuesWithPrefix('biz_');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> isTrialOnboardingCompleted() async {
    final val = await db.getKeyValue('auth_trialOnboardingCompleted');
    return val == 'true';
  }

  @override
  Future<void> setTrialOnboardingCompleted(bool completed) async {
    await db.putKeyValue('auth_trialOnboardingCompleted', completed.toString());
  }
}
