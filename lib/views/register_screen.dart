import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/services/app_state_service.dart';
import 'package:mindcare/views/main_navigation_screen.dart';
import 'package:mindcare/views/login_screen.dart';
import 'package:mindcare/views/psychologist_dashboard_screen.dart';

enum UserRole { user, psychologist }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _selectedRole = UserRole.user;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Basic Validations
    if (name.isEmpty) {
      _showError('Silakan masukkan nama lengkap Anda.');
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showError('Format email tidak valid.');
      return;
    }

    if (password.length < 6) {
      _showError('Kata sandi minimal 6 karakter.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);

    if (_selectedRole == UserRole.psychologist) {
      final license = _licenseController.text.trim();
      final exp = _experienceController.text.trim();
      final spec = _specializationController.text.trim();

      if (license.isEmpty) {
        setState(() => _isLoading = false);
        _showError('Silakan masukkan nomor STR / SIPP Anda.');
        return;
      }

      if (exp.isEmpty) {
        setState(() => _isLoading = false);
        _showError('Silakan masukkan lama pengalaman praktik.');
        return;
      }

      final res = await AppStateService.instance.registerPsychologist(
        name: name,
        email: email,
        password: password,
        licenseNumber: license,
        experienceYears: '$exp Tahun',
        specialization: spec.isNotEmpty ? spec : 'Psikologi Klinis & Konseling Mental',
        phone: phone.isNotEmpty ? phone : '+62 821 5566 7788',
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Pendaftaran Psikolog berhasil! ✨'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PsychologistDashboardScreen()),
        );
      } else {
        _showError(res['message'] ?? 'Gagal melakukan pendaftaran.');
      }
    } else {
      final res = await AppStateService.instance.registerPatient(
        name: name,
        email: email,
        password: password,
        phone: phone.isNotEmpty ? phone : '+62 812 3456 7890',
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Akun Pengguna berhasil dibuat! ✨'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        _showError(res['message'] ?? 'Gagal melakukan pendaftaran.');
      }
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

                      // Main Card Container
                      _buildFormCard(),
                      const SizedBox(height: 24),

                      // Footer Login Link
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
        // Mascot Image / Avatar
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              _selectedRole == UserRole.psychologist
                  ? 'https://images.unsplash.com/photo-1594824813580-496a798b3f4f?auto=format&fit=crop&w=200&q=80'
                  : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                _selectedRole == UserRole.psychologist ? Icons.medical_services_rounded : Icons.psychology,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          _selectedRole == UserRole.psychologist
              ? 'Daftar Akun Psikolog'
              : 'Daftar Akun Pengguna',
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
          _selectedRole == UserRole.psychologist
              ? 'Gabung sebagai mitra profesional MindCare untuk membantu pasien.'
              : 'Mulai perjalanan kesehatan mentalmu bersama kami.',
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
    return Container(
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
          // Role Selection Section
          Text(
            'Pilih Tipe Pendaftaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleSelector(),
          const SizedBox(height: 20),

          if (_selectedRole == UserRole.user) ...[
            // Nama Lengkap Input
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _nameController,
              hintText: 'Contoh: Anindya Kirana',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

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

            // Nomor HP
            _buildLabel('Nomor WhatsApp / HP'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _phoneController,
              hintText: '+62 812 3456 7890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Password Input
            _buildLabel('Kata Sandi (Min. 6 Karakter)'),
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
            const SizedBox(height: 16),

            // Confirm Password Input
            _buildLabel('Konfirmasi Kata Sandi'),
            const SizedBox(height: 6),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: '••••••••',
              isVisible: _isConfirmPasswordVisible,
              onToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ] else ...[
            // Nama Lengkap & Gelar Input
            _buildLabel('Nama Lengkap & Gelar Profesional'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _nameController,
              hintText: 'Contoh: Dr. Sarah Doe, M.Psi',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),

            // Email Profesional Input
            _buildLabel('Email Profesional'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _emailController,
              hintText: 'sarah.doe@clinic.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Nomor STR / SIPP Input
            _buildLabel('Nomor STR / SIPP Resmi'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _licenseController,
              hintText: 'Misal: SIPP. 1984/HIMPSI/2023',
              icon: Icons.assignment_ind_outlined,
            ),
            const SizedBox(height: 16),

            // Tahun Pengalaman & Spesialisasi
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Pengalaman'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _experienceController,
                        hintText: 'Misal: 5',
                        icon: Icons.work_history_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Spesialisasi'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _specializationController,
                        hintText: 'Psikologi Klinis',
                        icon: Icons.psychology_outlined,
                      ),
                    ],
                  ),
                ),
              ],
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
            const SizedBox(height: 16),

            // Confirm Password Input
            _buildLabel('Konfirmasi Kata Sandi'),
            const SizedBox(height: 6),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: '••••••••',
              isVisible: _isConfirmPasswordVisible,
              onToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 16),

            // Info Banner
            _buildInfoBanner(),
          ],
          const SizedBox(height: 24),

          // Primary Register Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
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
                          _selectedRole == UserRole.psychologist
                              ? 'Daftar sebagai Psikolog'
                              : 'Daftar Akun Pengguna',
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
        ],
      ),
    );
  }

  // --- Role Selector Widget (Pengguna / Psikolog) ---
  Widget _buildRoleSelector() {
    final bool isUserSelected = _selectedRole == UserRole.user;
    final bool isPsychologistSelected = _selectedRole == UserRole.psychologist;

    return Row(
      children: [
        // Role: Saya Pengguna
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedRole = UserRole.user;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: isUserSelected
                    ? AppColors.primaryContainer.withValues(alpha: 0.2)
                    : AppColors.surfaceCanvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUserSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: isUserSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 28,
                    color: isUserSelected ? AppColors.primary : AppColors.outline,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pengguna / Pasien',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isUserSelected ? FontWeight.bold : FontWeight.w500,
                      color: isUserSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Role: Saya Psikolog
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedRole = UserRole.psychologist;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: isPsychologistSelected
                    ? AppColors.secondaryContainer.withValues(alpha: 0.25)
                    : AppColors.surfaceCanvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPsychologistSelected
                      ? AppColors.secondary
                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: isPsychologistSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 28,
                    color: isPsychologistSelected ? AppColors.secondary : AppColors.outline,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Psikolog / Terapis',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isPsychologistSelected ? FontWeight.bold : FontWeight.w500,
                      color: isPsychologistSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.outline,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.outline,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.outline,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !isVisible,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.outline,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: isVisible ? AppColors.primary : AppColors.outline,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nomor STR/SIPP Anda akan otomatis diverifikasi ke database HIMPSI/Kemenkes untuk menjamin kredensial profesional.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Footer (Link to Login) ---
  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Masuk di sini',
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
}
