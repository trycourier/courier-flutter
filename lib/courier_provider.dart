enum CourierProvider {

  apns(value: "apn"),
  fcm(value: "firebase-fcm");

  final String value;

  const CourierProvider({
    required this.value,
  });

}