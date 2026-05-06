enum CourierApiUrls {
  us(value: 'us'),
  eu(value: 'eu');

  final String value;

  const CourierApiUrls({required this.value});

  static CourierApiUrls? fromValue(String? value) {
    if (value == null) return null;
    return CourierApiUrls.values.cast<CourierApiUrls?>().firstWhere(
      (e) => e!.value == value,
      orElse: () => null,
    );
  }
}
