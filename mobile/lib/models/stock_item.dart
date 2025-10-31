class StockItem {
  final String id;
  String name;
  double quantity;
  String unit;
  String status;

  StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.status = 'En stock',
  });
}
