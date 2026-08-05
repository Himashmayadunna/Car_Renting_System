import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';

class ChatMessageScreen extends StatefulWidget {
  final String partnerName;
  final String vehicleTitle;

  const ChatMessageScreen({
    super.key,
    required this.partnerName,
    required this.vehicleTitle,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isPartnerTyping = false;

  final List<_ChatMsg> _messages = [];

  final List<String> _quickPhrases = [
    "Can you deliver to Colombo Airport?",
    "Is a helmet included with the bike?",
    "Can I extend my trip by 1 day?",
    "I've arrived at the pickup location!",
  ];

  @override
  void initState() {
    super.initState();
    // Default welcome messages
    _messages.add(
      _ChatMsg(
        sender: widget.partnerName,
        text: "Ayubowan! Thank you for your interest in ${widget.vehicleTitle}. How can I help you today?",
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMsg(
          sender: "Me",
          text: text.trim(),
          time: DateTime.now(),
          isMe: true,
        ),
      );
      _msgController.clear();
    });

    _scrollToBottom();
    _simulateAutoReply(text);
  }

  void _simulateAutoReply(String userMsg) {
    setState(() => _isPartnerTyping = true);
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isPartnerTyping = false;
        String reply = "Sure! We can arrange that across Sri Lanka. Let me know your preferred pickup time.";
        if (userMsg.toLowerCase().contains("airport")) {
          reply = "Yes! We provide BIA Colombo Airport delivery for just Rs. 1,500. Our driver will wait at Arrivals.";
        } else if (userMsg.toLowerCase().contains("helmet")) {
          reply = "Yes, 2 sanitized safety helmets are included free of charge with all our scooter and bike rentals!";
        } else if (userMsg.toLowerCase().contains("arrived")) {
          reply = "Great! I'm walking over with the vehicle keys now. See you in 2 minutes!";
        }

        _messages.add(
          _ChatMsg(
            sender: widget.partnerName,
            text: reply,
            time: DateTime.now(),
            isMe: false,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _shareLocation() {
    _sendMessage("📍 Shared Location: BIA Terminal 1 Arrivals, Katunayake, Sri Lanka");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    widget.partnerName.isNotEmpty ? widget.partnerName[0] : "P",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundDark, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.partnerName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                  ),
                  Text(
                    _isPartnerTyping ? "typing..." : "Online • Replies in 10 mins",
                    style: TextStyle(
                      fontSize: 11,
                      color: _isPartnerTyping ? AppColors.primary : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Calling ${widget.partnerName} (+94 77 123 4567)...")),
              );
            },
            icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Vehicle: ${widget.vehicleTitle}")),
              );
            },
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textGrey),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Vehicle Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.cardDark,
              child: Row(
                children: [
                  const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.vehicleTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "VERIFIED HOST",
                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, idx) {
                  final m = _messages[idx];
                  return _buildMessageBubble(m);
                },
              ),
            ),

            if (_isPartnerTyping)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    SizedBox(width: 8),
                    Text("Partner is typing...", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),

            // 3. Quick Phrases Horizontal List
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickPhrases.length,
                itemBuilder: (context, idx) {
                  final phrase = _quickPhrases[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(phrase, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.cardDark,
                      labelStyle: const TextStyle(color: AppColors.textWhite),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      onPressed: () => _sendMessage(phrase),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 4. Input Footer Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _shareLocation,
                    icon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                    tooltip: "Share Location",
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: "Write message to ${widget.partnerName}...",
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.textDark, size: 20),
                      onPressed: () => _sendMessage(_msgController.text),
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

  Widget _buildMessageBubble(_ChatMsg m) {
    return Align(
      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: m.isMe ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(m.isMe ? 18 : 4),
            bottomRight: Radius.circular(m.isMe ? 4 : 18),
          ),
          border: m.isMe ? null : Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.text,
              style: TextStyle(
                color: m.isMe ? AppColors.textDark : AppColors.textWhite,
                fontSize: 14,
                fontWeight: m.isMe ? FontWeight.w600 : FontWeight.normal,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(m.time),
                  style: TextStyle(
                    fontSize: 10,
                    color: m.isMe ? AppColors.textDark.withOpacity(0.7) : AppColors.textGrey,
                  ),
                ),
                if (m.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all_rounded, size: 14, color: AppColors.textDark),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMsg {
  final String sender;
  final String text;
  final DateTime time;
  final bool isMe;

  _ChatMsg({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });
}
