import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:hushhxtinder/ui/app/product/productScreen.dart';
import 'package:hushhxtinder/ui/app/profile/edit_profile/addMediaScreen.dart';
import 'package:hushhxtinder/ui/app/profile/edit_profile/editProfileScreen.dart';
import 'package:hushhxtinder/ui/app/profile/profileViewModel.dart';
import 'package:hushhxtinder/ui/app/profile/qrScreen.dart';
import 'package:hushhxtinder/ui/app/settings/settings_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileData?> _profileFuture;
  bool isPressedSettings = false;
  bool isPressedAddProduct = false;
  bool isPressedAddMedia = false;
  double profileCompletePercent = 0;

  @override
  void initState() {
    super.initState();
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    _profileFuture = profileViewModel.fetchUser();
  }

  void _resetAllExcept(String button) {
    setState(() {
      isPressedSettings = button == 'settings';
      isPressedAddProduct = button == 'addProduct';
      isPressedAddMedia = button == 'addMedia';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: CurvedBackgroundClipper(),
                child: Container(
                  height: screenHeight * 0.71,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A0C18), Color(0xFF320A3B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  FutureBuilder<ProfileData?>(
                    future: _profileFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        final profile = snapshot.data!;
                        return PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (String result) {
                            if (result == 'generateQR') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GenerateQrPromptScreen(profile: profile),
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'generateQR',
                              child: Text('Generate QR'),
                            ),
                          ],
                        );
                      } else {
                        return const Text("Error fetching profile");
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder<ProfileData?>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)),
                      );
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text('No profile data available',
                            style: TextStyle(color: Colors.white)),
                      );
                    } else {
                      final profile = snapshot.data!;
                      final profileViewModel =
                          Provider.of<ProfileViewModel>(context, listen: false);
                      profileCompletePercent =
                          profileViewModel.getProfileCompletionPercentage();

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/images/Frame.png',
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                  fit: BoxFit.cover,
                                ),
                                CircleAvatar(
                                  radius: screenWidth * 0.18,
                                  backgroundImage:
                                      NetworkImage(profile.images![0]),
                                ),
                                Positioned(
                                  bottom: -1,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.05),
                                    width: screenWidth * 0.35,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE54D60),
                                          Color(0xFFA342FF),
                                        ],
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color:
                                              Color.fromRGBO(33, 37, 41, 0.3),
                                          blurRadius: 3,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${profileCompletePercent.toInt()}% complete',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -100,
                                  right: 10,
                                  bottom: 0,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfileScreen()),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 71, 32, 110),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.edit,
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        size: screenWidth * 0.06,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profile.name,
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontSize: screenWidth * 0.07,
                                    color:
                                        const Color.fromRGBO(233, 235, 238, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Image.asset(
                                  'lib/assets/images/grey_tick.png',
                                  width: screenWidth * 0.06,
                                  height: screenWidth * 0.05,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildButton('settings', Icons.settings,
                                      'Settings', isPressedSettings, () {
                                    _resetAllExcept('addProduct');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SettingsScreen()),
                                    );
                                  }, screenWidth, screenHeight),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: screenWidth * 0.15),
                                    child: _buildButton(
                                        'addProduct',
                                        Icons.edit,
                                        'Add Products',
                                        isPressedAddProduct, () {
                                      _resetAllExcept('addProduct');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProductListScreen()),
                                      );
                                    }, screenWidth, screenHeight),
                                  ),
                                  _buildButton('addMedia', Icons.add_a_photo,
                                      'Add Media', isPressedAddMedia, () {
                                    _resetAllExcept('addMedia');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Addmediascreen()),
                                    );
                                  }, screenWidth, screenHeight),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02),
                  child: Column(
                    children: [
                      const Text(
                        'hushh Platinum™',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: TextButton(
                          onPressed: () {
                            // Action for the platinum button
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromRGBO(233, 235, 238, 1)),
                          ),
                          child: Text(
                            'Get hushh Platinum™',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 80, 9, 148),
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String label,
      IconData icon,
      String buttonText,
      bool isPressed,
      VoidCallback onTap,
      double screenWidth,
      double screenHeight) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isPressed ? Colors.white : Colors.grey,
            size: screenWidth * 0.08,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            buttonText,
            style: TextStyle(
              color: isPressed ? Colors.white : Colors.grey,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 100);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 100);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
