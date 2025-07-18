import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/settings/components/version_tile.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _serverUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, provider, child) {
      return Scaffold(
          body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Text('Settings',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 28.0)),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.dns_rounded),
                    title: Text('Server'),
                    subtitle: Text(provider.apiUrl),
                    onTap: () {
                      _serverUrlController.text = provider.apiUrl;
                      showDialog(
                        context: context,
                        builder: (context) =>
                            _buildServerSettingDialog(provider),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.print_rounded),
                    title: Text('Printer Device'),
                    subtitle: Text(
                        '${provider.printerName} (${provider.printerAddress})'),
                    onTap: () async {
                      final device =
                          await FlutterBluetoothPrinter.selectDevice(context);
                      if (device != null) {
                        provider.setPrinterAddress(device.address);
                        provider.setPrinterName(device.name!);
                      }
                    },
                  ),
                  VersionTile()
                ],
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
              flex: 1,
              child: Center(
                child: Text('Settings'),
              ))
        ],
      ));
    });
  }

  _buildServerSettingDialog(MainProvider provider) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return AlertDialog(
        title: Text('Server Setting'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.5, // Adjust height if needed
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _serverUrlController,
                  decoration: InputDecoration(labelText: 'Server URL'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setApiUrl(_serverUrlController.text);
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                msg: "New server URL has been saved",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: Text('Simpan'),
          ),
        ],
      );
    },
  );
}

}
