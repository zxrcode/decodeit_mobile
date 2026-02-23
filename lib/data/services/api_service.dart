import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/ip_info.dart';

class ApiService {
  static const String _ipApiUrl = 'http://ip-api.com/json/';

  Future<IpInfo?> fetchIpInfo([String? customIp]) async {
    try {
      final url = customIp != null && customIp.isNotEmpty
          ? '$_ipApiUrl$customIp'
          : _ipApiUrl;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return IpInfo.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
