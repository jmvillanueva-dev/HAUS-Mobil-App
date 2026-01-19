import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual para RoomieMatch
/// Inspirado en diseños modernos de apps de roommates con Dark Mode principal
class AppTheme {
  // ============================================
  // COLORES PRINCIPALES
  // ============================================

  /// Teal/Turquesa - Color primario para acciones y acentos
  static const Color primaryColor = Color(0xFF2DD4BF);

  /// Teal oscuro para variantes del primario
  static const Color primaryDark = Color(0xFF14B8A6);

  /// Teal claro para estados hover/pressed
  static const Color primaryLight = Color(0xFF5EEAD4);

  /// Verde Lima - Color secundario para badges y verificación
  static const Color secondaryColor = Color(0xFFBFFF00);

  /// Secundario oscuro
  static const Color secondaryDark = Color(0xFFA3E635);

  // ============================================
  // COLORES DE FONDO - DARK MODE
  // ============================================

  /// Fondo principal oscuro
  static const Color backgroundDark = Color(0xFF0D0D0D);

  /// Superficies elevadas (cards, modals)
  static const Color surfaceDark = Color(0xFF1A1A1A);

  /// Superficie elevada secundaria
  static const Color surfaceDarkElevated = Color(0xFF262626);

  // ============================================
  // COLORES DE FONDO - LIGHT MODE
  // ============================================

  /// Fondo principal claro
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Superficies en light mode
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Superficie con sombra sutil
  static const Color surfaceLightElevated = Color(0xFFF5F5F5);

  // ============================================
  // COLORES DE TEXTO
  // ============================================

  /// Texto principal en dark mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Texto secundario en dark mode
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  /// Texto terciario/disabled en dark mode
  static const Color textTertiaryDark = Color(0xFF6B7280);

  /// Texto principal en light mode
  static const Color textPrimaryLight = Color(0xFF1F2937);

  /// Texto secundario en light mode
  static const Color textSecondaryLight = Color(0xFF6B7280);

  /// Texto terciario en light mode
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // ============================================
  // COLORES SEMÁNTICOS
  // ============================================

  /// Error/Alerta
  static const Color errorColor = Color(0xFFFF6B6B);

  /// Éxito/Confirmación
  static const Color successColor = Color(0xFF22C55E);

  /// Advertencia
  static const Color warningColor = Color(0xFFFBBF24);

  /// Información
  static const Color infoColor = Color(0xFF3B82F6);

  // ============================================
  // COLORES DE VERIFICACIÓN
  // ============================================

  /// Badge verificado
  static const Color verifiedColor = Color(0xFF22C55E);

  /// Badge pendiente
  static const Color pendingColor = Color(0xFFFBBF24);

  /// Badge no verificado
  static const Color unverifiedColor = Color(0xFF6B7280);

  /// Badge rechazado
  static const Color rejectedColor = Color(0xFFEF4444);

  // ============================================
  // BORDES Y DIVISORES
  // ============================================

  static const Color borderDark = Color(0xFF374151);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF1F2937);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // ============================================
  // TEMA OSCURO (Principal)
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryDark,
        secondary: secondaryColor,
        secondaryContainer: secondaryDark,
        surface: surfaceDark,
        error: errorColor,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textPrimaryDark,
        onError: Colors.white,
        outline: borderDark,
      ),
      scaffoldBackgroundColor: backgroundDark,

      // Tipografía
      textTheme: _buildTextTheme(isDark: true),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Botones con borde
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: borderDark, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondaryDark,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: textTertiaryDark,
          fontSize: 14,
        ),
        prefixIconColor: textSecondaryDark,
        suffixIconColor: textSecondaryDark,
      ),

      // Cards
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: textSecondaryDark);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryDark,
          );
        }),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: backgroundDark,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDarkElevated,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDarkElevated,
        contentTextStyle: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  // ============================================
  // TEMA CLARO (Alternativo)
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLight,
        secondary: secondaryColor,
        secondaryContainer: secondaryDark,
        surface: surfaceLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: textPrimaryLight,
        onSurface: textPrimaryLight,
        onError: Colors.white,
        outline: borderLight,
      ),
      scaffoldBackgroundColor: backgroundLight,

      // Tipografía
      textTheme: _buildTextTheme(isDark: false),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Botones con borde
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: borderLight, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondaryLight,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: textTertiaryLight,
          fontSize: 14,
        ),
        prefixIconColor: textSecondaryLight,
        suffixIconColor: textSecondaryLight,
      ),

      // Cards
      cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primaryColor.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: textSecondaryLight);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryLight,
          );
        }),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLightElevated,
        selectedColor: primaryColor.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerLight,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: GoogleFonts.inter(
          color: surfaceLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  // ============================================
  // HELPER: Construir tema de texto
  // ============================================

  static TextTheme _buildTextTheme({required bool isDark}) {
    final Color primaryText = isDark ? textPrimaryDark : textPrimaryLight;
    final Color secondaryText = isDark ? textSecondaryDark : textSecondaryLight;

    return TextTheme(
      // Display
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),

      // Headlines
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),

      // Titles
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),

      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primaryText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: secondaryText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryText,
      ),

      // Labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryText,
        letterSpacing: 0.5,
      ),
    );
  }

  // ============================================
  // HELPERS: Acceso rápido a colores
  // ============================================

  /// Obtener color de verificación según estado
  static Color getVerificationColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return verifiedColor;
      case 'pending':
        return pendingColor;
      case 'rejected':
        return rejectedColor;
      default:
        return unverifiedColor;
    }
  }

  /// Obtener texto de verificación según estado
  static String getVerificationText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verificado';
      case 'pending':
        return 'En revisión';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Sin verificar';
    }
  }

  /// Obtener icono de verificación según estado
  static IconData getVerificationIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Icons.verified_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
