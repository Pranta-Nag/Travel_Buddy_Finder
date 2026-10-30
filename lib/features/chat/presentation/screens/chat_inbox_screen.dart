import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/chat/presentation/screens/chat_room_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchChatRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final int unreadTotal = chatProvider.totalUnreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            if (unreadTotal > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadTotal > 99 ? '99+' : '$unreadTotal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
            onPressed: () => chatProvider.fetchChatRooms(silent: true),
            tooltip: 'Refresh conversations',
          ),
        ],
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: chatProvider.roomsStream,
        initialData: chatProvider.chatRooms,
        builder: (context, snapshot) {
          if (chatProvider.isLoading &&
              (snapshot.data == null || snapshot.data!.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allRooms = snapshot.data ?? [];

          // Filter by search query if any
          final rooms = _searchQuery.isEmpty
              ? allRooms
              : allRooms.where((r) {
                  final q = _searchQuery.toLowerCase();
                  return r.partnerName.toLowerCase().contains(q) ||
                      r.tripTitle.toLowerCase().contains(q) ||
                      r.lastMessage.toLowerCase().contains(q);
                }).toList();

          if (allRooms.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => chatProvider.fetchChatRooms(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 46,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Connect with hosts or buddies from any trip to start chatting in real time!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar (Messenger style)
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search chats or tour titles...',
                      hintStyle: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 16, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Conversation List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => chatProvider.fetchChatRooms(),
                  child: rooms.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 60),
                            Center(
                              child: Text(
                                'No matching conversations found',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          itemCount: rooms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return _buildMessengerChatCard(
                              context,
                              room,
                              chatProvider,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessengerChatCard(
    BuildContext context,
    ChatRoomModel room,
    ChatProvider chatProvider,
  ) {
    final avatarProvider = AppUrl.imageProvider(room.partnerAvatarUrl);
    final bool hasUnread = room.hasUnread == true;
    final int safeUnseen = room.unseenCount;
    final bool isMine = room.isLastMessageMine == true;
    final bool isSeen = room.isLastMessageSeen == true;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                roomId: room.roomId,
                partnerName: room.partnerName,
                partnerAvatarUrl: room.partnerAvatarUrl,
                tripTitle: room.tripTitle,
              ),
            ),
          ).then((_) {
            // Re-fetch chat rooms to update read status immediately
            chatProvider.fetchChatRooms(silent: true);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasUnread
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : const Color(0xFFF1F5F9),
              width: hasUnread ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Messenger-Style Partner Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasUnread
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    padding: EdgeInsets.all(hasUnread ? 1.5 : 0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      backgroundImage: avatarProvider,
                      onBackgroundImageError: avatarProvider != null
                          ? (_, __) {}
                          : null,
                      child: avatarProvider == null
                          ? Text(
                              room.partnerName.isNotEmpty
                                  ? room.partnerName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // 2. Messenger Content Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line 1: Partner Name & Last Message Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            room.partnerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: hasUnread
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          room.formattedLastTime,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: hasUnread
                                ? AppColors.primary
                                : const Color(0xFF94A3B8),
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Line 2: Tour Title Pill
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.luggage_rounded,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    room.tripTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Line 3: Last Message Content (Under Tour Title) + Read/Unread Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.lastMessage.isEmpty
                                ? 'Tap to start conversation'
                                : (room.isLastMessageMine
                                    ? 'You: ${room.lastMessage}'
                                    : room.lastMessage),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: hasUnread
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B),
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Read / Unread Status Indicator
                        if (hasUnread)
                          // Unread Badge Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              safeUnseen > 99
                                  ? '99+'
                                  : '$safeUnseen',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        else if (isMine && room.lastMessage.isNotEmpty)
                          // Read Receipt for My Sent Messages
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSeen
                                    ? Icons.done_all_rounded
                                    : Icons.check_rounded,
                                size: 14,
                                color: isSeen
                                    ? AppColors.primary
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                isSeen ? 'Seen' : 'Sent',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSeen
                                      ? AppColors.primary
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
