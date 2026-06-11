import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

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
    return AlertDialog(
      title: const Text('Delete Group Permanently?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action CANNOT be undone. All games, announcements, and payment history will be permanently deleted.',
            style: TextStyle(color: AppColors.destructive, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Type the group name "${widget.groupName}" to confirm deletion:',
            style: AppTextStyles.bodyMedium,
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
            backgroundColor: AppColors.destructive,
            foregroundColor: Colors.white,
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
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Delete Forever'),
        ),
      ],
    );
  }
}
