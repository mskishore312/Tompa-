class InvoiceLine {
  const InvoiceLine({
    required this.description,
    required this.quantity,
    required this.rate,
    required this.gstRate,
    this.hsn,
    this.unit,
  });

  final String description;
  final double quantity;
  final double rate;
  final double gstRate;
  final String? hsn;
  final String? unit;

  double get taxableValue => quantity * rate;
  double get gstAmount => taxableValue * gstRate / 100;
  double get total => taxableValue + gstAmount;
}

class InvoiceDraft {
  const InvoiceDraft({
    required this.type,
    required this.withInventory,
    required this.partyName,
    required this.lines,
    required this.date,
    this.invoiceNumber,
  });

  final String type;
  final bool withInventory;
  final String partyName;
  final List<InvoiceLine> lines;
  final DateTime date;
  final String? invoiceNumber;

  double get taxableValue => lines.fold<double>(0, (sum, line) => sum + line.taxableValue);
  double get gstAmount => lines.fold<double>(0, (sum, line) => sum + line.gstAmount);
  double get total => lines.fold<double>(0, (sum, line) => sum + line.total);
}
