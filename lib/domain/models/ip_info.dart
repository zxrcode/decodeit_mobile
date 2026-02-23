class IpInfo {
  final String ip;
  final String country;
  final String city;
  final String isp;

  IpInfo({
    required this.ip,
    required this.country,
    required this.city,
    required this.isp,
  });

  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ip: json['query'] ?? 'Белгісіз',
      country: json['country'] ?? 'Белгісіз',
      city: json['city'] ?? 'Белгісіз',
      isp: json['isp'] ?? 'Белгісіз',
    );
  }
}
