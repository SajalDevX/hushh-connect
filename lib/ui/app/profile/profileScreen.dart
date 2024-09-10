import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:hushhxtinder/ui/app/product/productScreen.dart';
import 'package:hushhxtinder/ui/app/profile/profileViewModel.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileData?> _profileFuture;

  @override
  void initState() {
    super.initState();
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    _profileFuture = profileViewModel.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg', // Replace with your background image URL
              fit: BoxFit.cover,
            ),
          ),
          // Foreground Content
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                // Remove the leading property to hide the back arrow icon
              ),
              Expanded(
                child: FutureBuilder<ProfileData?>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                          child: Text('No profile data available',
                              style: TextStyle(color: Colors.white)));
                    } else {
                      final profile = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(height: 20),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(profile.imageurl),
                          ),
                          SizedBox(height: 10),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '20% complete',
                            style: TextStyle(
                              color: Colors.pinkAccent,
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Column(
                                  children: [
                                    Icon(Icons.settings, color: Colors.white),
                                    SizedBox(height: 5),
                                    Text(
                                      'Settings',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductListScreen()),
                                          );
                                        },
                                        icon: Icon(Icons.edit),
                                        color: Colors.white),
                                    SizedBox(height: 5),
                                    const Text(
                                      'Add Products',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                const Column(
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        color: Colors.white),
                                    SizedBox(height: 5),
                                    Text(
                                      'Add Media',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                const Text(
                                  'hushh Platinum™',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 5),
                                const Text(
                                  'Level up every action you take on hushh',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 0, 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                  ),
                                  child: Text(
                                    'GET HUSHH PLATINUM™',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
