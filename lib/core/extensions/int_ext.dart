extension PaiseExt on int {
  String toRupees() {
    final rupees = this / 100;
    return rupees % 1 == 0
        ? '₹${rupees.toInt()}'
        : '₹${rupees.toStringAsFixed(2)}';
  }
}

int perHeadPaise(int totalPaise, int playerCount) =>
    (totalPaise / playerCount).ceil();