import 'package:authenticatu/Screen/home.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false; // Prevents multiple scans

  void _processQRCode(String code) async {
    if (_isProcessing) return; // Ignore additional scans
    _isProcessing = true; // Mark processing started

    try {
      Uri uri = Uri.parse(code);
      if (uri.scheme == 'otpauth' && uri.host == 'totp') {
        String? secret = uri.queryParameters['secret'];
        String? issuer = uri.queryParameters['issuer'];
        String? label =
            uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

        if (secret != null && label != null) {
          TOTPKey totpKey = TOTPKey(key: secret, label: label, issuer: issuer);
          var provider = Provider.of<OtpProvider>(context, listen: false);
          await provider.addKey(totpKey).then((isSuccess) {
            if (isSuccess != null) {
              if (isSuccess) {
                cameraController.stop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Key added successfully")),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Key already exists!")));
              }
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error")));
            }
          });
        } else {
          _showError("Invalid QR code");
        }
      } else {
        _showError("Invalid QR code format");
      }
    } catch (e) {
      _showError("Failed to parse QR code");
    } finally {
      Future.delayed(Duration(seconds: 2), () {
        _isProcessing = false; // Allow scanning again after 2 seconds
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Future.delayed(Duration(seconds: 2), () {
      _isProcessing = false; // Reset scanning flag after error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
      ),
      title: Text("Scan QR Code"), 
      titleTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      backgroundColor: const Color(0xFF000957),),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (_isProcessing) return; // Prevent multiple scans
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            _processQRCode(barcodes.first.rawValue ?? "");
          }
        },
      ),
    );
  }
}
