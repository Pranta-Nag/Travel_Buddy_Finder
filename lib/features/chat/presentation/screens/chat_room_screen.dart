import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/models/message_model.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String partnerName;
  final String? partnerAvatarUrl;
  final String? tripTitle;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.partnerName,
    this.partnerAvatarUrl,
    this.tripTitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().enterChatRoom(widget.roomId);
    });
  }

  void _onTextChanged() {
    final hasContent = _textController.text.trim().isNotEmpty;
    if (hasContent != _hasText) {
      setState(() {
        _hasText = hasContent;
      });
    }
  }

  @override
  void dispose() {
    context.read<ChatProvider>().exitChatRoom();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom([bool animated = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final target = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuad,
          );
        } else {
          _scrollController.jumpTo(target);
        }
      }
    });
  }

  void _handleSend([String? textToSend]) async {
    final text = (textToSend ?? _textController.text).trim();
    if (text.isEmpty) return;

    _textController.clear();
    final chatProvider = context.read<ChatProvider>();
    final success = await chatProvider.sendMessage(widget.roomId, text);
    _scrollToBottom(true);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to send message. Please retry."),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final partnerAvatar = AppUrl.imageProvider(widget.partnerAvatarUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primarySoft,
                          backgroundImage: partnerAvatar,
                          onBackgroundImageError:
                              partnerAvatar != null ? (_, __) {} : null,
                          child: partnerAvatar == null
                              ? Text(
                                  widget.partnerName.isNotEmpty
                                      ? widget.partnerName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.partnerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 1),
                        if (widget.tripTitle != null && widget.tripTitle!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.luggage_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.tripTitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            "Online • Travel Companion",
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.greyText,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<ChatProvider>().fetchMessages(
                            widget.roomId,
                            silent: true,
                          );
                    },
                    tooltip: 'Refresh messages',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: chatProvider.messageStream,
                initialData: chatProvider.messages,
                builder: (context, snapshot) {
                  if (chatProvider.isLoading &&
                      (snapshot.data == null || snapshot.data!.isEmpty)) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return _buildEmptyConversationState();
                  }

                  // Auto scroll on new messages
                  _scrollToBottom(false);

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg.isMe;

                      return _ChatBubble(
                        message: msg,
                        isMe: isMe,
                        partnerAvatar: partnerAvatar,
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyConversationState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primarySoft, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Say hello to ${widget.partnerName}! 👋',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ask about itinerary details, packing tips, or meet-up locations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'QUICK CONVERSATION STARTERS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _starterChip("👋 Hey! Excited to travel together!"),
              _starterChip("🗓️ What's our planned daily schedule?"),
              _starterChip("📍 Where should we meet up first?"),
              _starterChip("🎒 Any specific gear I should pack?"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starterChip(String text) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
          _focusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fieldColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _hasText
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [
                          AppColors.primary.withValues(alpha: 0.6),
                          AppColors.primaryDark.withValues(alpha: 0.6),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: _hasText
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final ImageProvider? partnerAvatar;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    this.partnerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('msg-anim-${message.messageId}'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.88 + (0.12 * animValue),
          alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: partnerAvatar,
                onBackgroundImageError:
                    partnerAvatar != null ? (_, __) {} : null,
                child: partnerAvatar == null
                    ? Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.74,
                ),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe ? null : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: isMe
                      ? null
                      : Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? AppColors.primary.withValues(alpha: 0.22)
                          : const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: isMe ? 8 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.messageText,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        height: 1.38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.formattedTime,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.seenStatus
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 13,
                            color: message.seenStatus
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.75),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
