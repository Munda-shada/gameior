extension DateTimeIST on DateTime {
  DateTime toIST() => toUtc().add(const Duration(hours: 5, minutes: 30));

  String toTimeString() {
    final ist = toIST();
    final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
    final minute = ist.minute.toString().padLeft(2, '0');
    final period = ist.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String toDateString() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final ist = toIST();
    return '${days[ist.weekday - 1]} ${ist.day} ${months[ist.month - 1]}';
  }

  String toRelativeString() {
    final now = DateTime.now().toIST();
    final ist = toIST();
    final diff = ist.difference(now);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return '${diff.inDays} days away';
    return toDateString();
  }
}