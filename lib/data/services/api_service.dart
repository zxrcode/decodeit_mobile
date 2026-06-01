import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/ip_info.dart';

class ApiService {
  static const String _ipInfoUrl = 'https://ipinfo.io/json';
  static const String _ipInfoCustomUrl = 'https://ipinfo.io/';

  Future<IpInfo?> fetchIpInfo([String? customIp]) async {
    try {
      final url = customIp != null && customIp.isNotEmpty
          ? '$_ipInfoCustomUrl$customIp/json'
          : _ipInfoUrl;
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

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
