import 'package:flutter/material.dart';

class ScannerQrScreen extends StatelessWidget {
  const ScannerQrScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Scanner un QR Code'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner,
                    size: 64, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(height: 24),
                Text('Placez le QR code dans la zone',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scanner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Intégrer la logique de scan QR
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
