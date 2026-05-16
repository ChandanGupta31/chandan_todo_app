import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/presentation/bloc/task_bloc.dart';
import 'package:todo/presentation/bloc/task_event.dart';
import 'package:todo/presentation/bloc/theme_bloc.dart';
import 'core/di/service_locator.dart' as di;
import 'presentation/pages/home_page.dart';

void main() async {
  // Ensure Flutter binding is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection and Hive
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => di.sl<TaskBloc>()..add(LoadTasksEvent()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Chandan ToDo',
            debugShowCheckedModeBanner: false,
            
            // Premium Theme Config using customized colorSchemeSeed
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(centerTitle: false),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(centerTitle: false),
            ),
            
            // This now reads dynamically from our ThemeBloc state!
            themeMode: themeState.themeMode, 
            
            home: const HomePage(),
          );
        },
      ),
    );
  }
}