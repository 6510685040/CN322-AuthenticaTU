import 'dart:async';
import 'package:authenticatu/Screen/auth_service.dart';
import 'package:authenticatu/Screen/scanner.dart';
import 'package:authenticatu/components/countdownbar.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:authenticatu/shared_pref_access.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:authenticatu/Screen/change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  bool _isLoading = true;
  String? _error;
  bool isGuest = false;

  Future<void> _checkGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    final guest = prefs.getBool('guestUser') ?? false;
    setState(() {
      isGuest = guest;
    });
  }

  void logout() async {
    try {
      authService.value.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  void _startOtpTimer() {
    final now = DateTime.now();
    final secondsUntilNextCycle = 30 - (now.second % 30);

    // Initial delay to sync with 30-second intervals
    Future.delayed(Duration(seconds: secondsUntilNextCycle), () {
      if (mounted) {
        reloadData();
        _timer = Timer.periodic(const Duration(seconds: 30), (_) {
          reloadData();
        });
      }
    });
  }

  Future<void> reloadData() async {
    if (!mounted) return;

    setState(() {
      _error = null;
    });

    try {
      await Provider.of<OtpProvider>(context, listen: false).initData();
    } catch (e) {
      // เป็นไปได้ยากที่จะเข้าตรงนี้เพราะ process ด้านบนมี error handle Tui
      if (mounted) {
        setState(() {
          _error = 'Failed to load OTP data. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await reloadData();
  }

  @override
  void initState() {
    super.initState();
    _checkGuestUser();
    reloadData();
    _startOtpTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _handleRefresh,
          ),
          if (!isGuest) // 👈 Only show if not a guest
            IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScannerScreen()),
          ).then(
            (_) => reloadData(),
          ); // Reload data after returning from scanner
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Consumer<OtpProvider>(
      builder: (context, provider, child) {
        final itemCount = provider.otps.length;

        if (itemCount <= 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("ไม่พบข้อมูล", style: TextStyle(fontSize: 35)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScannerScreen(),
                      ),
                    ).then((_) => reloadData());
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              TOTPCountdownBar(),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final otp = provider.otps[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Text(
                          otp.key,
                          style: const TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text(otp.label),
                        subtitle: otp.issuer != null ? Text(otp.issuer!) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  bool backUpStatus = false;

  Future<void> loadBackUpStatus() async {
    final status = await getBackUpStatus(); // your async function
    setState(() {
      backUpStatus = status;
    });
  }

  @override
  void initState() {
    loadBackUpStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Container(
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
  );

  Widget buildMenuItems(BuildContext context) => Column(
    children: [
      ListTile(
        leading: const Icon(Icons.password),
        title: const Text('Change Password'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangePasswordPage()),
          );
        },
      ),
      ListTile(
        leading:
            (backUpStatus
                ? Icon(Icons.backup, color: Colors.blue.shade400)
                : Icon(Icons.backup)),
        title: const Text('Back up and Restore'),
        onTap: () {
          // TODO - check if not login yet
          setState(() {
            toggleBackUpStatus();
            backUpStatus = !backUpStatus;
          });
        },
      ),
    ],
  );
}
