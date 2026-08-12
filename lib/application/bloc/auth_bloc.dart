import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

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

  const RegisterSubmittedEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

class BusinessSetupSubmittedEvent extends AuthEvent {
  final BusinessEntity business;

  const BusinessSetupSubmittedEvent(this.business);

  @override
  List<Object?> get props => [business];
}

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

class BusinessSetupRequiredState extends AuthState {
  final UserEntity user;

  const BusinessSetupRequiredState(this.user);

  @override
  List<Object?> get props => [user];
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
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onAppStarted(AppStartedEvent event, Emitter<AuthState> emit) async {
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (isAuth) {
        final user = await authRepository.getCurrentUser();
        final business = await authRepository.getBusinessProfile();
        if (user != null) {
          if (business == null) {
            emit(BusinessSetupRequiredState(user));
          } else {
            emit(AuthenticatedState(user: user, business: business));
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
    emit(AuthLoadingState());
    try {
      final user = await authRepository.login(event.emailOrPhone, event.password);
      final business = await authRepository.getBusinessProfile();
      if (business == null) {
        emit(BusinessSetupRequiredState(user));
      } else {
        emit(AuthenticatedState(user: user, business: business));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.register(event.name, event.email, event.phone, event.password);
      emit(BusinessSetupRequiredState(user));
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

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(UnauthenticatedState());
  }
}
