import 'package:flutter/material.dart';
import 'package:authenticatu/services/firestore_service.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final secureDataService = SecureDataService();

  @override
  void initState() {
    super.initState();
    _test();
  }

  Future<void> _test() async {
    await secureDataService.storeSetSecret('123456', 'TRALALA', 'TRALALA');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppBar Title')),
      body: const Center(child: Text('')),
    );
  }
}
