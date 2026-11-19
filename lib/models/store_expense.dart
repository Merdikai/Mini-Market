class StoreExpense {
  final String id;
  final String category;
  final String title;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String receiptRef;
  final String notes;
  final String recordedBy;

  const StoreExpense({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.date,
    this.paymentMethod = 'Cash',
    this.receiptRef = '',
    this.notes = '',
    required this.recordedBy,
  });
}
