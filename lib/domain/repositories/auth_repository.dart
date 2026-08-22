import '../entities/business_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<BusinessEntity?> getBusinessProfile();
  Future<UserEntity> login(String emailOrPhone, String password);
  Future<UserEntity> register(String name, String email, String phone, String password);
  Future<BusinessEntity> setupBusiness(BusinessEntity business);
  Future<BusinessEntity> updateBusinessProfile(BusinessEntity business);
  Future<UserEntity> updateUserCredentials({required String name, required String email, required String phone});
  Future<void> updatePassword({required String currentPassword, required String newPassword});
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<bool> isTrialOnboardingCompleted();
  Future<void> setTrialOnboardingCompleted(bool completed);
}

