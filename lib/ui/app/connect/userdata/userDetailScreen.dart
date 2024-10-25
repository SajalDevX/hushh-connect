// ignore_for_file: unnecessary_string_interpolations
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hushhxtinder/data/models/profile_model.dart';
import 'package:hushhxtinder/ui/app/connect/userdata/userViewModel.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class UserProfileDetailScreen extends StatefulWidget {
  const UserProfileDetailScreen(
      {super.key, required this.uid, required this.onMessageClick});

  final String uid;
  final VoidCallback onMessageClick;

  @override
  State<UserProfileDetailScreen> createState() =>
      _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  late Future<ProfileData?> _profileFuture;

  @override
  void initState() {
    super.initState();
    final userDetailViewModel =
        Provider.of<GetUserViewModel>(context, listen: false);
    _profileFuture = userDetailViewModel.fetchUserById(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<ProfileData?>(
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
            final ProfileData profile = snapshot.data!;
            String company = '';
            String experience = '';
            final officeDetails = profile.officeDetails != null
                ? Map<String, dynamic>.from(json.decode(profile.officeDetails!))
                : null;
            company = officeDetails?['company'] ?? '';
            experience = officeDetails?['tasks'] ?? '';

            return Stack(
              children: [
                _buildHeader(profile),

                // Body
                Positioned.fill(
                  top: 120.0,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        _buildImagesBox(profile.images!),
                        _buildCompanyInfoBox(company),
                        _buildExperienceInfoBox(experience),
                        _buildPassionsInfoBox(profile),
                        _buildMessageBox(profile),
                        _buildShareProfileBox(profile),
                        _buildBlockProfileBox(profile),
                        _buildReportProfileBox(profile),
                        const SizedBox(height: 106.0),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(ProfileData profile) {
    return Positioned(
      top: 56,
      left: 0,
      right: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60.0,
        decoration: _containerDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                profile.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {
                  // Try popping the route using Navigator
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                  } else {
                    // If no route to pop, navigate to the main screen
                    context.go('/main');
                  }
                },
                child: Image.asset(
                  'lib/assets/images/arrow-down.png',
                  width: 24.0,
                  height: 24.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesBox(List<String> imageUrls) {
    final PageController _pageController = PageController();
    int _currentPage = 0;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          decoration: _containerDecoration(color: const Color(0xff111419)),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          width: double.infinity,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: 400.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 400.0,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Center(
                              child: Text('Image failed to load',
                                  style: TextStyle(color: Colors.white)));
                        },
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10.0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / imageUrls.length,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyInfoBox(String profile) {
    return _buildInfoBox(
      title: "Currently working at",
      content: profile,
    );
  }

  Widget _buildExperienceInfoBox(String profile) {
    return _buildInfoBox(
      title: "Experiences",
      content: profile,
    );
  }

  Widget _buildPassionsInfoBox(ProfileData profile) {
    return _buildChipBox(
      title: "Passions",
      items: profile.passions!,
    );
  }

  Widget _buildMessageBox(ProfileData profile) {
    return _buildInfoBox(
      title: "Send ${profile.name} a message",
      content: "Increase your chances of getting connected by up to 25%.",
      action: TextButton(
        onPressed: widget.onMessageClick,
        child: const Text("Send message"),
      ),
    );
  }

  Widget _buildShareProfileBox(ProfileData profile) {
    return _buildSimpleActionBox(
      title: "Share ${profile.name}'s Profile",
      onTap: () {
        String profileLink = 'https://stumato.store/profile/${widget.uid}';
        Share.share('Check out this profile: ${profile.name}.\n$profileLink');
      },
    );
  }

  Widget _buildBlockProfileBox(ProfileData profile) {
    return _buildSimpleActionBox(
      title: "Block ${profile.name}",
      textColor: Colors.white, // Set the block button's text to red
      onTap: () async {
        // Show a confirmation dialog before blocking the user
        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor:  const Color(0xff111419),
              title: const Text("Confirm Block",style: TextStyle(color: Colors.white),),
              content: Text("Are you sure you want to block ${profile.name}?",style: const TextStyle(color: Colors.white),),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirm
                  child: const Text("Block", style: TextStyle(color: Colors.red)), // Block button in red
                ),
              ],
            );
          },
        );

        // If the user confirmed the action, proceed with blocking
        if (confirmed == true) {
          final userDetailViewModel =
          Provider.of<GetUserViewModel>(context, listen: false);
          await userDetailViewModel.blockUser(widget.uid);
        }
      },
    );
  }



  Widget _buildReportProfileBox(ProfileData profile) {
    return _buildSimpleActionBox(
      title: "Report ${profile.name}",
      textColor: Colors.red,
    );
  }

  // Utility Methods for Reusable UI Components
  BoxDecoration _containerDecoration({Color color = const Color(0xff09141f)}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String content,
    Widget? action,
  }) {
    return Container(
      decoration: _containerDecoration(),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildChipBox({required String title, required List<String> items}) {
    return Container(
      decoration: _containerDecoration(),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: items.map((passion) {
              return Chip(
                label: Text(passion),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
                backgroundColor: const Color(0xff212525),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionBox({
    required String title,
    Color textColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: _containerDecoration(),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        width: double.infinity,
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
