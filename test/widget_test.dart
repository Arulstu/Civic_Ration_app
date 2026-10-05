import 'package:flutter_test/flutter_test.dart';
import 'package:ration/core/models/models.dart';

void main() {
  group('Civic Harvest Core Models & Logic Unit Tests', () {
    test('RationUser serializes and deserializes correctly', () {
      final user = RationUser(
        uid: 'user_123',
        name: 'Ramesh Kumar',
        email: 'ramesh@ration.gov.in',
        phone: '+91 98451 23098',
        nfsaId: 'NFSA-123456',
        cardType: 'BPL',
        cardNumber: '4829-1092-8821',
        familySize: 4,
        shopId: 'shop_42',
        shopName: 'Ganesh Fair Price Shop #42',
        shopAddress: 'Ward No. 12, Rampur',
        isAadhaarLinked: true,
      );

      final map = user.toMap();
      expect(map['name'], 'Ramesh Kumar');
      expect(map['cardType'], 'BPL');
      expect(map['familySize'], 4);

      final fromMapUser = RationUser.fromMap(map, 'user_123');
      expect(fromMapUser.uid, 'user_123');
      expect(fromMapUser.name, 'Ramesh Kumar');
      expect(fromMapUser.cardNumber, '4829-1092-8821');
    });

    test('Commodity model handles serialization and status properly', () {
      const commodity = Commodity(
        id: 'c_rice',
        name: 'Rice (Raw / Boiled)',
        localName: 'அரிசி / Chawal',
        icon: 'grain',
        quantity: 20.0,
        unit: 'kg',
        pricePerUnit: 3.0,
        status: EntitlementStatus.available,
        schemeNote: '5 kg x 4 members under NFSA',
        category: 'Staples',
      );

      final map = commodity.toMap();
      expect(map['name'], 'Rice (Raw / Boiled)');
      expect(map['quantity'], 20.0);
      expect(map['status'], 'available');

      final fromMapCommodity = Commodity.fromMap(map, 'c_rice');
      expect(fromMapCommodity.id, 'c_rice');
      expect(fromMapCommodity.status, EntitlementStatus.available);
      expect(fromMapCommodity.quantity, 20.0);
    });

    test('CommunityNotice model serializes fields', () {
      final notice = CommunityNotice(
        id: 'n_1',
        title: 'Fresh Grain Consignment Arrived',
        body: 'Stocks of wheat and rice are available.',
        category: 'stock',
        date: DateTime(2026, 9, 30),
        isUrgent: true,
        extraLabel: 'Stock',
        extraValue: '500 Bags',
      );

      final map = notice.toMap();
      expect(map['title'], 'Fresh Grain Consignment Arrived');
      expect(map['category'], 'stock');
      expect(map['isUrgent'], true);
    });

    test('Shop model creates valid shop entity', () {
      const shop = Shop(
        id: 'shop_42',
        name: 'Ganesh Fair Price Shop #42',
        dealerName: 'Ganesh Verma',
        phone: '+91 98765 43210',
        address: 'Ward No. 12, Rampur',
        pincode: '600001',
      );

      final map = shop.toMap();
      expect(map['name'], 'Ganesh Fair Price Shop #42');
      expect(map['dealerName'], 'Ganesh Verma');
    });
  });
}
