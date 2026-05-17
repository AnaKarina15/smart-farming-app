import 'package:flutter/material.dart';
import '../models/usuario_admin.dart';
import '../models/stats_admin.dart';
import '../models/lote_admin.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;
  AdminProvider(this._adminService);

  // ─── Estado general ──────────────────────────────────────────────────────
  bool    _cargando = false;
  String? _error;

  bool    get cargando => _cargando;
  String? get error    => _error;

  // ─── Dashboard ───────────────────────────────────────────────────────────
  StatsAdmin? _stats;
  StatsAdmin? get stats => _stats;

  Future<void> cargarStats() async {
    _setLoading(true);
    try {
      _stats = await _adminService.obtenerStats();
      _error = null;
    } catch (e) {
      _error = _msg(e);
    } finally {
      _setLoading(false);
    }
  }

  // ─── Lista de usuarios ───────────────────────────────────────────────────
  List<UsuarioAdmin> _usuarios = [];
  
  Set<String> _filtroRoles = {
    'pequeno_productor',
    'trabajador',
    'gestor',
    'administrador'
  };
  Set<bool> _filtroEstados = {true, false};
  String  _busqueda       = '';
  bool    _verEliminados  = false;
  int     _paginaActual   = 0;
  static const int _porPagina = 20;
  bool    _hayMasPaginas  = false;

  List<UsuarioAdmin> get usuarios {
    return _usuarios.where((u) {
      final roleNormalized = u.role.toLowerCase().trim();
      final matchesRole = _filtroRoles.any((r) => r.toLowerCase().trim() == roleNormalized);
      final matchesEstado = _filtroEstados.contains(u.activo);
      return matchesRole && matchesEstado;
    }).toList();
  }

  Set<String> get filtroRoles => _filtroRoles;
  Set<bool> get filtroEstados => _filtroEstados;
  String  get busqueda       => _busqueda;
  bool    get verEliminados  => _verEliminados;
  int     get paginaActual   => _paginaActual;
  bool    get hayMasPaginas  => _hayMasPaginas;

  Future<void> cargarUsuarios({bool reset = true}) async {
    if (reset) _paginaActual = 0;
    _setLoading(true);
    try {
      final lista = await _adminService.listarUsuarios(
        search:         _busqueda.isEmpty ? null : _busqueda,
        includeDeleted: _verEliminados,
        limit:          100,
        offset:         0,
      );
      _usuarios       = lista;
      _hayMasPaginas  = false;
      _error          = null;
    } catch (e) {
      _error = _msg(e);
    } finally {
      _setLoading(false);
    }
  }

  void setFiltroRoles(Set<String> roles) {
    _filtroRoles = roles;
    notifyListeners();
  }

  void setFiltroEstados(Set<bool> estados) {
    _filtroEstados = estados;
    notifyListeners();
  }

  void setBusqueda(String valor)     { _busqueda     = valor; cargarUsuarios(); }
  void setVerEliminados(bool valor)  { _verEliminados = valor; cargarUsuarios(); }

  void paginaSiguiente() { if (_hayMasPaginas) { _paginaActual++; cargarUsuarios(reset: false); } }
  void paginaAnterior()  { if (_paginaActual > 0) { _paginaActual--; cargarUsuarios(); } }

  // ─── Detalle usuario ─────────────────────────────────────────────────────
  UsuarioAdmin? _usuarioDetalle;
  UsuarioAdmin? get usuarioDetalle => _usuarioDetalle;

  Future<void> cargarUsuario(String id) async {
    _setLoading(true);
    try {
      _usuarioDetalle = await _adminService.obtenerUsuario(id);
      _error = null;
    } catch (e) {
      _error = _msg(e);
    } finally {
      _setLoading(false);
    }
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────

  Future<bool> crearUsuario({
    required String nombreCompleto,
    required String email,
    required String password,
    required String role,
    String? telefono,
  }) async {
    _setLoading(true);
    try {
      await _adminService.crearUsuario(
        nombreCompleto: nombreCompleto,
        email:          email,
        password:       password,
        role:           role,
        telefono:       telefono,
      );
      await cargarUsuarios();
      _error = null;
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> editarUsuario(
    String id, {
    String? nombreCompleto,
    String? telefono,
    String? role,
    bool?   activo,
  }) async {
    _setLoading(true);
    try {
      _usuarioDetalle = await _adminService.editarUsuario(
        id,
        nombreCompleto: nombreCompleto,
        telefono:       telefono,
        role:           role,
        activo:         activo,
      );
      await cargarUsuarios();
      _error = null;
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetearPassword(String id, String nuevaPassword) async {
    _setLoading(true);
    try {
      await _adminService.resetearPassword(id, nuevaPassword);
      _error = null;
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> eliminarUsuario(String id) async {
    _setLoading(true);
    try {
      await _adminService.eliminarUsuario(id);
      await cargarUsuarios();
      _error = null;
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restaurarUsuario(String id) async {
    _setLoading(true);
    try {
      await _adminService.restaurarUsuario(id);
      await cargarUsuarios();
      _error = null;
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Lotes ───────────────────────────────────────────────────────────────
  List<LoteAdmin> _lotes = [];
  List<LoteAdmin> get lotes => _lotes;

  Future<void> cargarTodosLotes({String? propietarioId}) async {
    _setLoading(true);
    try {
      _lotes = await _adminService.listarTodosLotes(
          propietarioId: propietarioId);
      _error = null;
    } catch (e) {
      _error = _msg(e);
    } finally {
      _setLoading(false);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  void _setLoading(bool v) { _cargando = v; notifyListeners(); }
  String _msg(Object e)    => e.toString().replaceAll('Exception: ', '');
  void limpiarError()      { _error = null; notifyListeners(); }
}