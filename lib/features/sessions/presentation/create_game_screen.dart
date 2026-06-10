import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a venue first to generate a random name.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select match date and time.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editGameId != null ? 'Game updated!' : 'Game scheduled successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save game: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: AppColors.background,
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
              const SectionHeader(title: 'WHEN & WHERE'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Match Date'),
                              child: Text(dateStr, style: AppTextStyles.bodyLarge),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Start Time'),
                              child: Text(timeStr, style: AppTextStyles.bodyLarge),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _durationOption,
                            decoration: const InputDecoration(labelText: 'Duration'),
                            items: const [
                              DropdownMenuItem(value: '30', child: Text('30 Mins')),
                              DropdownMenuItem(value: '60', child: Text('1 Hour')),
                              DropdownMenuItem(value: '90', child: Text('1.5 Hours')),
                              DropdownMenuItem(value: '120', child: Text('2 Hours')),
                              DropdownMenuItem(value: '150', child: Text('2.5 Hours')),
                              DropdownMenuItem(value: '180', child: Text('3 Hours')),
                              DropdownMenuItem(value: 'Custom', child: Text('Custom duration')),
                            ],
                            onChanged: (val) => setState(() => _durationOption = val ?? '90'),
                          ),
                        ),
                        if (_durationOption == 'Custom') ...[
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: AppTextField(
                              controller: _customDurationController,
                              label: 'Duration (mins)',
                              hint: '100',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppTextField(
                      controller: _venueController,
                      label: 'Venue Location Name',
                      hint: 'Court 4, Sector 5 Arena',
                      maxLength: 100,
                      validator: (v) => v == null || v.isEmpty ? 'Venue name is required.' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _mapsController,
                      label: 'Google Maps Link (Optional)',
                      hint: 'https://maps.app.goo.gl/...',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // 2. Game Metadata
              const SectionHeader(title: 'GAME DETAILS'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<SportType>(
                      value: _sport,
                      decoration: const InputDecoration(labelText: 'Sport Type'),
                      items: SportType.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sport = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _titleController,
                            label: 'Match Session Title',
                            hint: 'Sunday Smash Clash',
                            maxLength: 60,
                            validator: (v) => v == null || v.isEmpty ? 'Session title is required.' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.auto_awesome),
                          onPressed: _generateRandomName,
                          tooltip: 'Generate Random Name',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _descController,
                      label: 'Description / Notes (Optional)',
                      hint: 'Bring your own rackets. Brand new shuttles provided.',
                      maxLength: 300,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // 3. Payment Rules
              const SectionHeader(title: 'FEES & UPI SETTINGS'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Model', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('PRE-PAID')),
                            selected: _paymentModel == PaymentModel.prepaid,
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: _paymentModel == PaymentModel.prepaid ? AppColors.primaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _paymentModel = PaymentModel.prepaid);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('POST-PAID')),
                            selected: _paymentModel == PaymentModel.postpaid,
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: _paymentModel == PaymentModel.postpaid ? AppColors.primaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _paymentModel = PaymentModel.postpaid);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppTextField(
                      controller: _costController,
                      label: _paymentModel == PaymentModel.prepaid ? 'Cost per person (₹)' : 'Estimated cost per person (₹) (Optional)',
                      hint: '150',
                      enabled: !_showCostBreakdown,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (_paymentModel == PaymentModel.prepaid && (v == null || v.isEmpty)) {
                          return 'Cost is required for prepaid model.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppTextField(
                      controller: _upiController,
                      label: 'Organizer UPI ID (for receiving collections)',
                      hint: 'name@upi',
                      validator: (v) => v == null || v.isEmpty ? 'UPI ID is required.' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Cost Breakdown Accordion
                    ExpansionTile(
                      leading: const Icon(Icons.calculate_outlined, color: AppColors.primary),
                      title: const Text('Add Cost Breakdown', style: AppTextStyles.headlineSmall),
                      subtitle: const Text('Sum elements to calculate per head cost', style: AppTextStyles.bodySmall),
                      initiallyExpanded: _showCostBreakdown,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _showCostBreakdown = expanded;
                          if (expanded) _updateCostFromBreakdown();
                        });
                      },
                      children: [
                        ..._costItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final labelController = TextEditingController(text: item['label'] as String);
                          final valController = TextEditingController(text: (item['costRupees'] as double).toStringAsFixed(0));

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: labelController,
                                    decoration: const InputDecoration(labelText: 'Item Label', hintText: 'Court fee'),
                                    onChanged: (val) {
                                      _costItems[idx]['label'] = val;
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: valController,
                                    decoration: const InputDecoration(labelText: 'Amount (₹)'),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    onChanged: (val) {
                                      _costItems[idx]['costRupees'] = double.tryParse(val) ?? 0.0;
                                      _updateCostFromBreakdown();
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.destructive),
                                  onPressed: () {
                                    setState(() {
                                      _costItems.removeAt(idx);
                                      _updateCostFromBreakdown();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        if (_costItems.length < 5)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Line Item'),
                              onPressed: () {
                                setState(() {
                                  _costItems.add({'label': '', 'costRupees': 0.0});
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // 4. RSVP Rules
              const SectionHeader(title: 'RSVP LIMITS & DEADLINE'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _capacityController,
                      label: 'Maximum Game Capacity',
                      hint: '20',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Capacity is required.';
                        final cap = int.tryParse(v) ?? 0;
                        if (cap < 2 || cap > 200) return 'Capacity must be between 2 and 200.';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile.adaptive(
                      title: const Text('Allow Guest RSVPs', style: AppTextStyles.headlineSmall),
                      subtitle: const Text('Players can add +1 or more extra guests', style: AppTextStyles.bodySmall),
                      value: _allowGuests,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _allowGuests = val),
                    ),
                    const Divider(height: AppSpacing.lg),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('RSVP Deadline (Optional)', style: AppTextStyles.headlineSmall),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectRsvpDeadlineDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Deadline Date'),
                              child: Text(_rsvpDeadlineDate != null ? rsvpDateStr : 'None', style: AppTextStyles.bodyLarge),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: InkWell(
                            onTap: _selectRsvpDeadlineTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Deadline Time'),
                              child: Text(_rsvpDeadlineTime != null ? rsvpTimeStr : 'None', style: AppTextStyles.bodyLarge),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_rsvpDeadlineDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() {
                            _rsvpDeadlineDate = null;
                            _rsvpDeadlineTime = null;
                          }),
                          child: const Text('Clear Deadline', style: TextStyle(color: AppColors.destructive)),
                        ),
                      ),
                  ],
                ),
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