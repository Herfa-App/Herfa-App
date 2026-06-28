import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// ─── Data model for a single message ─────────────────────────────────────────
enum MessageType { text, image, voice }

class ChatMessage {
  final String id;
  final String text;
  final bool isOutgoing;
  final MessageType type;
  final String time;
  final bool isRead;

  ChatMessage({
    required this.id,
    this.text = '',
    required this.isOutgoing,
    this.type = MessageType.text,
    required this.time,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) => ChatMessage(
        id: id,
        text: text,
        isOutgoing: isOutgoing,
        type: type,
        time: time,
        isRead: isRead ?? this.isRead,
      );
}

// ─── Chat Screen ──────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  bool _isRecording = false;
  bool _showSendButton = false;

  // Static initial messages that look like history
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'السلام عليكم أخي، أنا الآن في الطريق إليك. هل الموقع المسجل في الطلب دقيق؟',
      isOutgoing: false,
      type: MessageType.text,
      time: '10:30 ص',
      isRead: true,
    ),
    ChatMessage(
      id: '2',
      text: 'وعليكم السلام. نعم، الموقع دقيق جداً. سأرفق لك صورة لباب العمارة ليسهل عليك الوصول.',
      isOutgoing: true,
      type: MessageType.text,
      time: '10:32 ص',
      isRead: true,
    ),
    ChatMessage(
      id: '3',
      text: '',
      isOutgoing: true,
      type: MessageType.image,
      time: '10:33 ص',
      isRead: true,
    ),
    ChatMessage(
      id: '4',
      text: '',
      isOutgoing: false,
      type: MessageType.voice,
      time: '10:35 ص',
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.addListener(_onTextChanged);
    // scroll to bottom after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Scroll up when keyboard opens
  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _showSendButton) {
      setState(() => _showSendButton = hasText);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'م' : 'ص';
    return '$h:$m $ampm';
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isOutgoing: true,
        type: MessageType.text,
        time: _nowTime(),
        isRead: false,
      ));
      _textController.clear();
      _showSendButton = false;
    });

    _scrollToBottom();

    // Simulate reply after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'حسناً، شكراً جزيلاً. سأصل خلال دقائق.',
          isOutgoing: false,
          type: MessageType.text,
          time: _nowTime(),
          isRead: false,
        ));
      });
      _scrollToBottom();
    });
  }

  void _toggleRecording() {
    HapticFeedback.mediumImpact();
    setState(() => _isRecording = !_isRecording);

    if (_isRecording) {
      // stop recording → add voice message
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: '',
            isOutgoing: true,
            type: MessageType.voice,
            time: _nowTime(),
          ));
        });
        _scrollToBottom();
      });
    }
  }

  void _sendImageMessage() {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        isOutgoing: true,
        type: MessageType.image,
        time: _nowTime(),
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(context),

            // ── Status banner ──
            _buildStatusBanner(),

            // ── Messages list ──
            Expanded(
              child: GestureDetector(
                onTap: () => _focusNode.unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: _messages.length + 1, // +1 for date separator
                  itemBuilder: (ctx, i) {
                    if (i == 0) return _buildDateSeparator('اليوم');
                    final msg = _messages[i - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMessageBubble(msg),
                    );
                  },
                ),
              ),
            ),

            // ── Typing indicator ──
            if (_isTyping) _buildTypingIndicator(),

            // ── Input bar ──
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.textPrimary, size: 16),
            ),
          ),

          const Spacer(),

          // Name + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('أحمد محمد',
                  style: AppTextStyles.headlineSmall
                      .copyWith(fontSize: 16),
                  textDirection: TextDirection.rtl),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.greenAvailable,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('نشط الآن',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.greenAvailable)),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Avatar
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person,
                size: 22, color: AppColors.textLight),
          ),

          // Call
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.phone_outlined,
                  color: AppColors.primary, size: 18),
            ),
          ),

          // More
          GestureDetector(
            onTap: () => _showMoreOptions(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              _sheetItem(Icons.block_outlined, 'حظر المستخدم', AppColors.error),
              _sheetItem(Icons.report_outlined, 'إبلاغ عن مشكلة',
                  AppColors.textSecondary),
              _sheetItem(Icons.delete_outline, 'حذف المحادثة',
                  AppColors.textSecondary),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetItem(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      onTap: () => Navigator.pop(context),
    );
  }

  // ── Status Banner ───────────────────────────────────────────────────────────
  Widget _buildStatusBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Truck icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping,
                    color: AppColors.textWhite, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('12 دقيقة',
                          style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent)),
                    ),
                    const SizedBox(width: 8),
                    Text('الحرفي في الطريق',
                        style: AppTextStyles.titleSmall,
                        textDirection: TextDirection.rtl),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.65,
              backgroundColor: AppColors.accent.withOpacity(0.2),
              color: AppColors.accent,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Separator ──────────────────────────────────────────────────────────
  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  // ── Message Bubble dispatcher ───────────────────────────────────────────────
  Widget _buildMessageBubble(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.text:
        return msg.isOutgoing
            ? _buildOutgoing(msg)
            : _buildIncoming(msg);
      case MessageType.image:
        return _buildImageBubble(msg);
      case MessageType.voice:
        return _buildVoiceBubble(msg);
    }
  }

  // ── Incoming text ───────────────────────────────────────────────────────────
  Widget _buildIncoming(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColors.shadow.withOpacity(0.06),
                    blurRadius: 6)
              ],
            ),
            child: Text(msg.text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary, height: 1.5),
                textDirection: TextDirection.rtl),
          ),
          const SizedBox(height: 4),
          Text(msg.time, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  // ── Outgoing text ───────────────────────────────────────────────────────────
  Widget _buildOutgoing(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(msg.text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textWhite, height: 1.5),
                textDirection: TextDirection.rtl),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                msg.isRead ? Icons.done_all : Icons.done,
                size: 14,
                color: msg.isRead
                    ? const Color(0xFF4FC3F7)
                    : AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(msg.time, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image bubble ────────────────────────────────────────────────────────────
  Widget _buildImageBubble(ChatMessage msg) {
    return Align(
      alignment:
          msg.isOutgoing ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: msg.isOutgoing
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 220,
              height: 150,
              color: const Color(0xFF2A3A4A),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.image_outlined,
                      size: 48, color: Colors.white24),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('صورة',
                          style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.isOutgoing) ...[
                Icon(
                  msg.isRead ? Icons.done_all : Icons.done,
                  size: 14,
                  color: msg.isRead
                      ? const Color(0xFF4FC3F7)
                      : AppColors.textLight,
                ),
                const SizedBox(width: 4),
              ],
              Text(msg.time, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  // ── Voice bubble ────────────────────────────────────────────────────────────
  Widget _buildVoiceBubble(ChatMessage msg) {
    return Align(
      alignment:
          msg.isOutgoing ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: msg.isOutgoing
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isOutgoing
                  ? AppColors.primary
                  : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.shadow.withOpacity(0.06),
                    blurRadius: 6)
              ],
            ),
            child: Row(
              children: [
                // Play button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: msg.isOutgoing
                          ? AppColors.backgroundWhite.withOpacity(0.2)
                          : AppColors.backgroundGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow,
                        color: msg.isOutgoing
                            ? AppColors.textWhite
                            : AppColors.primary,
                        size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                // Waveform
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(14, (i) {
                          const heights = [
                            14.0, 8, 18, 6, 22, 10, 16,
                            20, 8, 24, 12, 16, 8, 14
                          ];
                          final h = heights[i % heights.length];
                          final barColor = msg.isOutgoing
                              ? (i < 8
                                  ? AppColors.textWhite
                                  : AppColors.textWhite.withOpacity(0.4))
                              : (i < 8
                                  ? AppColors.primary
                                  : AppColors.border);
                          return Container(
                            width: 3,
                            // height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('0:24',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: msg.isOutgoing
                                    ? AppColors.textWhite.withOpacity(0.8)
                                    : AppColors.textLight)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.isOutgoing) ...[
                Icon(
                  msg.isRead ? Icons.done_all : Icons.done,
                  size: 14,
                  color: msg.isRead
                      ? const Color(0xFF4FC3F7)
                      : AppColors.textLight,
                ),
                const SizedBox(width: 4),
              ],
              Text(msg.time, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  // ── Typing indicator ────────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow.withOpacity(0.06), blurRadius: 6)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.textLight,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Input Bar ───────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Left: Mic OR Send button ──────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _showSendButton
                // SEND button
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: _sendMessage,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: AppColors.textWhite, size: 22),
                    ),
                  )
                // MIC button (hold to record)
                : GestureDetector(
                    key: const ValueKey('mic'),
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppColors.error
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: AppColors.textWhite,
                        size: 22,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          // ── Center: text field ────────────────────────────────────────────
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 46, maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attach / image picker
                  GestureDetector(
                    onTap: _sendImageMessage,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.textSecondary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Actual text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: _isRecording
                            ? 'جاري التسجيل...'
                            : 'اكتب رسالة...',
                        hintStyle: AppTextStyles.hintStyle,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        filled: false,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Extras menu
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: const Icon(Icons.add_circle_outline,
                          color: AppColors.textSecondary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
