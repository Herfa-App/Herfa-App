import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

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
}

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

  String? _conversationId;
  String? _targetUserId;
  String? _targetName;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.addListener(_onTextChanged);
    _currentUserId = SupabaseService.instance.client.auth.currentUser?.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _targetUserId = args?['target_user_id'] ?? 'dbca732c-7b3b-4c07-b2f5-b98a12bc3abc'; // fallback default target
    _targetName = args?['target_name'] ?? 'أحمد محمد (متاح)';

    if (_currentUserId != null && _targetUserId != null) {
      _conversationId = _currentUserId!.compareTo(_targetUserId!) < 0
          ? '${_currentUserId}_$_targetUserId'
          : '${_targetUserId}_$_currentUserId';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final h = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? 12 : dateTime.hour;
      final m = dateTime.minute.toString().padLeft(2, '0');
      final ampm = dateTime.hour >= 12 ? 'م' : 'ص';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _targetUserId == null) return;

    _textController.clear();
    setState(() => _showSendButton = false);

    try {
      await SupabaseService.instance.sendMessage(
        receiverId: _targetUserId!,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة: ${e.toString()}', textAlign: TextAlign.right)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول أولاً لتصفح الرسائل')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStatusBanner(),
            Expanded(
              child: GestureDetector(
                onTap: () => _focusNode.unfocus(),
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _conversationId != null
                      ? SupabaseService.instance.streamMessages(_conversationId!)
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('حدث خطأ أثناء تحميل الرسائل: ${snapshot.error}'));
                    }

                    final data = snapshot.data ?? [];
                    final messages = data.map((m) {
                      final isOutgoing = m['sender_id'] == _currentUserId;
                      final typeStr = m['type'] ?? 'text';
                      final type = typeStr == 'image'
                          ? MessageType.image
                          : typeStr == 'voice'
                              ? MessageType.voice
                              : MessageType.text;

                      return ChatMessage(
                        id: m['id'] ?? '',
                        text: m['text'] ?? '',
                        isOutgoing: isOutgoing,
                        type: type,
                        time: _formatTime(m['created_at']),
                        isRead: m['is_read'] ?? false,
                      );
                    }).toList();

                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: messages.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == 0) return _buildDateSeparator('المحادثة');
                        final msg = messages[i - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMessageBubble(msg),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary, size: 16),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_targetName ?? 'حرفي حرفة',
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
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
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.greenAvailable)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 22, color: AppColors.textLight),
          ),
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
              child: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
            ),
          ),
          GestureDetector(
            onTap: () => _showMoreOptions(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 18),
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
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              _sheetItem(Icons.block_outlined, 'حظر المستخدم', AppColors.error),
              _sheetItem(Icons.report_outlined, 'إبلاغ عن مشكلة', AppColors.textSecondary),
              _sheetItem(Icons.delete_outline, 'حذف المحادثة', AppColors.textSecondary),
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
      title: Text(label, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      onTap: () => Navigator.pop(context),
    );
  }

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping, color: AppColors.textWhite, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('12 دقيقة',
                          style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    ),
                    const SizedBox(width: 8),
                    Text('الحرفي في الطريق',
                        style: AppTextStyles.titleSmall, textDirection: TextDirection.rtl),
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

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.text:
        return msg.isOutgoing ? _buildOutgoing(msg) : _buildIncoming(msg);
      default:
        return msg.isOutgoing ? _buildOutgoing(msg) : _buildIncoming(msg);
    }
  }

  Widget _buildOutgoing(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all, color: msg.isRead ? AppColors.primary : AppColors.textLight, size: 14),
                const SizedBox(width: 4),
                Text(msg.time, style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncoming(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 4),
            Text(msg.time, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('جاري الكتابة...', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: AppColors.textWhite, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: AppTextStyles.hintStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
