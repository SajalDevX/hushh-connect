import 'package:flutter/material.dart';
import 'package:hushhxtinder/ui/app/profile/profileViewModel.dart';
import 'package:hushhxtinder/ui/components/customButton.dart';
import 'package:provider/provider.dart';

class Addmediascreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Add Media",
          style: TextStyle(
            color: Colors.white, // Ensure text is visible on black background
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Set color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black, // Set background to black
      body: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          print("Images are:${profileViewModel.imageUrls}");

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: 9, // Limit to 9 items (6 images + add buttons)
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 items per row
                        crossAxisSpacing: 20, // Space between items
                        mainAxisSpacing: 20, // Space between items
                      ),
                      itemBuilder: (context, index) {
                        if (index < profileViewModel.imageUrls.length) {
                          // Show image preview with delete button
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        profileViewModel.imageUrls[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    profileViewModel.removeImage(index);
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 16,
                                    child:
                                        Icon(Icons.close, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Show "Add Media" button if less than 9 items
                          return GestureDetector(
                            onTap: profileViewModel.isLoading
                                ? null // Disable the button while uploading
                                : () {
                                    profileViewModel.addImage();
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors
                                      .white, // Set color for the add icon
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                      height: 20), // Adds extra space between grid and the text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Add a video, pic, or loop to get closer to completing your profile and increase your likes.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                      height:
                          20), // Adds extra space above the Save Profile button
                  SizedBox(
                    width: double.infinity - 120,
                    child: IAgreeButton(
                      text: 'Save Profile',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      size: double.infinity,
                    ),
                  ),
                  const SizedBox(
                      height: 32), // Additional space at the bottom if needed
                ],
              ),
              // Progress indicator overlay while uploading
              if (profileViewModel.isLoading)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.5), // Semi-transparent overlay
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors
                              .white, // White progress indicator on black background
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
