import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    bool preference = await settingsViewModel.getNearbyUsersPreference();
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
        backgroundColor: Color(0xff212525), // AppBar background color
      ),
      backgroundColor: Color(0xff212525), // Screen background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF111418),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: const Text(
                  'Nearby Users',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Switch(
                  value: isNearbyUsersOn,
                  onChanged: (bool value) async {
                    setState(() {
                      isNearbyUsersOn = value;
                    });
                    await settingsViewModel.setNearbyUsersPreference(value);
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Color(0xff09141f),
                ),
                onTap: null,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF111418), // Background color of the tile
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
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
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await settingsViewModel.deleteResponseAndStatus();
                            Navigator.of(context).pop(); // Close after deletion
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Delete Vibes Responses'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xff212525),
                  backgroundColor: Colors.white, // Text color
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF111418), // Background color of the tile
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await settingsViewModel.logout();
                  context.go('/onboarding');
                },
                child: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xff212525),
                  backgroundColor: Colors.white, // Text color
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Delete User Button
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF111418), // Background color of the tile
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                          'Are you sure you want to permanently delete your account? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await settingsViewModel.deleteUser();
                            context.pop();
                            context.go('/onboarding');
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Delete Account'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xff212525),
                  backgroundColor:
                      Colors.redAccent, // Red color for danger action
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
