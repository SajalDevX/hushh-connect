// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/card_model.dart';
import 'package:hushhxtinder/ui/app/home/homeViewmodel.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CurrentUserProfile extends StatefulWidget {
  const CurrentUserProfile(
      {super.key, required this.CardData, required this.onMessageClick});

  final List<ImageData> CardData;
  final VoidCallback onMessageClick;

  @override
  State<CurrentUserProfile> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<CurrentUserProfile> {
  @override
  Widget build(BuildContext context) {
    final ImageData data1 = widget.CardData[0];
    final ImageData data2 = widget.CardData[1];
    final ImageData data3 = widget.CardData[2];
    final List<String> imageUrls = widget.CardData.where((data) =>
            data.imageRes.isNotEmpty) // Null values ko filter karta hai
        .map((data) => data.imageRes)
        .toList();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top fixed title bar
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0, // Height of the top bar
              decoration: BoxDecoration(
                color: const Color(0xff212525),
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      data1.name,
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
                        Navigator.pop(context);
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
          ),
          Positioned.fill(
            top: 120.0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  _buildImagesBox(imageUrls),
                  _buildCompanyInfoBox(data1),
                  _buildExperienceInfoBox(data2),
                  _buildPassionsInfoBox(data3),
                  _buildMessageBox(data1),
                  _buildShareProfileBox(data1),
                  _buildBlockProfileBox(data1),
                  _buildReportProfileBox(data1),
                  const SizedBox(height: 106.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesBox(List<String> imageUrls) {
    final PageController _pageController = PageController();
    int _currentPage = 0;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xff111419),
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
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

  Widget _buildCompanyInfoBox(ImageData data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff09141f),
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Currently working at",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            " ${data.companyName}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceInfoBox(ImageData data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff09141f),
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Experiences",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "${data.description}",
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildPassionsInfoBox(ImageData data) {
    List<dynamic> passions = data.passions;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff09141f),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Passions",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: passions.map((passion) {
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

  Widget _buildMessageBox(ImageData data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff09141f),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Send ${data.name} a message",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            "Increase your chances of getting connected by up to 25%",
            style: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
          TextButton(
            onPressed: widget.onMessageClick,
            child: const Text("Send message"),
          ),
        ],
      ),
    );
  }

  Widget _buildShareProfileBox(ImageData data) {
    return GestureDetector(
      onTap: () {
        String profileLink = 'https://stumato.store/profile/${data.userId}';
        Share.share('Check out this profile: ${data.name}.\n$profileLink');
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff09141f),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Share ${data.name}'s Profile",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockProfileBox(ImageData data) {
    return GestureDetector(
      onTap: () async {
        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xff111419),
              title: const Text(
                "Confirm Block",
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                "Are you sure you want to block ${data.name}?",
                style: const TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirm
                  child: const Text("Block",
                      style:
                          TextStyle(color: Colors.red)), // Block button in red
                ),
              ],
            );
          },
        );

        // If the user confirmed the action, proceed with blocking
        if (confirmed == true) {
          final userDetailViewModel =
              Provider.of<HomeViewModel>(context, listen: false);
          await userDetailViewModel.blockUser(data.userId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff09141f),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Block ${data.name}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportProfileBox(ImageData data) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff09141f),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Report ${data.name}",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
