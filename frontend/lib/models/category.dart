class Category {
  final int id;
  final String persianName;
  final String iconCode;
  final int displayOrder;

  Category({
    required this.id,
    required this.persianName,
    required this.iconCode,
    required this.displayOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      persianName: json['persian_name'] as String,
      iconCode: json['icon_code'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'persian_name': persianName,
        'icon_code': iconCode,
        'display_order': displayOrder,
      };
}
