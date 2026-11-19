class ShippingAddress {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String address;
  final String postCode;
  final double lat;
  final double lng;

  new({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.address,
    required this.postCode,
    required this.lat,
    required this.lng,
  });

  factory fromRow(Map<String, Object?> map) {
    return ShippingAddress(
      id: map['id'].toString(),
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      phoneNo: map['phone'] as String,
      address: map['address'] as String,
      postCode: map['post_code'] as String,
      lat: map['pin_point_lat'] as double,
      lng: map['pin_point_lng'] as double,
    );
  }
}

class ShippingOption {
  final String id;
  final String name;
  final String eta;
  final int price;

  const ShippingOption({
    required this.id,
    required this.name,
    required this.eta,
    required this.price,
  });
}
