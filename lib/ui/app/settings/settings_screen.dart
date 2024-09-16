// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hushhxtinder/ui/app/settings/settingsViewModel.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Responses'),
                content: const Text(
                    'Are you sure you want to delete your Vibes responses?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await settingsViewModel.deleteResponseAndStatus();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
          child: Text('Delete Vibes Responses'),
        ),
      ),
    );
  }
}
