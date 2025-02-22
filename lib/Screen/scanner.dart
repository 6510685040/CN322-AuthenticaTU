import 'package:authenticatu/Screen/home.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/providers/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otp/otp.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();

  void _processQRCode(String code) {
    try {
      Uri uri = Uri.parse(code);
      if (uri.scheme == 'otpauth' && uri.host == 'totp') {
        String? secret = uri.queryParameters['secret'];
        String? issuer = uri.queryParameters['issuer'];
        String? label =
            uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

        if (secret != null && label != null) {
          print(
            "######################################################################object$label,$issuer,$secret",
          );
          TOTPKey totpKey = TOTPKey(key: secret, label: label, issuer: issuer);
          var provider = Provider.of<OtpProvider>(context, listen: false);
          provider.addKey(totpKey);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return HomeScreen();
              },
            ),
          );
        } else {
          _showError("Invalid QR code");
        }
      } else {
        _showError("Invalid QR code format");
      }
    } catch (e) {
      _showError("Failed to parse QR code");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            _processQRCode(barcodes.first.rawValue ?? "");
          }
        },
      ),
    );
  }
}
