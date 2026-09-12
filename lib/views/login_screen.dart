import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindcare/services/firebase_auth_service.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/views/main_navigation_screen.dart';
import 'package:mindcare/views/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Email wajib diisi.');
      return;
    }

    if (!email.contains('@')) {
      _showError('Format email tidak valid.');
      return;
    }

    if (password.isEmpty) {
      _showError('Password wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await AppStateService.instance.loginPatient(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil! ✨'),
          backgroundColor: AppColors.secondary,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Password salah';
      } else if (e.message != null) {
        message = e.message!;
      }

      if (!mounted) return;
      _showError(message);
    } catch (e) {
      if (!mounted) return;
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null) {
        final user = credential.user;
        await AppStateService.instance.loginGoogleUser(
          email: user?.email ?? 'google.user@gmail.com',
          name: user?.displayName ?? 'Pengguna Google',
          avatarUrl: user?.photoURL,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Google berhasil! ✨'),
            backgroundColor: AppColors.secondary,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal login Google: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: Stack(
        children: [
          // Decorative Ambient Blur Orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softMint.withValues(alpha: 0.35),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Section
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // Main Form Card Container
                      _buildFormCard(),
                      const SizedBox(height: 24),

                      // Footer Register Link
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header (Mascot, Title, Subtitle) ---
  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Image.asset(
          'assets/images/logo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.psychology,
            color: AppColors.primary,
            size: 140,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Selamat Datang Kembali',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'Masuk ke akun Anda untuk melanjutkan perjalanan kesehatan mental.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.4,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // --- Main Form Card ---
  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Input
          _buildLabel('Alamat Email'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _emailController,
            hintText: 'nama@email.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password Input
          _buildLabel('Kata Sandi'),
          const SizedBox(height: 6),
          _buildPasswordField(
            controller: _passwordController,
            hintText: '••••••••',
            isVisible: _isPasswordVisible,
            onToggle: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 10),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tautan pemulihan kata sandi telah dikirim ke email Anda.'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lupa Kata Sandi?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Primary Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masuk ke Akun',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Divider "Atau"
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau masuk dengan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1)),
            ],
          ),
          const SizedBox(height: 16),

          // Google Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleGoogleLogin,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 12),
                  Text(
                    'Masuk dengan Google',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  // --- Label Helper ---
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    );
  }

  // --- Text Field Helper ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.outline,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
        filled: true,
        fillColor: AppColors.surfaceCanvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // --- Password Field Helper ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.outline,
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.outline,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.surfaceCanvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // --- Footer Link ---
  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            'Daftar Sekarang',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 24.0;
    final double sy = size.height / 24.0;

    // 1. Red Top Sector (#EA4335)
    final redPath = Path()
      ..moveTo(12.0 * sx, 4.75 * sy)
      ..cubicTo(13.77 * sx, 4.75 * sy, 15.35 * sx, 5.36 * sy, 16.6 * sx, 6.55 * sy)
      ..lineTo(20.02 * sx, 3.13 * sy)
      ..cubicTo(17.96 * sx, 1.21 * sy, 15.24 * sx, 0.0 * sy, 12.0 * sx, 0.0 * sy)
      ..cubicTo(7.39 * sx, 0.0 * sy, 3.39 * sx, 2.62 * sy, 1.38 * sx, 6.44 * sy)
      ..lineTo(5.27 * sx, 9.46 * sy)
      ..cubicTo(6.22 * sx, 6.72 * sy, 8.88 * sx, 4.75 * sy, 12.0 * sx, 4.75 * sy)
      ..close();

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    canvas.drawPath(redPath, redPaint);

    // 2. Yellow Left Sector (#FBBC05)
    final yellowPath = Path()
      ..moveTo(5.27 * sx, 9.46 * sy)
      ..cubicTo(5.03 * sx, 10.18 * sy, 4.9 * sx, 10.95 * sy, 4.9 * sx, 11.75 * sy)
      ..cubicTo(4.9 * sx, 12.55 * sy, 5.03 * sx, 13.32 * sy, 5.27 * sx, 14.04 * sy)
      ..lineTo(1.38 * sx, 17.06 * sy)
      ..cubicTo(0.5 * sx, 15.37 * sy, 0.0 * sx, 13.63 * sy, 0.0 * sx, 11.75 * sy)
      ..cubicTo(0.0 * sx, 9.87 * sy, 0.5 * sx, 8.13 * sy, 1.38 * sx, 6.44 * sy)
      ..lineTo(5.27 * sx, 9.46 * sy)
      ..close();

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    canvas.drawPath(yellowPath, yellowPaint);

    // 3. Green Bottom Sector (#34A853)
    final greenPath = Path()
      ..moveTo(12.0 * sx, 18.75 * sy)
      ..cubicTo(8.88 * sx, 18.75 * sy, 6.22 * sx, 16.78 * sy, 5.27 * sx, 14.04 * sy)
      ..lineTo(1.38 * sx, 17.06 * sy)
      ..cubicTo(3.39 * sx, 20.88 * sy, 7.39 * sx, 23.5 * sy, 12.0 * sx, 23.5 * sy)
      ..cubicTo(15.24 * sx, 23.5 * sy, 17.96 * sx, 22.43 * sy, 19.92 * sx, 20.62 * sy)
      ..lineTo(16.13 * sx, 17.68 * sy)
      ..cubicTo(15.08 * sx, 18.38 * sy, 13.68 * sx, 18.75 * sy, 12.0 * sx, 18.75 * sy)
      ..close();

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    canvas.drawPath(greenPath, greenPaint);

    // 4. Blue Right Sector & Horizontal Bar (#4285F4)
    final bluePath = Path()
      ..moveTo(23.5 * sx, 11.75 * sy)
      ..cubicTo(23.5 * sx, 10.93 * sy, 23.43 * sx, 10.15 * sy, 23.3 * sx, 9.4 * sy)
      ..lineTo(12.0 * sx, 9.4 * sy)
      ..lineTo(12.0 * sx, 14.1 * sy)
      ..lineTo(18.46 * sx, 14.1 * sy)
      ..cubicTo(18.18 * sx, 15.56 * sy, 17.34 * sx, 16.82 * sy, 16.13 * sx, 17.68 * sy)
      ..lineTo(19.92 * sx, 20.62 * sy)
      ..cubicTo(22.14 * sx, 18.57 * sy, 23.5 * sx, 15.48 * sy, 23.5 * sx, 11.75 * sy)
      ..close();

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bluePath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
