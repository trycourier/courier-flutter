class CourierPagination {
  final bool more;
  final String? cursor;

  CourierPagination({
    required this.more,
    this.cursor,
  });

  factory CourierPagination.fromJson(dynamic data) {
    return CourierPagination(
      more: data['more'],
      cursor: data['cursor'],
    );
  }
}
