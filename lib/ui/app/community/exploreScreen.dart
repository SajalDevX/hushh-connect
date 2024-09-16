import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hushhxtinder/data/models/community_model.dart';
import 'package:hushhxtinder/ui/app/community/detail/communityDetail.dart';
import 'package:hushhxtinder/ui/app/community/communityViewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late CommunityViewModel _communityViewModel;

  @override
  void initState() {
    super.initState();
    _communityViewModel = CommunityViewModel(Supabase.instance.client);
  }

  void _showCommunityDetails(Community community) async {
    bool isMember = await _communityViewModel.isUserInCommunity(community.id);

    if (isMember) {
      // Navigate to the detail screen with a slide-up transition
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return CommunityDetailScreen(
                communityId: community.id, communityName: community.name);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    } else {
      // Show the join community widget
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(0),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    community.image,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        community.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        community.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            // isLoading = true;
                          });
                          try {
                            await _communityViewModel
                                .joinCommunity(community.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'You have joined ${community.name}!')),
                            );

                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return CommunityDetailScreen(
                                    communityId: community.id,
                                    communityName: community.name,
                                  );
                                },
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error joining community: $e')),
                            );
                          } finally {
                            setState(() {
                              // isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'JOIN NOW',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the modal
                        },
                        child: const Text(
                          'NO THANKS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      "lib/assets/images/huash_logo_2.svg",
                      height: 28,
                      width: 28,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Image.asset(
                          "lib/assets/images/notify_topbar.png",
                          height: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<List<Community>>(
                stream: _communityViewModel.streamAllCommunities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.hasData) {
                    final communities = snapshot.data!;
                    return GridView.builder(
                      itemCount: communities.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final community = communities[index];
                        return GestureDetector(
                          onTap: () {
                            _showCommunityDetails(community);
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                image: DecorationImage(
                                  image: NetworkImage(community.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  community.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No communities found.'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
