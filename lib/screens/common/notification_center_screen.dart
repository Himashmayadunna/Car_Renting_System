import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../widgets/premium_widgets.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedCategory = 'All';

  final List<_NotificationItem> _items = [
    _NotificationItem(
      id: 'n1',
      title: "Booking Confirmed! 🎉",
      body: "Your trip request #LANKA-89421 for Honda Dio 110 has been confirmed by Lanka Ride Rentals.",
      timeAgo: "2 mins ago",
      category: "Trips",
      isRead: false,
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    ),
    _NotificationItem(
      id: 'n2',
      title: "20% Weekend Promo Code 🌄",
      body: "Use promo code WEEKEND20 to save 20% on all SUV & Hybrid rentals in Ella and Nuwara Eliya this Friday-Sunday.",
      timeAgo: "1 hour ago",
      category: "Promos",
      isRead: false,
      icon: Icons.local_offer_rounded,
      color: AppColors.primary,
    ),
    _NotificationItem(
      id: 'n3',
      title: "Driving License Verification Passed",
      body: "Your Sri Lanka National Identity Card & Driving License verification is complete. You can now book cars instantly.",
      timeAgo: "1 day ago",
      category: "System",
      isRead: true,
      icon: Icons.verified_user_rounded,
      color: AppColors.accentBlue,
    ),
    _NotificationItem(
      id: 'n4',
      title: "Trip Reminder: Tomorrow at 10:00 AM",
      body: "Don't forget your scheduled pickup for Toyota Prius Hybrid at Colombo 03.",
      timeAgo: "2 days ago",
      category: "Trips",
      isRead: true,
      icon: Icons.access_time_filled_rounded,
      color: AppColors.primary,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (var item in _items) {
        item.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read"), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _items
        : _items.where((item) => item.category == _selectedCategory).toList();

    final unreadCount = _items.where((i) => !i.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Notification Center"),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$unreadCount new",
                  style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text("Mark read", style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Category Selector Pills
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: ['All', 'Trips', 'Promos', 'System'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? AppColors.textDark : AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. Notifications List
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateIllustration(
                    icon: Icons.notifications_off_rounded,
                    title: "No $_selectedCategory Notifications",
                    description: "You're all caught up! No recent alerts in this category.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem item) {
    return GestureDetector(
      onTap: () {
        setState(() => item.isRead = true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.cardDark : AppColors.cardDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isRead ? Colors.white.withOpacity(0.06) : AppColors.primary.withOpacity(0.6),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: item.isRead
              ? null
              : [
                  BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: item.isRead ? AppColors.textWhite : AppColors.textWhite,
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      color: item.isRead ? AppColors.textGrey : AppColors.textGreyLight,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.timeAgo,
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                      ),
                      Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          color: item.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

class _NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final String category;
  bool isRead;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.category,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}
