import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:gameior/core/utils/app_toast.dart';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';

// Split section imports
import 'package:gameior/features/sessions/presentation/widgets/schedule_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/game_details_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/payment_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/rsvp_settings_section.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String? editGameId;
  final bool isTemplate;
  const CreateGameScreen({required this.groupId, this.editGameId, this.isTemplate = false, super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Controllers & Fields
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final _mapsController = TextEditingController();
  final _costController = TextEditingController();
  final _upiController = TextEditingController();
  final _capacityController = TextEditingController();
  final _rulesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _durationOption = '90'; // Default 90 min
  final _customDurationController = TextEditingController();
  SportType _sport = SportType.badminton;
  PaymentModel _paymentModel = PaymentModel.prepaid;
  bool _allowGuests = true;
  bool _showCostBreakdown = false;

  DateTime? _rsvpDeadlineDate;
  TimeOfDay? _rsvpDeadlineTime;

  // Cost breakdown list
  final List<Map<String, dynamic>> _costItems = []; // label: string, costRupees: double
  List<String> _allowedSkillLevels = ['all'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _mapsController.dispose();
    _costController.dispose();
    _upiController.dispose();
    _capacityController.dispose();
    _customDurationController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final client = ref.read(supabaseClientProvider);

    try {
      // 1. Fetch group settings to pre-populate defaults
      final groupCtx = await ref.read(groupContextProvider(widget.groupId).future);
      final group = groupCtx.group;

      _sport = group.sport;
      _capacityController.text = (group.maxCapacity ?? 20).toString();
      _paymentModel = group.paymentModel;
      _costController.text = (group.defaultCostPaise / 100.0).toStringAsFixed(0);
      _upiController.text = group.defaultUpiId ?? '';
      _allowGuests = group.allowGuests;

      // 2. Fetch User Profile UPI ID if group has no default
      if (_upiController.text.isEmpty) {
        final profileRes = await client
            .from('profiles')
            .select('upi_id')
            .eq('id', client.auth.currentUser!.id)
            .maybeSingle();
        if (profileRes != null && profileRes['upi_id'] != null) {
          _upiController.text = profileRes['upi_id'] as String;
        }
      }

      // 3. Edit Mode Pre-fill
      if (widget.editGameId != null) {
        final gameRes = await client
            .from('games')
            .select('*, game_cost_items(*)')
            .eq('id', widget.editGameId!)
            .single();

        _titleController.text = gameRes['title'] as String? ?? '';
        _descController.text = gameRes['description'] as String? ?? '';
        _venueController.text = gameRes['venue'] as String? ?? '';
        _mapsController.text = gameRes['maps_link'] as String? ?? '';
        _capacityController.text = (gameRes['max_capacity'] as num).toInt().toString();
        _paymentModel = gameRes['payment_model'] == 'prepaid' ? PaymentModel.prepaid : PaymentModel.postpaid;
        _costController.text = ((gameRes['cost_paise'] as num) / 100.0).toStringAsFixed(0);
        _upiController.text = gameRes['upi_id'] as String? ?? '';
        _allowGuests = gameRes['allow_guests'] as bool? ?? true;
        _showCostBreakdown = gameRes['show_cost_breakdown'] as bool? ?? false;
        
        final scheduled = DateTime.parse(gameRes['scheduled_at'] as String).toLocal();
        _selectedDate = scheduled;
        _selectedTime = TimeOfDay.fromDateTime(scheduled);

        final dur = (gameRes['duration_minutes'] as num).toInt();
        if ([30, 60, 90, 120, 150, 180].contains(dur)) {
          _durationOption = dur.toString();
        } else {
          _durationOption = 'Custom';
          _customDurationController.text = dur.toString();
        }

        if (gameRes['rsvp_deadline'] != null) {
          final deadline = DateTime.parse(gameRes['rsvp_deadline'] as String).toLocal();
          _rsvpDeadlineDate = deadline;
          _rsvpDeadlineTime = TimeOfDay.fromDateTime(deadline);
        }

        final items = gameRes['game_cost_items'] as List? ?? [];
        _costItems.clear();
        for (var item in items) {
          _costItems.add({
            'label': item['label'],
            'costRupees': (item['amount_paise'] as num) / 100.0,
          });
        }
        final skillLevelsList = gameRes['allowed_skill_levels'] as List? ?? ['all'];
        _allowedSkillLevels = List<String>.from(skillLevelsList.map((e) => e.toString()));
      } 
      // 4. Template Mode Pre-fill
      else if (widget.isTemplate) {
        final lastGame = await client
            .from('games')
            .select('*, game_cost_items(*)')
            .eq('group_id', widget.groupId)
            .neq('status', 'upcoming')
            .order('scheduled_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastGame != null) {
          _venueController.text = lastGame['venue'] as String? ?? '';
          _mapsController.text = lastGame['maps_link'] as String? ?? '';
          _capacityController.text = (lastGame['max_capacity'] as num).toInt().toString();
          _paymentModel = lastGame['payment_model'] == 'prepaid' ? PaymentModel.prepaid : PaymentModel.postpaid;
          _costController.text = ((lastGame['cost_paise'] as num) / 100.0).toStringAsFixed(0);
          _upiController.text = lastGame['upi_id'] as String? ?? '';
          _allowGuests = lastGame['allow_guests'] as bool? ?? true;
          _showCostBreakdown = lastGame['show_cost_breakdown'] as bool? ?? false;

          final dur = (lastGame['duration_minutes'] as num).toInt();
          if ([30, 60, 90, 120, 150, 180].contains(dur)) {
            _durationOption = dur.toString();
          } else {
            _durationOption = 'Custom';
            _customDurationController.text = dur.toString();
          }

          final items = lastGame['game_cost_items'] as List? ?? [];
          _costItems.clear();
          for (var item in items) {
            _costItems.add({
              'label': item['label'],
              'costRupees': (item['amount_paise'] as num) / 100.0,
            });
          }
          final skillLevelsList = lastGame['allowed_skill_levels'] as List? ?? ['all'];
          _allowedSkillLevels = List<String>.from(skillLevelsList.map((e) => e.toString()));
        }
      }
    } catch (e) {
      // Fail silently, load defaults
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _generateRandomName() {
    final venue = _venueController.text.trim();
    if (venue.isEmpty) {
      showToast(context, 'Please enter a venue first to generate a random name.', isError: true);
      return;
    }
    const adjectives = ['Thunder', 'Epic', 'Fire', 'Lightning', 'Power', 'Supreme', 'Golden', 'Apex'];
    const nouns = ['Smash', 'Rally', 'Battle', 'Clash', 'Match', 'Duel', 'Showdown', 'Scrum'];
    
    final adj = adjectives[Random().nextInt(adjectives.length)];
    final noun = nouns[Random().nextInt(nouns.length)];
    final shortVenue = venue.split(',').first.trim();
    
    setState(() {
      _titleController.text = '$adj $noun @ $shortVenue';
    });
  }

  void _updateCostFromBreakdown() {
    if (!_showCostBreakdown) return;
    double sum = 0.0;
    for (var item in _costItems) {
      sum += (item['costRupees'] as double? ?? 0.0);
    }
    setState(() {
      _costController.text = sum.toStringAsFixed(0);
    });
  }

  Future<void> _selectDate() async {
    final initialDate = _selectedDate ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(DateTime.now()) ? DateTime.now().add(const Duration(days: 1)) : initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final initialTime = _selectedTime ?? const TimeOfDay(hour: 7, minute: 0);
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _selectRsvpDeadlineDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _rsvpDeadlineDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _selectedDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _rsvpDeadlineDate = date);
    }
  }

  Future<void> _selectRsvpDeadlineTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _rsvpDeadlineTime ?? const TimeOfDay(hour: 23, minute: 59),
    );
    if (time != null) {
      setState(() => _rsvpDeadlineTime = time);
    }
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      showToast(context, 'Please select match date and time.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final client = ref.read(supabaseClientProvider);

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    ).toUtc();

    DateTime? deadlineDateTime;
    if (_rsvpDeadlineDate != null && _rsvpDeadlineTime != null) {
      deadlineDateTime = DateTime(
        _rsvpDeadlineDate!.year,
        _rsvpDeadlineDate!.month,
        _rsvpDeadlineDate!.day,
        _rsvpDeadlineTime!.hour,
        _rsvpDeadlineTime!.minute,
      ).toUtc();
    }

    final duration = _durationOption == 'Custom'
        ? int.tryParse(_customDurationController.text) ?? 90
        : int.tryParse(_durationOption) ?? 90;

    final capacity = int.tryParse(_capacityController.text) ?? 20;
    final costDouble = double.tryParse(_costController.text) ?? 0.0;
    final costPaise = (costDouble * 100).round();

    final Map<String, dynamic> gameData = {
      'group_id': widget.groupId,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'sport': _sport.name,
      'venue': _venueController.text.trim(),
      'maps_link': _mapsController.text.trim(),
      'scheduled_at': scheduledDateTime.toIso8601String(),
      'duration_minutes': duration,
      'max_capacity': capacity,
      'payment_model': _paymentModel.name,
      'cost_paise': costPaise,
      'upi_id': _upiController.text.trim(),
      'show_cost_breakdown': _showCostBreakdown,
      'allow_guests': _allowGuests,
      'rsvp_deadline': deadlineDateTime?.toIso8601String(),
      'payment_owner_id': client.auth.currentUser!.id,
      'allowed_skill_levels': _allowedSkillLevels,
    };

    try {
      String gameId;
      if (widget.editGameId != null) {
        // Edit Game
        await client.from('games').update(gameData).eq('id', widget.editGameId!);
        gameId = widget.editGameId!;
        // Remove cost items
        await client.from('game_cost_items').delete().eq('game_id', gameId);
      } else {
        // New Game
        final newGame = await client.from('games').insert(gameData).select().single();
        gameId = newGame['id'] as String;
      }

      // Save Cost Breakdown Items
      if (_showCostBreakdown && _costItems.isNotEmpty) {
        final itemsToInsert = _costItems.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return {
            'game_id': gameId,
            'label': item['label'] as String,
            'amount_paise': ((item['costRupees'] as double) * 100).round(),
            'sort_order': idx,
          };
        }).toList();
        await client.from('game_cost_items').insert(itemsToInsert);
      }

      ref.invalidate(upcomingGamesProvider(widget.groupId));
      ref.invalidate(pastGamesProvider(groupId: widget.groupId, limit: AppConstants.pastGamesInitialLimit));

      if (mounted) {
        showToast(context, widget.editGameId != null ? 'Game updated!' : 'Game scheduled successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to save game: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleSkillLevelSelected(String value, bool selected) {
    setState(() {
      if (value == 'all') {
        if (selected) {
          _allowedSkillLevels = ['all'];
        }
      } else {
        if (selected) {
          _allowedSkillLevels.remove('all');
          if (!_allowedSkillLevels.contains(value)) {
            _allowedSkillLevels.add(value);
          }
        } else {
          _allowedSkillLevels.remove(value);
          if (_allowedSkillLevels.isEmpty) {
            _allowedSkillLevels = ['all'];
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dateStr = _selectedDate != null ? DateFormat('EEE, MMM d, yyyy').format(_selectedDate!) : 'Select Date';
    final timeStr = _selectedTime != null ? _selectedTime!.format(context) : 'Select Time';

    final rsvpDateStr = _rsvpDeadlineDate != null ? DateFormat('MMM d, yyyy').format(_rsvpDeadlineDate!) : 'Select Date';
    final rsvpTimeStr = _rsvpDeadlineTime != null ? _rsvpDeadlineTime!.format(context) : 'Select Time';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.editGameId != null ? 'Edit Game Session' : 'Schedule New Game'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Schedule Details
              ScheduleSection(
                onSelectDate: _selectDate,
                onSelectTime: _selectTime,
                dateStr: dateStr,
                timeStr: timeStr,
                durationOption: _durationOption,
                onDurationChanged: (val) => setState(() => _durationOption = val ?? '90'),
                customDurationController: _customDurationController,
                venueController: _venueController,
                mapsController: _mapsController,
              ),
              const SizedBox(height: AppSpacing.base),

              // 2. Game Metadata
              GameDetailsSection(
                sport: _sport,
                onSportChanged: (val) {
                  if (val != null) setState(() => _sport = val);
                },
                titleController: _titleController,
                onGenerateName: _generateRandomName,
                descController: _descController,
                allowedSkillLevels: _allowedSkillLevels,
                onSkillLevelSelected: _handleSkillLevelSelected,
              ),
              const SizedBox(height: AppSpacing.base),

              // 3. Payment Rules
              PaymentSection(
                paymentModel: _paymentModel,
                onPaymentModelChanged: (val) => setState(() => _paymentModel = val),
                costController: _costController,
                upiController: _upiController,
                showCostBreakdown: _showCostBreakdown,
                onCostBreakdownExpanded: (expanded) {
                  setState(() {
                    _showCostBreakdown = expanded;
                    if (expanded) _updateCostFromBreakdown();
                  });
                },
                costItems: _costItems,
                onAddCostItem: () {
                  setState(() {
                    _costItems.add({'label': '', 'costRupees': 0.0});
                  });
                },
                onRemoveCostItem: (idx) {
                  setState(() {
                    _costItems.removeAt(idx);
                    _updateCostFromBreakdown();
                  });
                },
                onCostItemLabelChanged: (idx, val) {
                  _costItems[idx]['label'] = val;
                },
                onCostItemAmountChanged: (idx, val) {
                  _costItems[idx]['costRupees'] = val;
                  _updateCostFromBreakdown();
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // 4. RSVP Rules
              RsvpSettingsSection(
                capacityController: _capacityController,
                allowGuests: _allowGuests,
                onAllowGuestsChanged: (val) => setState(() => _allowGuests = val),
                rsvpDeadlineDate: _rsvpDeadlineDate,
                rsvpDeadlineTime: _rsvpDeadlineTime,
                onSelectRsvpDeadlineDate: _selectRsvpDeadlineDate,
                onSelectRsvpDeadlineTime: _selectRsvpDeadlineTime,
                onClearDeadline: () => setState(() {
                  _rsvpDeadlineDate = null;
                  _rsvpDeadlineTime = null;
                }),
                rsvpDateStr: rsvpDateStr,
                rsvpTimeStr: rsvpTimeStr,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppButton(
                label: widget.editGameId != null ? 'Save Changes' : 'Schedule Game Session',
                isLoading: _isSubmitting,
                onPressed: _saveGame,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}