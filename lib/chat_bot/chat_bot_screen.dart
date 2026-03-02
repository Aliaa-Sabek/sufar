import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../ApiKeys.dart';

// Message model

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

// Page

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  // Groq config

  static const String _groqApiKey = ApiKeys.groqApiKey;
  static const String _model = 'llama-3.1-8b-instant';
  static const String _systemPrompt =
      'You are Sufar AI, a friendly and knowledgeable travel assistant for the Sufar travel app. '
      'You help users plan trips, find destinations, book hotels, search flights, check visa requirements, '
      'and provide travel tips. Keep responses concise, helpful, and friendly. '
      'Always stay on travel-related topics.';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
      "Hello! I'm Sufar AI, your personal travel assistant. How can I help you plan your journey today?",
      isUser: false,
    ),
  ];
  bool _isTyping = false;

  // API call

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // Build conversation history in OpenAI-compatible format (Groq uses same format)
      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': _systemPrompt},
        ..._messages.map((m) => {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        }),
      ];

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: reply.trim(), isUser: false));
        });
      } else {
        _showError('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Failed to connect. Please check your internet connection.');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat Bot', style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.grey),
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
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sufar AI Assistant',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.greenAccent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('Always here to help',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Message list

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
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
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
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
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF0D4B88),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0F7FA),
            child:
            Icon(Icons.auto_awesome, size: 16, color: Color(0xFF1A94C4)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: const BorderRadius.only(
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
                  const Text('Sufar AI',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A94C4),
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(msg.text,
                      style: const TextStyle(color: Color(0xFF0D1C52))),
                  const SizedBox(height: 4),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0F7FA),
            child:
            Icon(Icons.auto_awesome, size: 16, color: Color(0xFF1A94C4)),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3, (i) => _BouncingDot(delay: Duration(milliseconds: i * 150))),
            ),
          ),
        ],
      ),
    );
  }

  // Input bar

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                hintText: 'Type your message...',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap:
            _isTyping ? null : () => _sendMessage(_inputController.text),
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

  // Sidebar

  Widget _buildSidebar() {
    return Container(
      width: 300,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _sidebarCard(
              title: 'Quick Actions',
              child: Column(
                children: [
                  _buildQuickAction(Icons.location_on_outlined,
                      'Find Destinations',
                      'Suggest some popular travel destinations for me.'),
                  const SizedBox(height: 8),
                  _buildQuickAction(
                      Icons.flight_takeoff, 'Search Flights',
                      'How can I find the best flight deals?'),
                  const SizedBox(height: 8),
                  _buildQuickAction(
                      Icons.hotel_outlined, 'Book Hotels',
                      'Help me find a good hotel for my trip.'),
                  const SizedBox(height: 8),
                  _buildQuickAction(
                      Icons.description_outlined, 'Visa Info',
                      'How do I check visa requirements for a country?'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A94C4), Color(0xFF0D4B88)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Pro Tips',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),
                  for (final tip in [
                    'Be specific about your preferences',
                    'Mention your budget range',
                    'Share your travel dates',
                    'Ask follow-up questions',
                    'Use quick actions for faster help',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(tip,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sidebarCard(
              title: 'Example Questions',
              child: Column(
                children: [
                  for (final q in [
                    "What's the best time to visit Japan?",
                    "I have \$2000 for a week trip",
                    "Do I need a visa for Thailand?",
                  ])
                    GestureDetector(
                      onTap: () => _sendMessage(q),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 14, color: Color(0xFF1A94C4)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(q,
                                  style: const TextStyle(
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
            const SizedBox(height: 20),
            _sidebarCard(
              title: 'Need More Help?',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect with our travel experts for personalized assistance.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Contact Support',
                          style: TextStyle(color: Colors.white)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1C52))),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String message) {
    return GestureDetector(
      onTap: () => _sendMessage(message),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A94C4), size: 18),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF0D1C52),
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

// dot animation

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
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
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