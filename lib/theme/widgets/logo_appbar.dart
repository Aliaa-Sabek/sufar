import 'package:flutter/material.dart';

/// Reusable Logo AppBar widget
/// يستخدم لتقليل تكرار كود اللوجو في الشاشات
class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomeTap;
  final String? title;
  final bool showHomeButton;
  final double? elevation;
  final List<Widget>? actions;

  const LogoAppBar({
    super.key,
    this.onHomeTap,
    this.title,
    this.showHomeButton = true,
    this.elevation = 0,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(
          'assets/Sufar Logo Blue.png',
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) =>
              Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
        ),
      ),
      title: title != null
          ? Text(title!, style: Theme.of(context).appBarTheme.titleTextStyle)
          : null,
      actions: [
        if (showHomeButton)
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.grey),
            onPressed:
                onHomeTap ??
                () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
