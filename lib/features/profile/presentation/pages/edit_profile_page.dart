import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/avatar_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../matching/presentation/pages/preferences_page.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _universityOrCompanyController;
  late TextEditingController _bioController;

  File? _selectedImage;
  bool _isUploading = false;
  String? _avatarUrl;
  late final AvatarService _avatarService;

  @override
  void initState() {
    super.initState();
    _avatarService = getIt<AvatarService>();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _universityOrCompanyController =
        TextEditingController(text: widget.user.universityOrCompany);
    _bioController = TextEditingController(text: widget.user.bio);
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _universityOrCompanyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool fromCamera) async {
    File? image = fromCamera
        ? await _avatarService.captureFromCamera()
        : await _avatarService.pickFromGallery();
    if (image != null) {
      setState(() => _selectedImage = image);
      _uploadAvatar();
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);
    final avatarPath =
        await _avatarService.uploadAvatar(widget.user.id, _selectedImage!);
    if (avatarPath != null) {
      _avatarUrl = _avatarService.getAvatarPublicUrl(avatarPath);
    }
    setState(() => _isUploading = false);
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            UpdateProfileRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              universityOrCompany: _universityOrCompanyController.text.trim(),
              bio: _bioController.text.trim(),
              avatarUrl: _avatarUrl,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double headerHeight = 220;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          Navigator.of(context).pop();
          _showCustomSnackBar(context, '¡Perfil actualizado!', isError: false);
        } else if (state is AuthError) {
          _showCustomSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileUpdateLoading || _isUploading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      // 1. Header Negro
                      Container(
                        width: double.infinity,
                        height: headerHeight,
                        color: Colors.black, // Negro puro
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SafeArea(
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // Row para Back Button y Título
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'EDITAR PERFIL',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 56), // Alinear con el título
                                child: Text(
                                  'Mantén tu información actualizada',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Formulario en Tarjeta Blanca
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 80), // Espacio para avatar

                              _buildSectionLabel('INFORMACIÓN PERSONAL'),
                              const SizedBox(height: 16),

                              _buildLabel('Nombre'),
                              _buildTextField(
                                controller: _firstNameController,
                                hint: 'Tu nombre',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Apellido'),
                              _buildTextField(
                                controller: _lastNameController,
                                hint: 'Tu apellido',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Teléfono'),
                              _buildTextField(
                                controller: _phoneController,
                                hint: '0991234567',
                                icon: Icons.phone_android_rounded,
                                isPhone: true,
                              ),

                              const SizedBox(height: 24),
                              _buildSectionLabel('INFORMACIÓN PROFESIONAL'),
                              const SizedBox(height: 16),

                              _buildLabel(widget.user.role == UserRole.student
                                  ? 'Universidad'
                                  : 'Empresa'),
                              _buildTextField(
                                controller: _universityOrCompanyController,
                                hint: widget.user.role == UserRole.student
                                    ? 'Nombre de tu universidad'
                                    : 'Nombre de tu empresa',
                                icon: widget.user.role == UserRole.student
                                    ? Icons.school_outlined
                                    : Icons.work_outline,
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Biografía'),
                              _buildBioField(),

                              const SizedBox(height: 24),
                              _buildPreferencesButton(),

                              const SizedBox(height: 32),
                              _buildSubmitButton(isLoading),

                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancelar',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Avatar Superpuesto
                Positioned(
                  top: headerHeight - 60, // Mitad del avatar (120/2)
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildAvatar(120),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widgets ---

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppTheme.primaryColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937), // Gris oscuro
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.inter(
          color: const Color(0xFF1F2937), // Dark text
          fontWeight: FontWeight.w500,
        ),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters:
            isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
        maxLength: isPhone ? 10 : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 22),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          counterText: '',
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _bioController,
        maxLines: 4,
        maxLength: 300,
        style: GoogleFonts.inter(
          color: const Color(0xFF1F2937), // Dark text
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cuéntanos un poco sobre ti...',
          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildAvatar(double size) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
            image: _selectedImage != null
                ? DecorationImage(
                    image: FileImage(_selectedImage!), fit: BoxFit.cover)
                : (_avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                    : null),
          ),
          child: (_selectedImage == null && _avatarUrl == null)
              ? Icon(Icons.person_rounded,
                  size: size * 0.5, color: Colors.grey[300])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.black26, shape: BoxShape.circle),
              child: const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor)),
            ),
          ),
      ],
    );
  }

  Widget _buildPreferencesButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreferencesPage(userId: widget.user.id))),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor),
        ),
        title: Text(
          'Preferencias de Roomie',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          'Ajusta tus filtros de búsqueda',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.primaryColor, // Color sólido como en el login
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                'GUARDAR CAMBIOS',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar Foto de Perfil',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppTheme.primaryColor),
                ),
                title: Text('Elegir de Galería',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(false);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppTheme.primaryColor),
                ),
                title: Text('Tomar Foto',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(20),
    ));
  }
}
