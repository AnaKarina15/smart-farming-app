import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../core/storage/token_storage.dart';

/// Estados posibles del proveedor de autenticacion.
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Proveedor de estado de autenticacion (Provider/ChangeNotifier).
///
/// Mantiene el usuario actual en memoria y notifica a las pantallas
/// cuando cambia el estado de auth (login, logout, registro).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthProvider(this._authService, this._tokenStorage);

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Verifica si hay sesion guardada al iniciar la app.
  Future<void> checkAuthStatus() async {
    final hasSession = await _tokenStorage.hasValidSession();
    if (hasSession) {
      try {
        final user = await _authService.getCurrentUser();
        _currentUser = user;
        await _tokenStorage.saveOfflineProfile(user);
        _status = AuthStatus.authenticated;
      } catch (e) {
        bool isUnauthorized = false;
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          isUnauthorized = true;
        }
        
        if (isUnauthorized) {
          // Sesion expirada o invalida
          await _tokenStorage.clearTokens();
          _status = AuthStatus.unauthenticated;
        } else {
          // Offline o error de red: Restaurar sesion offline
          final userId = await _tokenStorage.getUserId() ?? 'offline_user';
          final role = await _tokenStorage.getRole() ?? 'productor';
          final name = await _tokenStorage.getName() ?? 'Productor Offline';
          final email = await _tokenStorage.getEmail() ?? 'offline@agrofield.com';
          final photo = await _tokenStorage.getPhoto();

          _currentUser = UserModel(
            id: userId,
            nombreCompleto: name,
            email: email,
            role: role,
            activo: true,
            fotoPerfilUrl: photo,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _status = AuthStatus.authenticated;
        }
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Registra un nuevo Pequeno Productor.
  Future<bool> register({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _authService.register(
        nombreCompleto: nombreCompleto,
        email: email,
        telefono: telefono,
        password: password,
      );
      _currentUser = tokens.user;
      await _tokenStorage.saveOfflineProfile(tokens.user);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Inicia sesion con email y password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _authService.login(
        email: email,
        password: password,
      );
      _currentUser = tokens.user;
      await _tokenStorage.saveOfflineProfile(tokens.user);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Cierra sesion.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia el mensaje de error (despues de mostrarlo).
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
