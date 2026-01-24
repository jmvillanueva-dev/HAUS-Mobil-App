import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/avatar_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

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
    File? image;
    if (fromCamera) {
      image = await _avatarService.captureFromCamera();
    } else {
      image = await _avatarService.pickFromGallery();
    }

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      _uploadAvatar();
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    final avatarPath = await _avatarService.uploadAvatar(
      widget.user.id,
      _selectedImage!,
    );

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
          backgroundColor: AppTheme.backgroundDark,
          appBar: _buildAppBar(context),
          // UX: Botón siempre visible para facilitar la conversión
          bottomNavigationBar: _buildBottomAction(isLoading),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 32),

                  // Agrupación lógica por Card/Container
                  _buildFormCard(
                    title: 'Información Personal',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameController,
                              label: 'Nombre',
                              hint: 'Tu nombre',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameController,
                              label: 'Apellido',
                              hint: 'Tu apellido',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Teléfono',
                        hint: '0991234567',
                        prefixIcon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo requerido';
                          }
                          if (value.length != 10) {
                            return 'Debe tener 10 dígitos';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildFormCard(
                    title: 'Información Profesional',
                    children: [
                      CustomTextField(
                        controller: _universityOrCompanyController,
                        label: widget.user.role == UserRole.student
                            ? 'Universidad'
                            : 'Empresa',
                        hint: widget.user.role == UserRole.student
                            ? 'Nombre de tu universidad'
                            : 'Nombre de tu empresa',
                        prefixIcon: widget.user.role == UserRole.student
                            ? Icons.school_outlined
                            : Icons.work_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildBioField(),
                    ],
                  ),
                  // Espacio extra para que el scroll no choque con el bottom bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- COMPONENTES DE DISEÑO ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Center(
        child: _buildNavButton(
          icon: Icons.close_rounded, // UX: "X" para cancelar edición
          onTap: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'Editar Perfil',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
      ),
      centerTitle: true,
    );
  }

  Widget _buildNavButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, color: AppTheme.textPrimaryDark, size: 20),
      ),
    );
  }

  Widget _buildFormCard(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildBottomAction(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(top: BorderSide(color: AppTheme.borderDark, width: 0.5)),
      ),
      child: SafeArea(
        child: _buildSaveButton(isLoading),
      ),
    );
  }

  // Modificación del BioField para que encaje estéticamente
  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biografía',
          style: TextStyle(
              fontSize: 13, color: AppTheme.textSecondaryDark.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 300,
          style: const TextStyle(color: AppTheme.textPrimaryDark, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Cuéntanos un poco sobre ti...',
            hintStyle: TextStyle(
              color: AppTheme.textSecondaryDark.withOpacity(0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppTheme.backgroundDark.withOpacity(0.4),
            counterStyle: const TextStyle(
              color: AppTheme.textSecondaryDark,
              fontSize: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceDark,
                border: Border.all(
                  color: AppTheme.backgroundDark,
                  width: 4,
                ),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : (_avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: (_selectedImage == null && _avatarUrl == null)
                  ? const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: AppTheme.textSecondaryDark,
                    )
                  : null,
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showImagePickerOptions(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.backgroundDark,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Foto de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 20),
              _buildPickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Galería',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(false);
                },
              ),
              _buildPickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'Cámara',
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

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppTheme.textSecondaryDark,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppTheme.surfaceDark.withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Guardar Cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
