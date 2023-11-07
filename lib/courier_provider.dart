enum CourierPushProvider {

  apn(value: "apn"),
  firebaseFcm(value: "firebase-fcm"),
  expo(value: "expo"),
  oneSignal(value: "onesignal"),
  pusherBeams(value: "pusher-beams");

  final String value;

  const CourierPushProvider({
    required this.value,
  });

}