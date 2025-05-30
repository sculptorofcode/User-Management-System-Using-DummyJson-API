import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user.dart';
import '../repositories/post_repository.dart';
import '../screens/create_post_screen.dart';
import '../utils/api_client.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CreatePostScreen(userId: widget.user.id),
                ),
              );

              if (result != null && mounted) {
                // Refresh the screen to show the new post
                setState(() {});
              }
            },
            tooltip: 'Create Post',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Posts'),
            Tab(text: 'Todos'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          context.read<PostRepository>().getUserPosts(widget.user.id),
          ApiClient().fetchUserTodos(widget.user.id),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            final posts = snapshot.data![0];
            final todos = snapshot.data![1];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildUserProfileDetails(context),
                _buildPostsList(posts),
                _buildTodosList(todos),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildUserProfileDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header with avatar and basic info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar-${widget.user.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.user.avatar,
                      placeholder:
                          (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 50),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, size: 50),
                          ),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.user.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Personal Information Section
          _buildSectionHeader(context, 'Personal Information'),
          _buildInfoCard(context, [
            _buildInfoItem('Username', widget.user.username),
            _buildInfoItem(
              'Full Name',
              '${widget.user.firstName} ${widget.user.lastName}',
            ),
            if (widget.user.maidenName?.isNotEmpty == true)
              _buildInfoItem('Maiden Name', widget.user.maidenName!),
            _buildInfoItem('Gender', widget.user.gender),
            _buildInfoItem('Age', widget.user.age.toString()),
            _buildInfoItem('Birth Date', widget.user.birthDate),
            _buildInfoItem('Blood Group', widget.user.bloodGroup),
            _buildInfoItem('Height', '${widget.user.height} cm'),
            _buildInfoItem('Weight', '${widget.user.weight} kg'),
            _buildInfoItem('Eye Color', widget.user.eyeColor),
            if (widget.user.hair != null)
              _buildInfoItem(
                'Hair',
                '${widget.user.hair!.color} ${widget.user.hair!.type}',
              ),
          ]),

          const SizedBox(height: 24),

          // Contact Information Section
          _buildSectionHeader(context, 'Contact Information'),
          _buildInfoCard(context, [
            _buildInfoItem('Email', widget.user.email),
            _buildInfoItem('Phone', widget.user.phone),
            _buildInfoItem('IP Address', widget.user.ip),
            _buildInfoItem('MAC Address', widget.user.macAddress),
          ]),

          const SizedBox(height: 24),

          // Address Section
          if (widget.user.address != null) ...[
            _buildSectionHeader(context, 'Address'),
            _buildInfoCard(context, [
              _buildInfoItem('Street', widget.user.address!.address),
              _buildInfoItem('City', widget.user.address!.city),
              _buildInfoItem('State', widget.user.address!.state),
              _buildInfoItem('Postal Code', widget.user.address!.postalCode),
              _buildInfoItem('Country', widget.user.address!.country),
              _buildInfoItem(
                'Coordinates',
                'Lat: ${widget.user.address!.coordinates.lat}, Lng: ${widget.user.address!.coordinates.lng}',
              ),
            ]),
            const SizedBox(height: 24),
          ],

          // Education Section
          _buildSectionHeader(context, 'Education'),
          _buildInfoCard(context, [
            _buildInfoItem('University', widget.user.university),
          ]),

          const SizedBox(height: 24),

          // Company Information Section
          if (widget.user.company != null) ...[
            _buildSectionHeader(context, 'Company Information'),
            _buildInfoCard(context, [
              _buildInfoItem('Company Name', widget.user.company!.name),
              _buildInfoItem('Department', widget.user.company!.department),
              _buildInfoItem('Title', widget.user.company!.title),
              if (widget.user.company!.address != null) ...[
                _buildInfoItem(
                  'Work Address',
                  widget.user.company!.address!.address,
                ),
                _buildInfoItem('Work City', widget.user.company!.address!.city),
                _buildInfoItem(
                  'Work Country',
                  widget.user.company!.address!.country,
                ),
              ],
            ]),
            const SizedBox(height: 24),
          ],

          // Banking Information Section
          if (widget.user.bank != null) ...[
            _buildSectionHeader(context, 'Banking Information'),
            _buildInfoCard(context, [
              _buildInfoItem('Card Type', widget.user.bank!.cardType),
              _buildInfoItem(
                'Card Number',
                _formatCardNumber(widget.user.bank!.cardNumber),
              ),
              _buildInfoItem('Expiration', widget.user.bank!.cardExpire),
              _buildInfoItem('Currency', widget.user.bank!.currency),
              _buildInfoItem('IBAN', widget.user.bank!.iban),
            ]),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> items) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: items,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;

    // Only show the last 4 digits, mask the rest
    final lastFourDigits = cardNumber.substring(cardNumber.length - 4);
    return '•••• •••• •••• $lastFourDigits';
  }

  Widget _buildPostsList(List posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts found'));
    }

    // Sort posts - show local posts first
    final sortedPosts = List.from(posts)..sort((a, b) {
      final isALocal = a['isLocal'] == true;
      final isBLocal = b['isLocal'] == true;
      if (isALocal && !isBLocal) return -1;
      if (!isALocal && isBLocal) return 1;
      return 0;
    });

    return ListView.builder(
      itemCount: sortedPosts.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final post = sortedPosts[index];
        final isLocal = post['isLocal'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Add a light accent color for local posts
          color:
              isLocal
                  ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3)
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post['title'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isLocal)
                      Tooltip(
                        message: 'Local post',
                        child: Icon(
                          Icons.bookmark,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const Divider(),
                Text(
                  post['body'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (isLocal) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Saved locally',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodosList(List todos) {
    if (todos.isEmpty) {
      return const Center(child: Text('No todos found'));
    }

    return ListView.builder(
      itemCount: todos.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              todo['todo'],
              style: TextStyle(
                decoration:
                    todo['completed']
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                color:
                    todo['completed']
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            trailing:
                todo['completed']
                    ? Icon(Icons.check_circle, color: Colors.green[700])
                    : const Icon(Icons.circle_outlined),
          ),
        );
      },
    );
  }
}
