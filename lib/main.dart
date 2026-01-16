import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'local_storage_crud.dart';
import 'cloud_storage_crud.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('🔥 Firebase initialized SUCCESS');
  } catch (e) {
    debugPrint('❌ Firebase init ERROR: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter CRUD Project')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocalStorageCRUDScreen(),
                  ),
                );
              },
              child: const Text('LOCAL STORAGE CRUD'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CloudStorageCRUDScreen(),
                  ),
                );
              },
              child: const Text('CLOUD STORAGE CRUD'),
            ),
          ],
        ),
      ),
    );
  }
}
