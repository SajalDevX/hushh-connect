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

  bool isPressedSettings = false;

  bool isPressedAddProduct = false;

  bool isPressedAddMedia = false;

  @override
  void initState() {
    super.initState();

    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    _profileFuture = profileViewModel.fetchUser();
  }

  void _resetAllExcept(String button) {
    setState(() {
      if (button == 'settings') {
        isPressedSettings = true;

        isPressedAddProduct = false;

        isPressedAddMedia = false;
      } else if (button == 'addProduct') {
        isPressedSettings = false;

        isPressedAddProduct = true;

        isPressedAddMedia = false;
      } else if (button == 'addMedia') {
        isPressedSettings = false;

        isPressedAddProduct = false;

        isPressedAddMedia = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  height: MediaQuery.of(context).size.height * 0.68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0A0C18),
                        Color(0xFF320A3B),
                      ],
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
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'lib/assets/images/Frame.png',
                                width: 188,
                                height: 188,
                                fit: BoxFit.cover,
                              ),
                              CircleAvatar(
                                radius: 70,
                                backgroundImage: NetworkImage(profile.imageurl),
                              ),
                              Positioned(
                                bottom: -1,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 20),
                                  width: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE54D60),
                                        Color(0xFFA342FF),
                                      ],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(33, 37, 41, 0.3),
                                        blurRadius: 3,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '20% complete',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 28,
                                  color: Color.fromRGBO(233, 235, 238, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                'lib/assets/images/grey_tick.png',
                                width: 24,
                                height: 20,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _resetAllExcept('settings');
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: isPressedSettings
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFFE54D60),
                                                    Color(0xFFA342FF),
                                                  ],
                                                )
                                              : null,
                                          color: isPressedSettings
                                              ? null
                                              : Color(0xFF1A1B1D),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                                102, 110, 123, 1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.settings,
                                          color: isPressedSettings
                                              ? Colors.white
                                              : Color.fromRGBO(
                                                  124, 134, 146, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Settings',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(148, 155, 165, 1),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _resetAllExcept('addProduct');

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductListScreen()),
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: isPressedAddProduct
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFFE54D60),
                                                    Color(0xFFA342FF),
                                                  ],
                                                )
                                              : null,
                                          color: isPressedAddProduct
                                              ? null
                                              : Color(0xFF1A1B1D),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                                102, 110, 123, 1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: isPressedAddProduct
                                              ? Colors.white
                                              : Color.fromRGBO(
                                                  124, 134, 146, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Add Products',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(148, 155, 165, 1),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _resetAllExcept('addMedia');
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: isPressedAddMedia
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFFE54D60),
                                                    Color(0xFFA342FF),
                                                  ],
                                                )
                                              : null,
                                          color: isPressedAddMedia
                                              ? null
                                              : Color(0xFF1A1B1D),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                                102, 110, 123, 1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo,
                                          color: isPressedAddMedia
                                              ? Colors.white
                                              : Color.fromRGBO(
                                                  124, 134, 146, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Add Media',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(148, 155, 165, 1),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 60),
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
                                SizedBox(height: 100),
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
