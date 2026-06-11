import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class DeleteGroupDialog extends StatefulWidget {
  final String groupName;
  final VoidCallback onConfirm;
  const DeleteGroupDialog({required this.groupName, required this.onConfirm, super.key});

  @override
  State<DeleteGroupDialog> createState() => _DeleteGroupDialogState();
}

class _DeleteGroupDialogState extends State<DeleteGroupDialog> {
  final _controller = TextEditingController();
  bool _isValid = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Delete Group Permanently?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This action CANNOT be undone. All games, announcements, and payment history will be permanently deleted.',
            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Type the group name "${widget.groupName}" to confirm deletion:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter group name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onChanged: (text) {
              setState(() {
                _isValid = text.trim() == widget.groupName;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: (_isValid && !_isSubmitting)
              ? () async {
                  setState(() => _isSubmitting = true);
                  try {
                    widget.onConfirm();
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() => _isSubmitting = false);
                  }
                }
              : null,
          child: _isSubmitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onError,
                  ),
                )
              : const Text('Delete Forever'),
        ),
      ],
    );
  }
}
