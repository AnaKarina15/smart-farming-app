import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final _nameController = TextEditingController(text: 'Juan Pérez');
  final _emailController = TextEditingController(text: 'juan.perez@agrofield.com');
  final _phoneController = TextEditingController(text: '+54 9 11 1234-5678');
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // State flags
  bool _isEditingData = false;
  bool _isChangingPassword = false;
  bool _hasChanges = false;

  // Store original values to detect changes
  late String _originalName;
  late String _originalEmail;
  late String _originalPhone;

  @override
  void initState() {
    super.initState();
    _originalName = _nameController.text;
    _originalEmail = _emailController.text;
    _originalPhone = _phoneController.text;

    // Listen for changes
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _currentPasswordController.addListener(_checkForChanges);
    _newPasswordController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasDataChanges = _nameController.text != _originalName ||
        _emailController.text != _originalEmail ||
        _phoneController.text != _originalPhone;
    final hasPasswordChanges = _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty;

    setState(() {
      _hasChanges = hasDataChanges || hasPasswordChanges;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Offline banner
              const _OfflineBanner(),
              const SizedBox(height: 24),

              // Profile photo
              _buildProfilePhoto(),
              const SizedBox(height: 16),

              // User name
              Text(
                _nameController.text.toUpperCase(),
                style: GoogleFonts.lexend(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons row
              _buildActionButtons(),
              const SizedBox(height: 28),

              // Data fields
              _buildLabeledField(
                label: 'NOMBRE COMPLETO',
                controller: _nameController,
                enabled: _isEditingData,
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'CORREO ELECTRÓNICO',
                controller: _emailController,
                enabled: _isEditingData,
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'TELÉFONO',
                controller: _phoneController,
                enabled: _isEditingData,
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE0E0E0), thickness: 1),
              const SizedBox(height: 24),

              // Change password section
              _buildChangePasswordSection(),

              const SizedBox(height: 32),

              // Save changes button
              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfilePhoto() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDSN3PC-r68fjYmxenSJhpeON5kYHq_FqUZAujP2XfNu3JJHwHWSgnCN9Mm79mUT-e6OebbOBqgIc99B8tup3iS0PJnmytuyZZktqjXVRIZLYy-ESL4kwGEoJAe-zbuBYr_xAOBApeI9dr99zxBRrgqOuruL2tbOPHRDxigBfNC744A0tG932QLdld5h7USNgZhYJ84JYhao2to2xVmuj7iaXDmBiqsY2uFfKiVOKnGAYGhCMl6sOASdn-0vA8-ceZz9ucme_xBy_B3',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Edit Photo button
        _ActionChip(
          icon: Icons.image_outlined,
          label: 'EDITAR FOTO',
          onTap: () {
            // TODO: Open image picker
          },
        ),
        const SizedBox(width: 8),
        // Edit Data button
        _ActionChip(
          icon: Icons.edit_outlined,
          label: 'EDITAR DATOS',
          isActive: _isEditingData,
          onTap: () {
            setState(() {
              _isEditingData = !_isEditingData;
              if (!_isEditingData) {
                // Reset values if cancelling edit
                _nameController.text = _originalName;
                _emailController.text = _originalEmail;
                _phoneController.text = _originalPhone;
              }
            });
          },
        ),
        const SizedBox(width: 8),
        // Settings gear icon
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: () {
              // TODO: Open settings
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.settings,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            color: AppColors.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.lexend(
            color: enabled ? AppColors.primary : AppColors.textGrey,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            fillColor: enabled ? AppColors.white : const Color(0xFFF5F5F5),
            filled: true,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textGrey, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: enabled ? AppColors.primary : AppColors.borderGrey,
                width: enabled ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: enabled ? AppColors.primary : AppColors.borderGrey,
                width: enabled ? 2 : 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: AppColors.borderGrey,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Change password toggle button
        GestureDetector(
          onTap: () {
            setState(() {
              _isChangingPassword = !_isChangingPassword;
              if (!_isChangingPassword) {
                _currentPasswordController.clear();
                _newPasswordController.clear();
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: _isChangingPassword
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _isChangingPassword ? AppColors.primary : AppColors.borderGrey,
                width: _isChangingPassword ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: _isChangingPassword ? AppColors.primary : AppColors.textGrey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'CAMBIAR CONTRASEÑA',
                  style: GoogleFonts.lexend(
                    color: _isChangingPassword ? AppColors.primary : AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isChangingPassword
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _isChangingPassword ? AppColors.primary : AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),

        // Password fields (animated)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEGURIDAD',
                  style: GoogleFonts.lexend(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  label: 'CONTRASEÑA ACTUAL',
                  controller: _currentPasswordController,
                  enabled: true,
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  label: 'NUEVA CONTRASEÑA',
                  controller: _newPasswordController,
                  enabled: true,
                ),
              ],
            ),
          ),
          crossFadeState: _isChangingPassword
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _hasChanges
          ? () {
              // TODO: Save changes to backend
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cambios guardados correctamente',
                    style: GoogleFonts.lexend(),
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
              setState(() {
                _originalName = _nameController.text;
                _originalEmail = _emailController.text;
                _originalPhone = _phoneController.text;
                _hasChanges = false;
                _isEditingData = false;
                _isChangingPassword = false;
                _currentPasswordController.clear();
                _newPasswordController.clear();
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _hasChanges ? AppColors.primary : const Color(0xFFBDBDBD),
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: _hasChanges ? AppColors.primary : const Color(0xFFBDBDBD),
            width: 2,
          ),
          boxShadow: _hasChanges
              ? const [
                  BoxShadow(
                    color: AppColors.primary,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            'GUARDAR CAMBIOS',
            style: GoogleFonts.lexend(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Private Widgets ---

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: const Color(0xFF1B4332), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Color(0xFFC1ECD4), size: 20),
          const SizedBox(width: 8),
          Text(
            'MODO OFFLINE',
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lexend(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
