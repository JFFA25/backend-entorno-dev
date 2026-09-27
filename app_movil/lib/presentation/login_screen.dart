import 'package:flutter/material.dart';
import '../data/keycloak_service.dart';
import '../data/api_service.dart'; // 1. Importamos tu nuevo servicio de API

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final KeycloakService _authService = KeycloakService();
  final ApiService _apiService = ApiService(); // 2. Instanciamos tu servicio HTTP
  
  String _status = "Presiona el botón para iniciar sesión";
  String _token = "";
  bool _loading = false;
  bool _apiLoading = false; // Estado de carga para la consulta HTTP
  String _apiResponse = ""; // Aquí se guardará el estado de las BDs

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  static const _bgTop = Color(0xFF0F0C29);
  static const _bgMid = Color(0xFF302B63);
  static const _bgBottom = Color(0xFF24243E);
  static const _accent = Color(0xFF00E5FF);
  static const _accent2 = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();

    final tokenRecibido = _authService.checkForToken();
    if (tokenRecibido != null) {
      setState(() {
        _status = "¡Autenticación Exitosa!";
        _token = tokenRecibido;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _loading = true;
      _status = "Redirigiendo a Keycloak...";
    });
    _authService.login();
  }

  // 3. Función para mandar a consultar a tu contenedor de FastAPI
  void _checkApiHealth() async {
    setState(() {
      _apiLoading = true;
    });
    
    final data = await _apiService.getDatabaseHealth();
    
    setState(() {
      _apiLoading = false;
      if (data.containsKey('error')) {
        _apiResponse = data['error'];
      } else {
        _apiResponse = "PostgreSQL: ${data['postgres']}\nMongoDB: ${data['mongodb']}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Keycloak Auth',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgMid, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                  
                  // 4. Inyectamos la sección de pruebas del backend integrada a tus estilos
                  const SizedBox(height: 24),
                  _buildApiButton(),
                  if (_apiResponse.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildApiResponseCard(),
                  ],
                  
                  if (_token.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Expanded(child: _buildTokenCard()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_accent, _accent2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.lock_outline, color: Colors.white, size: 40),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        _status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.92),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_accent2, _accent],
          ),
          boxShadow: [
            BoxShadow(
              color: _accent2.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _loading ? null : _handleLogin,
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Iniciar sesión con Keycloak",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // 5. Botón estilizado para activar el Healthcheck de tu backend
  Widget _buildApiButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _accent, width: 1.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _apiLoading ? null : _checkApiHealth,
        child: _apiLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: _accent),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_sync_rounded, color: _accent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Consultar API (Healthcheck)",
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // 6. Tarjeta translúcida para pintar las respuestas "Connected" de Docker en tiempo real
  Widget _buildApiResponseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        _apiResponse,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.white,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTokenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: _accent, size: 18),
              const SizedBox(width: 8),
              const Text(
                "Token JWT recibido",

                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                _token,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}