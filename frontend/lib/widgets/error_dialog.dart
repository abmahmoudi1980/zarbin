import 'package:flutter/material.dart';

class ErrorDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? actionButtonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600]),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('بستن'),
            ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text(actionButtonText ?? 'تلاش دوباره'),
              ),
          ],
        );
      },
    );
  }

  static Future<void> showApiError(
    BuildContext context, {
    required String error,
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      title: 'خطای سرور',
      message: error,
      onRetry: onRetry,
      actionButtonText: 'تلاش دوباره',
    );
  }

  static Future<void> showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      title: 'خطای اتصال',
      message: 'اتصال به اینترنت خود را بررسی کنید و دوباره تلاش کنید.',
      onRetry: onRetry,
      actionButtonText: 'تلاش دوباره',
    );
  }

  static Future<void> showValidationError(
    BuildContext context, {
    required String message,
  }) {
    return show(
      context,
      title: 'خطای اعتبارسنجی',
      message: message,
    );
  }

  static Future<void> showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    return Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: duration,
        ),
      );
    });
  }

  static Future<void> showWarningSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.orange[600],
          duration: duration,
        ),
      );
    });
  }
}
