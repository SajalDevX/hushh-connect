import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/ui/app/settings/settingsViewModel.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNearbyUsersOn = false;

  @override
  void initState() {
    super.initState();
    _loadNearbyUsersPreference();
  }

  Future<void> _loadNearbyUsersPreference() async {
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    bool preference = await settingsViewModel
        .getNearbyUsersPreference(); // Fetch nearby users toggle state
    setState(() {
      isNearbyUsersOn = preference;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Color(0xFF111418), // Set AppBar background color to match screen
      ),
      backgroundColor:
          Color(0xFF111418), // Set the screen background color to #111480
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Delete Vibes Responses Button
            ElevatedButton(
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
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await settingsViewModel.deleteResponseAndStatus();
                          Navigator.of(context)
                              .pop(); // Close dialog after deletion
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Delete Vibes Responses'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF111418),
                backgroundColor: Colors.white, // Text color
              ),
            ),

            const SizedBox(height: 20),

            // Nearby Users Toggle
            SwitchListTile(
              title: const Text(
                'Nearby Users',
                style: TextStyle(color: Colors.white),
              ),
              value: isNearbyUsersOn,
              onChanged: (bool value) async {
                setState(() {
                  isNearbyUsersOn = value;
                });
                await settingsViewModel
                    .setNearbyUsersPreference(value); // Save toggle state
              },

              tileColor: Color(0xFF111418), // Background color of the toggle
              activeColor: Colors.white, // Color when switch is on
              inactiveThumbColor: Colors.grey, // Color when switch is off
            ),
          ],
        ),
      ),
    );
  }
}
