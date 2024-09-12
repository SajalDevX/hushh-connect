import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:hushhxtinder/ui/app/connect/connectViewModel.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Initialize TabController
    final connectViewModel =
        Provider.of<ConnectViewModel>(context, listen: false);

    // Fetch data for all sections when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectViewModel>().fetchFollowingUsers();
    });
    connectViewModel.fetchFollowers();
    connectViewModel.fetchMutualUsers();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectViewModel = Provider.of<ConnectViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Column(
            children: [
              // Top Bar with Logo
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    ],
                  ),
                ),
              ),
              // TabBar for User List Sections
              Container(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.amber,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Mutual'),
                    Tab(text: 'Following'),
                    Tab(text: 'Followers'),
                  ],
                ),
              ),
              // TabBarView for displaying the content of each section
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserSection(
                      users: connectViewModel.mutualUsers,
                      isLoading: connectViewModel.isLoadingMutual,
                    ),
                    _buildUserSection(
                      users: connectViewModel.followingUsers,
                      isLoading: connectViewModel.isLoadingFollowing,
                    ),
                    _buildUserSection(
                      users: connectViewModel.followers,
                      isLoading: connectViewModel.isLoadingFollowers,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build User Section (mutual, following, or followers)
  Widget _buildUserSection({
    required List<Map<String, dynamic>> users,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(
                            user['username'] ?? 'User',
                            style: const TextStyle(color: Colors.white),
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(user['avatar_url'] ?? ''),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
