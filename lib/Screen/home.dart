import 'dart:async';
import 'package:authenticatu/Screen/scanner.dart';
import 'package:authenticatu/components/countdownbar.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  void _startOtpTimer() {
    final now = DateTime.now();
    int secondsUntilNextCycle = 30 - (now.second % 30);

    Future.delayed(Duration(seconds: secondsUntilNextCycle), () {
      reloadData();
      _timer = Timer.periodic(Duration(seconds: 30), (timer) {
        reloadData();
      });
    });
  }

  void reloadData() {
    Provider.of<OtpProvider>(context, listen: false).initData();
  }

  @override
  void initState() {
    super.initState();
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
      body: Consumer<OtpProvider>(
        builder: (context, provider, child) {
          int itemCount = provider.otps.length;
          if (itemCount <= 0) {
            return Center(
              child: Text("ไม่พบข้อมูล", style: TextStyle(fontSize: 35)),
            );
          } else {
            return Column(
              children: [
                TOTPCountdownBar(),
                Expanded(
                  child: ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final otp = provider.otps[index];
                      return Card(
                        child: ListTile(
                          leading: Text(otp.key),
                          title: Text(otp.label),
                          subtitle: Text(otp.issuer ?? ""),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScannerScreen()),
          );
        },
        child: Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
