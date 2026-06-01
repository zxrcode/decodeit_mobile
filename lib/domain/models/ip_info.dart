class IpInfo {
  final String ip;
  final String country;
  final String city;
  final String isp;
  final String? region;
  final String? timezone;

  IpInfo({
    required this.ip,
    required this.country,
    required this.city,
    required this.isp,
    this.region,
    this.timezone,
  });

  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ip: json['ip'] ?? json['query'] ?? 'Белгісіз',
      // ipinfo.io: 'country' is 2-letter code; ipapi.co: 'country_name'
      country: json['country_name'] ?? json['country'] ?? 'Белгісіз',
      city: json['city'] ?? 'Белгісіз',
      // ipinfo.io: 'org' contains ASN + name; ipapi.co: 'org' or 'isp'
      isp: json['org'] ?? json['isp'] ?? 'Белгісіз',
      region: json['region'],
      timezone: json['timezone'],
    );
  }
}
