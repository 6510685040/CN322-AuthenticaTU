import 'dart:async';
import 'package:authenticatu/Screen/auth_service.dart';
import 'package:authenticatu/Screen/scanner.dart';
import 'package:authenticatu/components/countdownbar.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:authenticatu/shared_pref_access.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<void> handleRefresh() async {
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
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            children: const [
              TextSpan(
                text: 'Authentica',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(text: 'TU', style: TextStyle(color: Color(0xFFFFEB00))),
            ],
          ),
        ),
        //titleTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        backgroundColor: Color(0xFF000957),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : handleRefresh,
          ),
          if (!isGuest) // 👈 Only show if not a guest
            IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
        centerTitle: true,
      ),

      drawer: NavigationDrawer(onRefresh: handleRefresh),
      body: _buildBody(),
      backgroundColor: Color(0xFFFAFAFA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF000957),
        //shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScannerScreen()),
          ).then(
            (_) => reloadData(),
          ); // Reload data after returning from scanner
        },
        child: const Icon(Icons.qr_code_scanner, color: Colors.yellow),
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
              onPressed: handleRefresh,
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
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error, //warning_amber_rounded,
                    size: 80,
                    color: Color.fromARGB(255, 197, 195, 195),
                  ),
                  const SizedBox(height: 16),
                  const Text("Data not found", style: TextStyle(fontSize: 30)),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000957),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerScreen(),
                        ),
                      ).then((_) => reloadData());
                    },
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.yellow,
                    ),
                    label: const Text(
                      'Scan QR Code',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: handleRefresh,
          //color: const Color(0xFF000957),
          //color: Theme.of(context).Color(0xFF000957),
          //backgroundColor: const Color.fromARGB(255, 195, 38, 38),
          child: Column(
            children: [
              TOTPCountdownBar(),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final otp = provider.otps[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      color: Color.fromARGB(255, 245, 245, 239),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 140,
                              height: 60,
                              decoration: BoxDecoration(
                                //color: Theme.of(context).primaryColor.withOpacity(0.1),
                                color: const Color.fromARGB(49, 199, 200, 200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                otp.key,
                                style: TextStyle(
                                  fontFamily: GoogleFonts.rubik().fontFamily,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  //color: Theme.of(context).primaryColor,
                                  color: const Color(0xFF000957),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    otp.label,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF000957),
                                    ),
                                  ),
                                  if (otp.issuer != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        otp.issuer!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.color,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy_rounded,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: otp.key));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('OTP copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
  final Future<void> Function() onRefresh;
  const NavigationDrawer({super.key, required this.onRefresh});

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
    backgroundColor: const Color(0xFFFAFAFA),
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
        leading:
            (backUpStatus
                ? Icon(Icons.backup, color: Colors.blue.shade400)
                : Icon(Icons.backup)),
        title: const Text('Back up and Restore'),
        titleTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
          color: Color(0xFF000957),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        onTap: () async {
          try {
            await toggleBackUpStatus();
            await widget.onRefresh();
            setState(() {
              backUpStatus = !backUpStatus;
            });
            // Optionally close the drawer after refresh
            if (context.mounted) {
              Navigator.pop(context);
            }
            if (backUpStatus) {
              Fluttertoast.showToast(
                msg: 'Backup operation completed successfully!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              Fluttertoast.showToast(
                msg: 'Turned off backup operation successfully!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          } catch (e) {
            Fluttertoast.showToast(
              msg: 'Backup operation failed: ${e.toString()}',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
      ),
    ],
  );
}
