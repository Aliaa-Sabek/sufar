import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';


class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}


class Intent {
  final String tag;
  final List<String> patterns;
  final List<String> responses;

  Intent({
    required this.tag,
    required this.patterns,
    required this.responses,
  });

  factory Intent.fromJson(Map<String, dynamic> json) {
    return Intent(
      tag: json['tag'] ?? '',
      patterns: List<String>.from(json['patterns'] ?? []),
      responses: List<String>.from(json['responses'] ?? []),
    );
  }
}

// ── Page ───────────────────────────────────────────────────────────────────

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {

  // Uses AIService → Railway backend (AI_SERVICE_URL dart-define)


  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
      "Hello! I'm Sufar AI, your personal travel assistant. How can I help you plan your journey today?\n\nأهلاً! أنا مساعد سُفَر الذكي. كيف يمكنني مساعدتك في تخطيط رحلتك؟ ✈️",
      isUser: false,
    ),
  ];
  bool _isTyping = false;
  List<Intent> _intents = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadIntents();
  }

  // lOAD INTENTS

  Future<void> _loadIntents() async {
    try {
      final String data =
      await rootBundle.loadString('assets/intents.json');
      final Map<String, dynamic> json = jsonDecode(data);
      final List<dynamic> intentList = json['intents'] as List<dynamic>;
      setState(() {
        _intents = intentList
            .map((e) => Intent.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {

      debugPrint('Could not load intents: $e');
    }
  }

// MATCHING INTENTS
  String? _matchIntent(String userInput) {
    if (_intents.isEmpty) return null;

    final input = userInput.toLowerCase().trim();

    for (final intent in _intents) {
      for (final pattern in intent.patterns) {
        if (input.contains(pattern.toLowerCase()) ||
            pattern.toLowerCase().contains(input)) {

          final responses = intent.responses;
          return responses[_random.nextInt(responses.length)];
        }
      }
    }
    return null;
  }


  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    final intentResponse = _matchIntent(text.trim());
    if (intentResponse != null) {
      await Future.delayed(const Duration(milliseconds: 600)); // natural feel
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: intentResponse, isUser: false));
      });
      _scrollToBottom();
      return;
    }

    try {
      // Detect language: if message contains Arabic chars → 'ar'
      final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text.trim());
      final String language = isArabic ? 'ar' : 'en';

      final result = await AIService.chat(
        message: text.trim(),
        language: language,
      );

      final responseData = result['response'] ?? result['reply'] ?? result['message'];
      String reply = '';
      if (responseData is Map) {
        reply = (isArabic ? responseData['ar'] : responseData['en'])?.toString() ?? 
                responseData.values.firstOrNull?.toString() ?? 
                'Sorry, I could not understand the response.';
      } else {
        reply = responseData?.toString() ?? 'Sorry, I could not understand the response.';
      }

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      _showError('Failed to connect: $e');
    }

    _scrollToBottom();
  }

  void _showError(String msg) {
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: "Sorry, I couldn't respond right now. Please try again.",
        isUser: false,
      ));
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bot', style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            errorBuilder: (context, error, stack) =>
            Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.grey),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
            ),
          ),
          if (isWide) _buildSidebar(),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0D4B88),
      padding: EdgeInsets.all(24),
      width: double.infinity,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome, color: Theme.of(context).cardColor),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sufar AI Assistant',
                  style: TextStyle(
                      color: Theme.of(context).cardColor, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle),
                  ),
                  SizedBox(width: 6),
                  Text(
                    _intents.isEmpty
                        ? 'Connecting...'
                        : 'Always here to help',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(24),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    if (msg.isUser) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A94C4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(msg.text,
                        style: TextStyle(color: Theme.of(context).cardColor)),
                    SizedBox(height: 4),
                    Text(timeStr,
                        style: TextStyle(
                            color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF0D4B88),
              child:
              Icon(Icons.person, size: 16, color: Theme.of(context).cardColor),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0F7FA),
            child: Icon(Icons.auto_awesome,
                size: 16, color: Color(0xFF1A94C4)),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sufar AI',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A94C4),
                          fontSize: 12)),
                  SizedBox(height: 8),
                  Text(msg.text,
                      style:
                      TextStyle(color: Color(0xFF0D1C52))),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(timeStr,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0F7FA),
            child: Icon(Icons.auto_awesome,
                size: 16, color: Color(0xFF1A94C4)),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3,
                      (i) => _BouncingDot(
                      delay: Duration(milliseconds: i * 150))),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              enabled: !_isTyping,
              decoration: InputDecoration(
                hintText: 'Type your message... / اكتب رسالتك...',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _isTyping
                ? null
                : () => _sendMessage(_inputController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: _isTyping
                    ? Colors.grey.shade300
                    : const Color(0xFF1A94C4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.send,
                  color: _isTyping ? Colors.grey : Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSidebar() {
    return Container(
      width: 300,
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _sidebarCard(
              title: 'Quick Actions',
              child: Column(
                children: [
                  _buildQuickAction(Icons.location_on_outlined,
                      'Find Destinations',
                      'Suggest some popular travel destinations for me.'),
                  SizedBox(height: 8),
                  _buildQuickAction(Icons.flight_takeoff, 'Search Flights',
                      'I want to book a flight'),
                  SizedBox(height: 8),
                  _buildQuickAction(
                      Icons.hotel_outlined, 'Book Hotels', 'Find me a hotel'),
                  SizedBox(height: 8),
                  _buildQuickAction(Icons.description_outlined, 'Visa Info',
                      'Do I need a visa for Thailand?'),
                  SizedBox(height: 8),
                  _buildQuickAction(Icons.map_outlined, 'Plan Full Trip',
                      'Plan my full trip'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A94C4), Color(0xFF0D4B88)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.info_outline, color: Theme.of(context).cardColor, size: 18),
                    SizedBox(width: 8),
                    Text('Pro Tips',
                        style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.bold)),
                  ]),
                  SizedBox(height: 12),
                  for (final tip in [
                    'Be specific about your preferences',
                    'Mention your budget range',
                    'Share your travel dates',
                    'Ask in English or Arabic 🌍',
                    'Use quick actions for faster help',
                  ])
                    Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(
                                  color: Theme.of(context).cardColor,
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(tip,
                                style: TextStyle(
                                    color: Theme.of(context).cardColor, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _sidebarCard(
              title: 'Example Questions',
              child: Column(
                children: [
                  for (final q in [
                    "What's the best time to visit Japan?",
                    "Plan my full trip to Dubai",
                    "Do I need a visa for Thailand?",
                    "أريد فندق في إسطنبول",
                    "ما هي أفضل الأنشطة في باريس؟",
                  ])
                    GestureDetector(
                      onTap: () => _sendMessage(q),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 14, color: Color(0xFF1A94C4)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(q,
                                  style: TextStyle(
                                      color: Color(0xFF1A94C4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _sidebarCard(
              title: 'Need More Help?',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect with our travel experts for personalized assistance.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Contact Support',
                          style: TextStyle(color: Theme.of(context).cardColor)),
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

  Widget _sidebarCard({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0D1C52))),
          SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, String message) {
    return GestureDetector(
      onTap: () => _sendMessage(message),
      child: Container(
        padding:
        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A94C4), size: 18),
            SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}


class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween(begin: 0.0, end: -8.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: Color(0xFF1A94C4), shape: BoxShape.circle),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
