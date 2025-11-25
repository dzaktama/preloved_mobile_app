import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/userModel.dart';
import '../../model/barang_model.dart';
import '../../model/review_model.dart';
import '../../controller/user_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/chat_controller.dart';
import '../chat/chat_room_page.dart';

class SellerProfilePage extends StatefulWidget {
  final int sellerId;

  const SellerProfilePage({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  final AuthController _authController = AuthController();
  final ChatController _chatController = ChatController();

  UserModel? _seller;
  List<BarangJualanModel> _products = [];
  List<ReviewModel> _reviews = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  int? _currentUserId;

  late TabController _tabController;

  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final currentUser = await _authController.getUserLogin();
    _currentUserId = currentUser?.id;

    final seller = await _userController.getUserById(widget.sellerId);
    final products = await _userController.getUserProducts(widget.sellerId);
    final reviews = await _userController.getUserReviews(widget.sellerId);
    final stats = await _userController.getUserStatistics(widget.sellerId);

    setState(() {
      _seller = seller;
      _products = products;
      _reviews = reviews;
      _statistics = stats;
      _isLoading = false;
    });
  }

  Future<void> _openChat() async {
    if (_currentUserId == null) return;

    final chatRoom = await _chatController.getOrCreateChatRoom(
      _currentUserId!,
      widget.sellerId,
    );

    if (chatRoom != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomPage(
            chatRoomId: chatRoom.id!,
            otherUserId: widget.sellerId,
            otherUserName: _seller?.uName ?? 'User',
            otherUserPhoto: _seller?.uFotoProfil,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_seller == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildProfileImage(),
                      const SizedBox(height: 12),
                      Text(
                        _seller?.uName ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${_seller?.ratingDisplay ?? '0.0'} (${_seller?.totalReviewsDisplay ?? '0'} reviews)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Products', '${_statistics['products'] ?? 0}'),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem('Sold', '${_statistics['sold'] ?? 0}'),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem('Response Rate', _seller?.responseRateDisplay ?? '100%'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bio
                  if (_seller?.bio != null && _seller!.bio!.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _seller!.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  if (_currentUserId != widget.sellerId)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openChat,
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: textLight,
                indicatorColor: primaryColor,
                tabs: const [
                  Tab(text: 'Products'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_seller?.uFotoProfil != null && _seller!.uFotoProfil!.isNotEmpty) {
      if (_seller!.uFotoProfil!.startsWith('http')) {
        return CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(_seller!.uFotoProfil!),
          backgroundColor: Colors.white,
        );
      } else {
        return CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(File(_seller!.uFotoProfil!)),
          backgroundColor: Colors.white,
        );
      }
    }
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: Text(
        _seller?.uName?.substring(0, 1).toUpperCase() ?? 'U',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No products yet',
              style: TextStyle(fontSize: 16, color: textLight),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(BarangJualanModel product) {
    return InkWell(
      onTap: () {
        // Navigate to product detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(product.pathGambar),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: const TextStyle(fontSize: 10, color: textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.namaBarang,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.harga,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 80, color: textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No reviews yet',
              style: TextStyle(fontSize: 16, color: textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return _buildReviewCard(_reviews[index]);
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                  review.buyerName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.buyerName ?? 'User',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.createdAtDateTime != null
                              ? DateFormat('dd MMM yyyy').format(review.createdAtDateTime!)
                              : '',
                          style: const TextStyle(fontSize: 11, color: textLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.reviewText!,
              style: const TextStyle(
                fontSize: 13,
                color: textDark,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}