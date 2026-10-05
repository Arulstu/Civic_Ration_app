// ─── Civic Harvest Data Models ───────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String name;
  final int age;
  final String relation;
  final bool isAadhaarVerified;

  const FamilyMember({
    required this.name,
    required this.age,
    required this.relation,
    required this.isAadhaarVerified,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      name: map['name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      relation: map['relation'] as String? ?? 'Member',
      isAadhaarVerified: map['isAadhaarVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'age': age,
        'relation': relation,
        'isAadhaarVerified': isAadhaarVerified,
      };
}

class RationUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String nfsaId;
  final String cardType; // BPL, AAY, PHH, APL
  final String cardNumber;
  final int familySize;
  final String shopId;
  final String shopName;
  final String shopAddress;
  final String shopDealerName;
  final String shopDealerPhone;
  final bool isAadhaarLinked;
  final String state;
  final String district;
  final String pincode;
  final List<FamilyMember> familyMembers;
  final DateTime? lastClaimDate;
  final String role; // 'beneficiary' | 'shopkeeper'

  const RationUser({
    required this.uid,
    required this.name,
    this.email = '',
    this.phone = '',
    required this.nfsaId,
    required this.cardType,
    required this.cardNumber,
    required this.familySize,
    required this.shopId,
    required this.shopName,
    required this.shopAddress,
    this.shopDealerName = 'Ganesh Verma',
    this.shopDealerPhone = '+91 98765 43210',
    required this.isAadhaarLinked,
    this.state = 'Tamil Nadu / Uttar Pradesh',
    this.district = 'Central Zone',
    this.pincode = '600001',
    this.familyMembers = const [],
    this.lastClaimDate,
    this.role = 'beneficiary',
  });

  bool get isShopkeeper => role == 'shopkeeper';

  factory RationUser.fromMap(Map<String, dynamic> map, String uid) {
    List<FamilyMember> members = [];
    if (map['familyMembers'] is List) {
      members = (map['familyMembers'] as List)
          .map((m) => FamilyMember.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
    }

    DateTime? lastClaim;
    if (map['lastClaimDate'] is Timestamp) {
      lastClaim = (map['lastClaimDate'] as Timestamp).toDate();
    } else if (map['lastClaimDate'] is String) {
      lastClaim = DateTime.tryParse(map['lastClaimDate'] as String);
    }

    return RationUser(
      uid: uid,
      name: map['name'] as String? ?? 'Beneficiary',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      nfsaId: map['nfsaId'] as String? ?? 'NFSA-${uid.substring(0, uid.length > 6 ? 6 : uid.length).toUpperCase()}',
      cardType: map['cardType'] as String? ?? 'BPL',
      cardNumber: map['cardNumber'] as String? ?? '4829-1092-8821',
      familySize: (map['familySize'] as num?)?.toInt() ?? (members.isNotEmpty ? members.length : 4),
      shopId: map['shopId'] as String? ?? 'shop_42',
      shopName: map['shopName'] as String? ?? 'Ganesh PDS Kendra #42',
      shopAddress: map['shopAddress'] as String? ?? 'Ward No. 12, Near Gram Panchayat, Rampur',
      shopDealerName: map['shopDealerName'] as String? ?? 'Ganesh Verma (Authorized Dealer)',
      shopDealerPhone: map['shopDealerPhone'] as String? ?? '+91 98765 43210',
      isAadhaarLinked: map['isAadhaarLinked'] as bool? ?? true,
      state: map['state'] as String? ?? 'Tamil Nadu / Uttar Pradesh',
      district: map['district'] as String? ?? 'Central Ward 12',
      pincode: map['pincode'] as String? ?? '600001',
      familyMembers: members,
      lastClaimDate: lastClaim,
      role: map['role'] as String? ?? 'beneficiary',
    );
  }

  RationUser copyWith({
    List<FamilyMember>? familyMembers,
    int? familySize,
    DateTime? lastClaimDate,
  }) {
    return RationUser(
      uid: uid, name: name, email: email, phone: phone,
      nfsaId: nfsaId, cardType: cardType, cardNumber: cardNumber,
      familySize: familySize ?? this.familySize,
      shopId: shopId, shopName: shopName, shopAddress: shopAddress,
      shopDealerName: shopDealerName, shopDealerPhone: shopDealerPhone,
      isAadhaarLinked: isAadhaarLinked, state: state, district: district,
      pincode: pincode,
      familyMembers: familyMembers ?? this.familyMembers,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      role: role,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'nfsaId': nfsaId,
        'cardType': cardType,
        'cardNumber': cardNumber,
        'familySize': familySize,
        'shopId': shopId,
        'shopName': shopName,
        'shopAddress': shopAddress,
        'shopDealerName': shopDealerName,
        'shopDealerPhone': shopDealerPhone,
        'isAadhaarLinked': isAadhaarLinked,
        'state': state,
        'district': district,
        'pincode': pincode,
        'familyMembers': familyMembers.map((m) => m.toMap()).toList(),
        'role': role,
        if (lastClaimDate != null) 'lastClaimDate': Timestamp.fromDate(lastClaimDate!),
      };
}

enum EntitlementStatus { available, collected, pending }

class Commodity {
  final String id;
  final String name;
  final String localName;
  final String icon;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final EntitlementStatus status;
  final String schemeNote;
  final String category;
  final DateTime? lastCollectedDate;

  const Commodity({
    required this.id,
    required this.name,
    required this.localName,
    required this.icon,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.status,
    required this.schemeNote,
    this.category = 'Staples',
    this.lastCollectedDate,
  });

  factory Commodity.fromMap(Map<String, dynamic> map, String id) {
    DateTime? collectedDate;
    if (map['lastCollectedDate'] is Timestamp) {
      collectedDate = (map['lastCollectedDate'] as Timestamp).toDate();
    } else if (map['lastCollectedDate'] is String) {
      collectedDate = DateTime.tryParse(map['lastCollectedDate'] as String);
    }

    return Commodity(
      id: id,
      name: map['name'] as String? ?? '',
      localName: map['localName'] as String? ?? '',
      icon: map['icon'] as String? ?? 'grain',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0,
      status: EntitlementStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'available'),
        orElse: () => EntitlementStatus.available,
      ),
      schemeNote: map['schemeNote'] as String? ?? '',
      category: map['category'] as String? ?? 'Staples',
      lastCollectedDate: collectedDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'localName': localName,
        'icon': icon,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'status': status.name,
        'schemeNote': schemeNote,
        'category': category,
        if (lastCollectedDate != null)
          'lastCollectedDate': Timestamp.fromDate(lastCollectedDate!),
      };
}

enum StockStatus { available, lowStock, outOfStock }

class Shop {
  final String id;
  final String name;
  final String dealerName;
  final String phone;
  final String address;
  final String pincode;
  final double lat;
  final double lng;
  final String timing;
  final bool isOpen;
  final String stockUpdateAgo;
  final int queueCount;
  final int waitTimeMins;
  final double rating;

  const Shop({
    required this.id,
    required this.name,
    required this.dealerName,
    required this.phone,
    required this.address,
    required this.pincode,
    this.lat = 13.0827,
    this.lng = 80.2707,
    this.timing = '7:00 AM – 1:00 PM • Tue - Sun (Mon Closed)',
    this.isOpen = true,
    this.stockUpdateAgo = '15 mins ago',
    this.queueCount = 3,
    this.waitTimeMins = 8,
    this.rating = 4.8,
  });

  factory Shop.fromMap(Map<String, dynamic> map, String id) {
    return Shop(
      id: id,
      name: map['name'] as String? ?? 'Ganesh Fair Price Shop',
      dealerName: map['dealerName'] as String? ?? 'Ganesh Verma',
      phone: map['phone'] as String? ?? '+91 98765 43210',
      address: map['address'] as String? ?? 'Ward No. 12, Rampur',
      pincode: map['pincode'] as String? ?? '600001',
      lat: (map['lat'] as num?)?.toDouble() ?? 13.0827,
      lng: (map['lng'] as num?)?.toDouble() ?? 80.2707,
      timing: map['timing'] as String? ?? '7:00 AM – 1:00 PM • Tue - Sun (Mon Closed)',
      isOpen: map['isOpen'] as bool? ?? true,
      stockUpdateAgo: map['stockUpdateAgo'] as String? ?? '15 mins ago',
      queueCount: (map['queueCount'] as num?)?.toInt() ?? 3,
      waitTimeMins: (map['waitTimeMins'] as num?)?.toInt() ?? 8,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'dealerName': dealerName,
        'phone': phone,
        'address': address,
        'pincode': pincode,
        'lat': lat,
        'lng': lng,
        'timing': timing,
        'isOpen': isOpen,
        'stockUpdateAgo': stockUpdateAgo,
        'queueCount': queueCount,
        'waitTimeMins': waitTimeMins,
        'rating': rating,
      };
}

class ShopCommodity {
  final String id;
  final String name;
  final String localName;
  final String icon;
  final double pricePerUnit;
  final String unit;
  final StockStatus stockStatus;
  final String? replenishmentNote;
  final double stockKg;
  final String cap;
  final String category;

  const ShopCommodity({
    required this.id,
    required this.name,
    required this.localName,
    required this.icon,
    required this.pricePerUnit,
    required this.unit,
    required this.stockStatus,
    this.replenishmentNote,
    this.stockKg = 500,
    required this.cap,
    this.category = 'Grains',
  });

  factory ShopCommodity.fromMap(Map<String, dynamic> map, [String id = '']) {
    return ShopCommodity(
      id: id.isNotEmpty ? id : (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      localName: map['localName'] as String? ?? '',
      icon: map['icon'] as String? ?? 'grain',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      stockStatus: StockStatus.values.firstWhere(
        (e) => e.name == (map['stockStatus'] as String? ?? 'available'),
        orElse: () => StockStatus.available,
      ),
      replenishmentNote: map['replenishmentNote'] as String?,
      stockKg: (map['stockKg'] as num?)?.toDouble() ?? 500,
      cap: map['cap'] as String? ?? '',
      category: map['category'] as String? ?? 'Grains',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'localName': localName,
        'icon': icon,
        'pricePerUnit': pricePerUnit,
        'unit': unit,
        'stockStatus': stockStatus.name,
        'replenishmentNote': replenishmentNote,
        'stockKg': stockKg,
        'cap': cap,
        'category': category,
      };
}

class CommunityNotice {
  final String id;
  final String title;
  final String body;
  final String category; // 'all', 'stock', 'timings', 'schemes', 'alerts'
  final DateTime date;
  final bool isUrgent;
  final String? imageUrl;
  final String? extraLabel;
  final String? extraValue;
  final String? audioTextHi;
  final String? audioTextTa;
  final String? audioTextEn;
  final String actionLabel;
  final String actionType; // 'quota', 'reminder', 'directive', 'shop'

  const CommunityNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
    required this.isUrgent,
    this.imageUrl,
    this.extraLabel,
    this.extraValue,
    this.audioTextHi,
    this.audioTextTa,
    this.audioTextEn,
    this.actionLabel = 'View Details',
    this.actionType = 'directive',
  });

  factory CommunityNotice.fromMap(Map<String, dynamic> map, String id) {
    DateTime noticeDate = DateTime.now();
    if (map['date'] is Timestamp) {
      noticeDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      noticeDate = DateTime.tryParse(map['date'] as String) ?? DateTime.now();
    }

    return CommunityNotice(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      category: map['category'] as String? ?? 'all',
      date: noticeDate,
      isUrgent: map['isUrgent'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      extraLabel: map['extraLabel'] as String?,
      extraValue: map['extraValue'] as String?,
      audioTextHi: map['audioTextHi'] as String?,
      audioTextTa: map['audioTextTa'] as String?,
      audioTextEn: map['audioTextEn'] as String?,
      actionLabel: map['actionLabel'] as String? ?? 'View Details',
      actionType: map['actionType'] as String? ?? 'directive',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'category': category,
        'date': Timestamp.fromDate(date),
        'isUrgent': isUrgent,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (extraLabel != null) 'extraLabel': extraLabel,
        if (extraValue != null) 'extraValue': extraValue,
        if (audioTextHi != null) 'audioTextHi': audioTextHi,
        if (audioTextTa != null) 'audioTextTa': audioTextTa,
        if (audioTextEn != null) 'audioTextEn': audioTextEn,
        'actionLabel': actionLabel,
        'actionType': actionType,
      };
}

class Grievance {
  final String id;
  final String userId;
  final String userName;
  final String cardNumber;
  final String shopId;
  final String shopName;
  final String category; // 'Shortage', 'Quality', 'Overcharging', 'Shop Closed', 'Biometric Issue'
  final String description;
  final String status; // 'Submitted', 'Under Investigation', 'Resolved'
  final DateTime createdAt;
  final String? resolutionNote;

  const Grievance({
    required this.id,
    required this.userId,
    required this.userName,
    required this.cardNumber,
    required this.shopId,
    required this.shopName,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolutionNote,
  });

  factory Grievance.fromMap(Map<String, dynamic> map, String id) {
    DateTime created = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      created = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      created = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
    }

    return Grievance(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      cardNumber: map['cardNumber'] as String? ?? '',
      shopId: map['shopId'] as String? ?? '',
      shopName: map['shopName'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'Submitted',
      createdAt: created,
      resolutionNote: map['resolutionNote'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'cardNumber': cardNumber,
        'shopId': shopId,
        'shopName': shopName,
        'category': category,
        'description': description,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        if (resolutionNote != null) 'resolutionNote': resolutionNote,
      };
}

class RationTransaction {
  final String id;
  final String userId;
  final String receiptNo;
  final DateTime date;
  final List<String> itemNames;
  final double totalQuantityKg;
  final double totalAmount;
  final String shopName;
  final String verificationType; // 'Aadhaar Biometric', 'OTP Verified', 'Digital Pass'

  const RationTransaction({
    required this.id,
    required this.userId,
    required this.receiptNo,
    required this.date,
    required this.itemNames,
    required this.totalQuantityKg,
    required this.totalAmount,
    required this.shopName,
    this.verificationType = 'Aadhaar Biometric e-POS',
  });

  factory RationTransaction.fromMap(Map<String, dynamic> map, String id) {
    DateTime txDate = DateTime.now();
    if (map['date'] is Timestamp) {
      txDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      txDate = DateTime.tryParse(map['date'] as String) ?? DateTime.now();
    }

    return RationTransaction(
      id: id,
      userId: map['userId'] as String? ?? '',
      receiptNo: map['receiptNo'] as String? ?? 'TXN-${id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase()}',
      date: txDate,
      itemNames: List<String>.from(map['itemNames'] as List? ?? []),
      totalQuantityKg: (map['totalQuantityKg'] as num?)?.toDouble() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      shopName: map['shopName'] as String? ?? 'Fair Price Shop #42',
      verificationType: map['verificationType'] as String? ?? 'Aadhaar Biometric e-POS',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'receiptNo': receiptNo,
        'date': Timestamp.fromDate(date),
        'itemNames': itemNames,
        'totalQuantityKg': totalQuantityKg,
        'totalAmount': totalAmount,
        'shopName': shopName,
        'verificationType': verificationType,
      };
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'stock', 'quota', 'notice', 'grievance'

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'notice',
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    DateTime time = DateTime.now();
    if (map['timestamp'] is Timestamp) {
      time = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      time = DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now();
    }

    return AppNotification(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      timestamp: time,
      isRead: map['isRead'] as bool? ?? false,
      type: map['type'] as String? ?? 'notice',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': isRead,
        'type': type,
      };
}
