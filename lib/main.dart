
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ADSO4089App());
}

class ADSO4089App extends StatelessWidget {
  const ADSO4089App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ADSO4089',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const DashboardScreen(),
    );
  }
}
