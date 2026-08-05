import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_widgets.dart';
import '../auth/login_screen.dart';
import '../common/chat_message_screen.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  String _selectedLanguage = 'English';
  bool _darkMode = true;
  bool _pushNotifications = true;
  bool _smsAlerts = true;

  void _showWalletModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("RentX Wallet & Cards", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Text("VERIFIED", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF264067), Color(0xFF132238)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Available Balance", style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("Rs. 12,450.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Top-up portal opened")));
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(90, 40)),
                    child: const Text("+ Top Up"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Saved Payment Methods", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite)),
            const SizedBox(height: 12),
            _cardRow(Icons.credit_card_rounded, "Visa ending in •••• 4289", "Expires 08/28"),
            _cardRow(Icons.account_balance_wallet_rounded, "LankaPay QR / FriMi", "Default Payment"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _cardRow(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }

  void _showLanguageModal() {
    final langs = ['English', 'Sinhala (සිංහල)', 'Tamil (தமிழ்)'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select App Language", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
            const SizedBox(height: 16),
            ...langs.map((l) => ListTile(
                  title: Text(l, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
                  trailing: _selectedLanguage == l.split(' ')[0] ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() => _selectedLanguage = l.split(' ')[0]);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Language updated to $_selectedLanguage")));
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNotificationsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Notification Preferences", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Trip Status Notifications", style: TextStyle(color: AppColors.textWhite)),
                subtitle: const Text("Receive alerts for pickup, drop-off, and inspection", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                value: _pushNotifications,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setModalState(() => _pushNotifications = val);
                  setState(() => _pushNotifications = val);
                },
              ),
              SwitchListTile(
                title: const Text("SMS & WhatsApp Alerts", style: TextStyle(color: AppColors.textWhite)),
                subtitle: const Text("Receive driver contacts and QR keys via SMS", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                value: _smsAlerts,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setModalState(() => _smsAlerts = val);
                  setState(() => _smsAlerts = val);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Cover Photo & Profile Avatar Header
              SliverToBoxAdapter(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E324E), Color(0xFF0F1826)],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 40,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.shield_rounded, color: AppColors.success, size: 14),
                                      SizedBox(width: 4),
                                      Text("Sri Lanka DL Verified", style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                    // Avatar
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.cardDark,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                        child: user?.profileImage == null
                            ? Text(
                                user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. User info & Completion bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        user?.name ?? "Kamal Silva",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? "kamal.silva@rentx.lk",
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const VerifiedBadge(text: "National ID Verified"),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Level 2 Explorer • 420 pts",
                              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Profile Completion Progress Bar (85%)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Profile Completion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite)),
                                Text("85% Complete", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: const LinearProgressIndicator(
                                value: 0.85,
                                backgroundColor: AppColors.backgroundDark,
                                color: AppColors.primary,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Add emergency contact number to reach 100% and unlock instant bookings.",
                              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Referral Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.cardDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.card_giftcard_rounded, color: AppColors.textDark, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Invite Friends, Get Rs. 2,000",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Share code RENTX-KAMAL with friends for island rentals.",
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Referral code RENTX-KAMAL copied!")),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 4. Menu Actions
                      _menuSectionHeader("PAYMENT & REWARDS"),
                      _menuTile(
                        icon: Icons.account_balance_wallet_rounded,
                        title: "RentX Wallet & Saved Cards",
                        subtitle: "Balance: Rs. 12,450.00",
                        onTap: _showWalletModal,
                      ),
                      _menuTile(
                        icon: Icons.stars_rounded,
                        title: "Loyalty Rewards Club",
                        subtitle: "420 Points available to redeem",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Redeem 400 pts for free GPS upgrade!")),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      _menuSectionHeader("SETTINGS & SUPPORT"),
                      _menuTile(
                        icon: Icons.notifications_rounded,
                        title: "Notification Preferences",
                        subtitle: "Push alerts & WhatsApp updates",
                        onTap: _showNotificationsModal,
                      ),
                      _menuTile(
                        icon: Icons.language_rounded,
                        title: "App Language",
                        subtitle: _selectedLanguage,
                        onTap: _showLanguageModal,
                      ),
                      _menuTile(
                        icon: _darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: "Dark Luxury Theme",
                        subtitle: "Permanent OLED dark theme",
                        trailing: Switch(
                          value: _darkMode,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _darkMode = val),
                        ),
                        onTap: () {},
                      ),
                      _menuTile(
                        icon: Icons.support_agent_rounded,
                        title: "24/7 Live Support Chat",
                        subtitle: "Connect with Sri Lanka concierge agent",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatMessageScreen(
                                partnerName: "RentX Support Team",
                                vehicleTitle: "Customer Service #940",
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      // Sign Out Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          await auth.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                        label: const Text("Sign Out of Account", style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textGrey,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey, size: 14),
      ),
    );
  }
}
