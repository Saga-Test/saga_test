import 'dart:io';

class SANetwork {
  static Future<String> get ip async {
    //
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);

    return interfaces.isNotEmpty
        ? interfaces.first.addresses.first.address
        : InternetAddress.anyIPv4.address;
  }
}
