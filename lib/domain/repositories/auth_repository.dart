import '../entities/business_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<BusinessEntity?> getBusinessProfile();
  Future<UserEntity> login(String emailOrPhone, String password);
  Future<UserEntity> register(String name, String email, String phone, String password);
  Future<BusinessEntity> setupBusiness(BusinessEntity business);
  Future<void> logout();
  Future<bool> isAuthenticated();
}
