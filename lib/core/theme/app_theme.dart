import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.sans,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.onBackground,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        dividerColor: AppColors.divider,
        // Headers on the light ground with deep-teal text and icons, seamless with the page; a soft shadow appears
        // only once content scrolls under them. The status bar's icons turn dark to match.
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: Color(0x33000000),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtitle,
          indicatorColor: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.onBackground),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.onBackground),
          bodyMedium: TextStyle(color: AppColors.onBackground),
          bodySmall: TextStyle(color: AppColors.subtitle),
          titleLarge: TextStyle(color: AppColors.onBackground),
          titleMedium: TextStyle(color: AppColors.onBackground),
          titleSmall: TextStyle(color: AppColors.onBackground),
          headlineMedium: TextStyle(color: AppColors.onBackground),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subtitle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.button,
            foregroundColor: AppColors.onButton,
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.sans,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkAccent,
          onPrimary: AppColors.onDarkAccent,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        dividerColor: AppColors.darkBorder,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkOnSurface),
          bodyMedium: TextStyle(color: AppColors.darkOnSurface),
          bodySmall: TextStyle(color: AppColors.darkSubtitle),
          titleLarge: TextStyle(color: AppColors.darkOnSurface),
          titleMedium: TextStyle(color: AppColors.darkOnSurface),
          titleSmall: TextStyle(color: AppColors.darkOnSurface),
          headlineMedium: TextStyle(color: AppColors.darkOnSurface),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          // backgroundColor: AppColors.darkSurface,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.darkAccent,
          unselectedItemColor: AppColors.darkSubtitle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF444444)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF444444)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.darkAccent, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkAccent,
            foregroundColor: AppColors.onDarkAccent,
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: AppColors.darkBorder),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkAccent,
            side: const BorderSide(color: AppColors.darkBorder),
          ),
        ),
      );
}
