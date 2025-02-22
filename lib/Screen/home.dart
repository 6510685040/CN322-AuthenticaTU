import 'package:authenticatu/Screen/scanner.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<OtpProvider>(context, listen: false).initData();
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
            return ListView.builder(
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
