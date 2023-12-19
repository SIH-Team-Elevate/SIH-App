import 'package:sih_app/utils/socket_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;
  sendlocation(double longitude, double latitude, String userId) {
    
    _socketClient.emit("location",
        {"longitude": longitude, "latitude": latitude, "userId": userId});
  }
}
