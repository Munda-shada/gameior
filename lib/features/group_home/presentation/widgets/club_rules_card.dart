import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/core/utils/app_toast.dart';

class ClubRulesCard extends ConsumerStatefulWidget {
  final String rules;
  final String groupId;
  final bool isAdmin;

  const ClubRulesCard({
    required this.rules,
    required this.groupId,
    required this.isAdmin,
    super.key,
  });

  @override
  ConsumerState<ClubRulesCard> createState() => _ClubRulesCardState();
}

class _ClubRulesCardState extends ConsumerState<ClubRulesCard> {
  bool _isExpanded = false;

  void _showEditRulesSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Edit Rules',
      initialChildSizeRatio: 0.7,
      child: _EditRulesBottomSheet(
        groupId: widget.groupId,
        initialRules: widget.rules,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRules = widget.rules.trim().isNotEmpty;
    final displayRules = hasRules ? widget.rules : 'No club rules defined yet.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'CLUB RULES',
          trailing: widget.isAdmin
              ? TextButton.icon(
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _showEditRulesSheet(context),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.push_pin,
                  color: theme.colorScheme.tertiary,
                ),
                title: Text(
                  'Pinned Rules & Guidelines',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
              ),
              if (_isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      displayRules,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditRulesBottomSheet extends StatefulWidget {
  final String groupId;
  final String initialRules;
  const _EditRulesBottomSheet({
    required this.groupId,
    required this.initialRules,
  });

  @override
  State<_EditRulesBottomSheet> createState() => _EditRulesBottomSheetState();
}

class _EditRulesBottomSheetState extends State<_EditRulesBottomSheet> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialRules);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.base,
        right: AppSpacing.base,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Club Rules',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Provide guidelines, penalty rules, or scheduling terms for players.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _controller,
            label: 'Rules & Regulations',
            hint: 'Define guidelines...',
            maxLength: 1000,
            maxLines: 8,
          ),
          const SizedBox(height: AppSpacing.lg),
          Consumer(
            builder: (context, ref, child) {
              return AppButton(
                label: 'Save Rules',
                isLoading: _isLoading,
                onPressed: () async {
                  final newRules = _controller.text.trim();
                  setState(() => _isLoading = true);
                  try {
                    final client = ref.read(supabaseClientProvider);
                    await client.from('groups').update({
                      'club_rules': newRules,
                    }).eq('id', widget.groupId);

                    ref.invalidate(groupContextProvider(widget.groupId));

                    if (context.mounted) {
                      showToast(context, 'Club rules updated successfully!');
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showToast(context, 'Failed to update rules: $e', isError: true);
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
