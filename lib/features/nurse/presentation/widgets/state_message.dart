import 'package:flutter/material.dart';

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onTap, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
