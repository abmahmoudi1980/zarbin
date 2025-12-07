import 'package:flutter/material.dart';

class OfflineIndicator extends StatefulWidget {
  final bool isOnline;
  final bool isStale;
  final String? staleMessage;

  const OfflineIndicator({
    Key? key,
    required this.isOnline,
    this.isStale = false,
    this.staleMessage,
  }) : super(key: key);

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Only animate if offline
    if (!widget.isOnline) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OfflineIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOnline && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    } else if (widget.isOnline && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOnline && !widget.isStale) {
      return const SizedBox.shrink();
    }

    if (!widget.isOnline) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.red[100],
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.red[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بدون اتصال اینترنتی',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.isStale) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.amber[100],
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.staleMessage ?? 'داده‌ها از 5 دقیقه قدیمی‌تر هستند',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// Widget to show connection status in AppBar
class ConnectivityBadge extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onTap;

  const ConnectivityBadge({
    Key? key,
    required this.isOnline,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return Tooltip(
        message: 'آنلاین',
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_done,
            color: Colors.green[700],
            size: 16,
          ),
        ),
      );
    }

    return Tooltip(
      message: 'آفلاین',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_off,
            color: Colors.red[700],
            size: 16,
          ),
        ),
      ),
    );
  }
}

// Widget to show data staleness indicator
class StalenessIndicator extends StatelessWidget {
  final DateTime? lastUpdate;
  final Duration staleThreshold;

  const StalenessIndicator({
    Key? key,
    this.lastUpdate,
    this.staleThreshold = const Duration(minutes: 5),
  }) : super(key: key);

  bool get isStale {
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate!) > staleThreshold;
  }

  @override
  Widget build(BuildContext context) {
    if (!isStale) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border.all(color: Colors.orange[200]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 14, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text(
              'داده‌های قدیمی',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
