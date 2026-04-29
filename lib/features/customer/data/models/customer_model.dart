import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String phone;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String address;
  
  @HiveField(5)
  final String? lastVisitDate;
  
  @HiveField(6)
  final String visitStatus;
  
  @HiveField(7)
  final String? notes;
  
  @HiveField(8)
  final String? lastSyncedTime;
  
  @HiveField(9)
  final String syncStatus;

  @HiveField(10)
  final String? updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.lastVisitDate,
    required this.visitStatus,
    this.notes,
    this.lastSyncedTime,
    required this.syncStatus,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int),
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      address: json['address'] ?? 'N/A',
      lastVisitDate: json['lastVisitDate'],
      visitStatus: json['visitStatus'] ?? 'pending',
      notes: json['notes'] ?? '',
      syncStatus: 'synced',
      updatedAt: json['updatedAt'] ?? json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'lastVisitDate': lastVisitDate,
      'visitStatus': visitStatus,
      'notes': notes,
      'updatedAt': updatedAt,
    };
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? lastVisitDate,
    String? visitStatus,
    String? notes,
    String? lastSyncedTime,
    String? syncStatus,
    String? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      visitStatus: visitStatus ?? this.visitStatus,
      notes: notes ?? this.notes,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
