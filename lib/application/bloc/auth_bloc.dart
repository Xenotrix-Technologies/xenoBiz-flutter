import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/network/network_checker.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStartedEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;

  const LoginSubmittedEvent({required this.emailOrPhone, required this.password});

  @override
  List<Object?> get props => [emailOrPhone, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? shopName;
  final String? address;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? gstin;
  final String? businessType;

  const RegisterSubmittedEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.shopName,
    this.address,
    this.city,
    this.state,
    this.pinCode,
    this.gstin,
    this.businessType,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        shopName,
        address,
        city,
        state,
        pinCode,
        gstin,
        businessType,
      ];
}

class BusinessSetupSubmittedEvent extends AuthEvent {
  final BusinessEntity business;

  const BusinessSetupSubmittedEvent(this.business);

  @override
  List<Object?> get props => [business];
}

class UpdateBusinessProfileEvent extends AuthEvent {
  final BusinessEntity business;

  const UpdateBusinessProfileEvent(this.business);

  @override
  List<Object?> get props => [business];
}

class UpdateUserCredentialsEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;

  const UpdateUserCredentialsEvent({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

class UpdatePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class CompleteTrialOnboardingEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  final BusinessEntity? business;

  const AuthenticatedState({required this.user, this.business});

  @override
  List<Object?> get props => [user, business];
}



class RegistrationSuccessState extends AuthState {
  final UserEntity user;
  final BusinessEntity? business;

  const RegistrationSuccessState({required this.user, this.business});

  @override
  List<Object?> get props => [user, business];
}

class TrialOnboardingRequiredState extends AuthState {
  final UserEntity user;
  final BusinessEntity? business;

  const TrialOnboardingRequiredState({required this.user, this.business});

  @override
  List<Object?> get props => [user, business];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<AppStartedEvent>(_onAppStarted);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<BusinessSetupSubmittedEvent>(_onBusinessSetupSubmitted);
    on<UpdateBusinessProfileEvent>(_onUpdateBusinessProfile);
    on<UpdateUserCredentialsEvent>(_onUpdateUserCredentials);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<CompleteTrialOnboardingEvent>(_onCompleteTrialOnboarding);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onAppStarted(AppStartedEvent event, Emitter<AuthState> emit) async {
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (isAuth) {
        final user = await authRepository.getCurrentUser();
        final business = await authRepository.getBusinessProfile();
        if (user != null) {
          final onboardingDone = await authRepository.isTrialOnboardingCompleted();
          if (onboardingDone) {
            emit(AuthenticatedState(user: user, business: business));
          } else {
            emit(TrialOnboardingRequiredState(user: user, business: business));
          }
          return;
        }
      }
      emit(UnauthenticatedState());
    } catch (e) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmittedEvent event, Emitter<AuthState> emit) async {
    final isConnected = await NetworkChecker().isConnected;
    if (!isConnected) {
      emit(AuthErrorState('No internet connection'));
      return;
    }
    emit(AuthLoadingState());
    try {
      final user = await authRepository.login(event.emailOrPhone, event.password);
      final business = await authRepository.getBusinessProfile();
      final onboardingDone = await authRepository.isTrialOnboardingCompleted();
      if (onboardingDone) {
        emit(AuthenticatedState(user: user, business: business));
      } else {
        emit(TrialOnboardingRequiredState(user: user, business: business));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCompleteTrialOnboarding(
      CompleteTrialOnboardingEvent event, Emitter<AuthState> emit) async {
    try {
      await authRepository.setTrialOnboardingCompleted(true);
      final user = await authRepository.getCurrentUser();
      final business = await authRepository.getBusinessProfile();
      if (user != null) {
        emit(AuthenticatedState(user: user, business: business));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmittedEvent event, Emitter<AuthState> emit) async {
    final isConnected = await NetworkChecker().isConnected;
    if (!isConnected) {
      emit(AuthErrorState('No internet connection'));
      return;
    }
    emit(AuthLoadingState());
    try {
      final user = await authRepository.register(event.name, event.email, event.phone, event.password);

      final shopName = (event.shopName != null && event.shopName!.trim().isNotEmpty)
          ? event.shopName!.trim()
          : (event.name.isNotEmpty ? '${event.name}\'s Store' : 'My Store');

      final addressComponents = [event.address, event.city, event.state, event.pinCode]
          .where((s) => s != null && s.trim().isNotEmpty)
          .map((s) => s!.trim())
          .toList();
      final fullAddress = addressComponents.isNotEmpty ? addressComponents.join(', ') : '';

      final business = BusinessEntity(
        id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
        name: shopName,
        email: event.email.trim().isNotEmpty ? event.email.trim() : null,
        phone: event.phone.trim(),
        address: fullAddress,
        gstin: event.gstin?.trim() ?? '',
        category: event.businessType ?? 'Retail Store',
        currency: '₹',
        createdAt: DateTime.now(),
      );

      final savedBusiness = await authRepository.setupBusiness(business);
      emit(RegistrationSuccessState(user: user, business: savedBusiness));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onBusinessSetupSubmitted(
      BusinessSetupSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final savedBusiness = await authRepository.setupBusiness(event.business);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthenticatedState(user: user, business: savedBusiness));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateBusinessProfile(
      UpdateBusinessProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final updatedBiz = await authRepository.updateBusinessProfile(event.business);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthenticatedState(user: user, business: updatedBiz));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateUserCredentials(
      UpdateUserCredentialsEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final updatedUser = await authRepository.updateUserCredentials(
        name: event.name,
        email: event.email,
        phone: event.phone,
      );
      final business = await authRepository.getBusinessProfile();
      emit(AuthenticatedState(user: updatedUser, business: business));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdatePassword(
      UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await authRepository.updatePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      final user = await authRepository.getCurrentUser();
      final business = await authRepository.getBusinessProfile();
      if (user != null) {
        emit(AuthenticatedState(user: user, business: business));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(UnauthenticatedState());
  }

}
