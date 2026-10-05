import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore? firestore;

  FirebaseService({this.firestore});

  static final FirebaseService instance = FirebaseService(
    firestore: _getFirestoreSafe(),
  );

  static FirebaseFirestore? _getFirestoreSafe() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // ─── IN-MEMORY REACTIVE DATABASE STATE ───────────────────────────────────────
  RationUser? _currentUser;
  final List<Commodity> _commodities = [];
  final List<ShopCommodity> _shopStock = [];
  final List<CommunityNotice> _notices = [];
  final List<RationTransaction> _transactions = [];
  final List<AppNotification> _notifications = [];
  final List<Grievance> _grievances = [];
  final Shop _currentShop = const Shop(
    id: 'shop_42',
    name: 'Ganesh Fair Price Shop #42',
    dealerName: 'Ganesh Verma (Authorized FPS Dealer)',
    phone: '+91 98765 43210',
    address: 'Ward No. 12, Near Gram Panchayat, Rampur',
    pincode: '600001',
    timing: '7:00 AM – 1:00 PM & 3:00 PM – 7:00 PM • Tue - Sun',
    isOpen: true,
    stockUpdateAgo: 'Live Stock: 15 mins ago',
    queueCount: 4,
    waitTimeMins: 7,
    rating: 4.8,
  );

  // ─── STREAM CONTROLLERS FOR REALTIME UI UPDATES ──────────────────────────────
  final _userController = StreamController<RationUser?>.broadcast();
  final _commoditiesController = StreamController<List<Commodity>>.broadcast();
  final _shopController = StreamController<Shop?>.broadcast();
  final _stockController = StreamController<List<ShopCommodity>>.broadcast();
  final _noticesController = StreamController<List<CommunityNotice>>.broadcast();
  final _transactionsController = StreamController<List<RationTransaction>>.broadcast();
  final _notificationsController = StreamController<List<AppNotification>>.broadcast();

  RationUser? get currentUser => _currentUser;

  // ─── GETTERS FOR REALTIME STREAMS ───────────────────────────────────────────
  Stream<RationUser?> userStream(String uid) {
    if (_currentUser == null) {
      _initDefaultUser(uid);
    }
    // Return a stream that starts with the current in-memory value
    return Stream<RationUser?>.multi((controller) {
      controller.add(_currentUser);
      final sub = _userController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<List<Commodity>> commoditiesStream(String uid) {
    if (_commodities.isEmpty) {
      _seedDefaultCommodities(_currentUser?.cardType ?? 'BPL', _currentUser?.familySize ?? 4);
    }
    return Stream<List<Commodity>>.multi((controller) {
      controller.add(List.unmodifiable(_commodities));
      final sub = _commoditiesController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<Shop?> shopStream(String shopId) {
    return Stream<Shop?>.multi((controller) {
      controller.add(_currentShop);
      final sub = _shopController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<List<ShopCommodity>> shopStockStream(String shopId) {
    if (_shopStock.isEmpty) {
      _seedDefaultShopStock();
    }
    return Stream<List<ShopCommodity>>.multi((controller) {
      controller.add(List.unmodifiable(_shopStock));
      final sub = _stockController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<List<CommunityNotice>> noticesStream() {
    if (_notices.isEmpty) {
      _seedDefaultNotices();
    }
    return Stream<List<CommunityNotice>>.multi((controller) {
      controller.add(List.unmodifiable(_notices));
      final sub = _noticesController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<List<RationTransaction>> transactionsStream(String uid) {
    if (_transactions.isEmpty) {
      _seedDefaultTransactions(uid);
    }
    return Stream<List<RationTransaction>>.multi((controller) {
      controller.add(List.unmodifiable(_transactions));
      final sub = _transactionsController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<List<AppNotification>> notificationsStream(String uid) {
    if (_notifications.isEmpty) {
      _seedDefaultNotifications();
    }
    return Stream<List<AppNotification>>.multi((controller) {
      controller.add(List.unmodifiable(_notifications));
      final sub = _notificationsController.stream.listen(controller.add);
      controller.onCancel = () => sub.cancel();
    });
  }

  // ─── USER INITIALIZATION & PERSISTENCE ─────────────────────────────────────
  Future<RationUser> initializeUserSession({
    required String uid,
    String? name,
    String? email,
    String? phone,
    String? cardType,
    String? cardNumber,
    int? familySize,
    String role = 'beneficiary',
  }) async {
    final chosenCardType = cardType ?? 'BPL';
    final isAay = chosenCardType == 'AAY';
    final chosenName = name ?? (isAay ? 'Shanti Devi' : 'Ramesh Kumar');
    final chosenCardNumber = cardNumber ?? (isAay ? '9182-4029-7712' : '4829-1092-8821');
    final chosenFamilySize = familySize ?? (isAay ? 5 : 4);

    // ── Family members start EMPTY — user adds them manually ─────────────────
    // Preserve existing members if session is already active (don't wipe on re-init)
    final existingMembers = (_currentUser?.uid == uid) ? _currentUser!.familyMembers : <FamilyMember>[];

    final user = RationUser(
      uid: uid,
      name: chosenName,
      email: email ?? (isAay ? 'antyodaya.demo@ration.gov.in' : 'bpl.beneficiary@ration.gov.in'),
      phone: phone ?? '+91 98451 23098',
      nfsaId: 'NFSA-${uid.substring(0, uid.length > 6 ? 6 : uid.length).toUpperCase()}',
      cardType: chosenCardType,
      cardNumber: chosenCardNumber,
      familySize: chosenFamilySize,
      shopId: 'shop_42',
      shopName: 'Ganesh PDS Kendra #42',
      shopAddress: 'Ward No. 12, Near Gram Panchayat, Rampur',
      shopDealerName: 'Ganesh Verma (Dealer ID: FPS-429)',
      shopDealerPhone: '+91 98765 43210',
      isAadhaarLinked: true,
      state: 'Tamil Nadu / Uttar Pradesh',
      district: 'Central Zone - Ward 12',
      pincode: '600001',
      familyMembers: existingMembers,
      lastClaimDate: role == 'shopkeeper' ? null : DateTime.now().subtract(const Duration(days: 4)),
      role: role,
    );

    _currentUser = user;
    _userController.add(_currentUser);

    _seedDefaultCommodities(chosenCardType, chosenFamilySize);
    _seedDefaultShopStock();
    _seedDefaultNotices();
    _seedDefaultTransactions(uid);
    _seedDefaultNotifications();

    // Also attempt Firestore persistence in background if available
    _syncUserToFirestore(user);

    return user;
  }

  void _initDefaultUser(String uid) {
    initializeUserSession(uid: uid);
  }

  Future<void> ensureUserInitialized(
    User firebaseUser, {
    String? name,
    String? cardType,
    String? cardNumber,
    int? familySize,
    String? phone,
  }) async {
    await initializeUserSession(
      uid: firebaseUser.uid,
      name: name ?? (firebaseUser.displayName?.isNotEmpty == true ? firebaseUser.displayName : null),
      email: firebaseUser.email,
      phone: phone,
      cardType: cardType,
      cardNumber: cardNumber,
      familySize: familySize,
    );
  }

  // ─── FAMILY MEMBER MANAGEMENT (manual by user) ────────────────────────────
  Future<void> addFamilyMember(String uid, FamilyMember member) async {
    if (_currentUser == null) return;
    final updated = List<FamilyMember>.from(_currentUser!.familyMembers)..add(member);
    _currentUser = _currentUser!.copyWith(
      familyMembers: updated,
      familySize: updated.length,
    );
    _userController.add(_currentUser);
    if (firestore != null) {
      try {
        await firestore!.collection('users').doc(uid).update({
          'familyMembers': updated.map((m) => m.toMap()).toList(),
          'familySize': updated.length,
        });
      } catch (e) {
        debugPrint('Firestore addFamilyMember error: $e');
      }
    }
  }

  Future<void> removeFamilyMember(String uid, int index) async {
    if (_currentUser == null) return;
    final updated = List<FamilyMember>.from(_currentUser!.familyMembers)..removeAt(index);
    _currentUser = _currentUser!.copyWith(
      familyMembers: updated,
      familySize: updated.length,
    );
    _userController.add(_currentUser);
    if (firestore != null) {
      try {
        await firestore!.collection('users').doc(uid).update({
          'familyMembers': updated.map((m) => m.toMap()).toList(),
          'familySize': updated.length,
        });
      } catch (e) {
        debugPrint('Firestore removeFamilyMember error: $e');
      }
    }
  }

  Future<void> _syncUserToFirestore(RationUser user) async {
    if (firestore == null) return;
    try {
      final docRef = firestore!.collection('users').doc(user.uid);
      await docRef.set(user.toMap(), SetOptions(merge: true));

      final batch = firestore!.batch();
      final commoditiesRef = docRef.collection('commodities');
      for (final item in _commodities) {
        batch.set(commoditiesRef.doc(item.id), item.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore sync notice: $e');
    }
  }

  // ─── SEED COMMODITIES ──────────────────────────────────────────────────────
  Future<void> seedUserCommodities(String uid, [String cardType = 'BPL', int familySize = 4]) async {
    _seedDefaultCommodities(cardType, familySize);
    _commoditiesController.add(List.unmodifiable(_commodities));

    if (firestore != null) {
      try {
        final batch = firestore!.batch();
        final commoditiesRef = firestore!.collection('users').doc(uid).collection('commodities');
        for (final item in _commodities) {
          batch.set(commoditiesRef.doc(item.id), item.toMap());
        }
        await batch.commit();
      } catch (e) {
        debugPrint('Firestore seed commodities error: $e');
      }
    }
  }

  void _seedDefaultCommodities(String cardType, int familySize) {
    _commodities.clear();
    final double stapleQty = (familySize * 5.0).clamp(15.0, 35.0);
    final isAay = cardType == 'AAY';

    _commodities.addAll([
      Commodity(
        id: 'c_rice',
        name: 'Rice (Raw / Boiled)',
        localName: 'அரிசி / Chawal',
        icon: 'grain',
        quantity: stapleQty,
        unit: 'kg',
        pricePerUnit: isAay ? 0.0 : 3.0,
        status: EntitlementStatus.available,
        schemeNote: '5 kg × $familySize members under NFSA',
        category: 'Staples',
      ),
      Commodity(
        id: 'c_wheat',
        name: 'Fortified Wheat / Atta',
        localName: 'கோதுமை / Gehun',
        icon: 'grass',
        quantity: stapleQty,
        unit: 'kg',
        pricePerUnit: isAay ? 0.0 : 2.0,
        status: EntitlementStatus.available,
        schemeNote: '5 kg × $familySize members under PMGKAY',
        category: 'Staples',
      ),
      Commodity(
        id: 'c_sugar',
        name: 'Refined Sugar',
        localName: 'சர்க்கரை / Cheeni',
        icon: 'cookie',
        quantity: 1.0,
        unit: 'kg',
        pricePerUnit: isAay ? 0.0 : 13.5,
        status: EntitlementStatus.available,
        schemeNote: 'Flat family monthly allocation',
        category: 'Essential',
      ),
      const Commodity(
        id: 'c_dal',
        name: 'Toor Dal / Chana Dal',
        localName: 'பருப்பு / Dal',
        icon: 'spa',
        quantity: 2.0,
        unit: 'kg',
        pricePerUnit: 15.0,
        status: EntitlementStatus.collected,
        schemeNote: 'State Nutritional Support Scheme',
        category: 'Pulses',
      ),
      const Commodity(
        id: 'c_oil',
        name: 'Fortified Mustard Oil',
        localName: 'எண்ணெய் / Sarsou',
        icon: 'water_drop',
        quantity: 1.0,
        unit: 'L',
        pricePerUnit: 30.0,
        status: EntitlementStatus.collected,
        schemeNote: 'Vitamin A & D enriched ration',
        category: 'Cooking Oil',
      ),
      const Commodity(
        id: 'c_salt',
        name: 'Iodized Salt',
        localName: 'உப்பு / Namak',
        icon: 'science',
        quantity: 1.0,
        unit: 'kg',
        pricePerUnit: 1.0,
        status: EntitlementStatus.available,
        schemeNote: 'Double fortified iodine & iron',
        category: 'Essential',
      ),
    ]);
  }

  // ─── CLAIM COMMODITIES & TRANSACTIONS ──────────────────────────────────────
  Future<void> claimCommodity(String uid, String commodityId) async {
    final idx = _commodities.indexWhere((c) => c.id == commodityId);
    if (idx != -1) {
      final old = _commodities[idx];
      _commodities[idx] = Commodity(
        id: old.id,
        name: old.name,
        localName: old.localName,
        icon: old.icon,
        quantity: old.quantity,
        unit: old.unit,
        pricePerUnit: old.pricePerUnit,
        status: EntitlementStatus.collected,
        schemeNote: old.schemeNote,
        category: old.category,
        lastCollectedDate: DateTime.now(),
      );
      _commoditiesController.add(List.unmodifiable(_commodities));

      // Create transaction
      final tx = RationTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        userId: uid,
        receiptNo: 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        date: DateTime.now(),
        itemNames: [old.name],
        totalQuantityKg: old.quantity,
        totalAmount: old.quantity * old.pricePerUnit,
        shopName: _currentShop.name,
        verificationType: 'Aadhaar Biometric e-POS',
      );
      _transactions.insert(0, tx);
      _transactionsController.add(List.unmodifiable(_transactions));

      // Add Notification
      addNotification(
        uid: uid,
        title: '${old.name} Claimed Successfully',
        body: 'Collected ${old.quantity} ${old.unit} at ${_currentShop.name}. e-Receipt generated.',
        type: 'quota',
      );

      // Background Firestore update
      if (firestore != null) {
        try {
          await firestore!
              .collection('users')
              .doc(uid)
              .collection('commodities')
              .doc(commodityId)
              .update({
            'status': EntitlementStatus.collected.name,
            'lastCollectedDate': Timestamp.now(),
          });
          await firestore!.collection('transactions').doc(tx.id).set(tx.toMap());
        } catch (e) {
          debugPrint('Firestore claim update error: $e');
        }
      }
    }
  }

  Future<RationTransaction> claimAllPendingCommodities(String uid) async {
    List<String> claimedNames = [];
    double totalKg = 0;
    double totalAmt = 0;

    for (int i = 0; i < _commodities.length; i++) {
      final item = _commodities[i];
      if (item.status != EntitlementStatus.collected) {
        _commodities[i] = Commodity(
          id: item.id,
          name: item.name,
          localName: item.localName,
          icon: item.icon,
          quantity: item.quantity,
          unit: item.unit,
          pricePerUnit: item.pricePerUnit,
          status: EntitlementStatus.collected,
          schemeNote: item.schemeNote,
          category: item.category,
          lastCollectedDate: DateTime.now(),
        );
        claimedNames.add(item.name);
        totalKg += item.quantity;
        totalAmt += (item.quantity * item.pricePerUnit);
      }
    }

    _commoditiesController.add(List.unmodifiable(_commodities));

    final tx = RationTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: uid,
      receiptNo: 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      date: DateTime.now(),
      itemNames: claimedNames.isNotEmpty ? claimedNames : ['All Monthly Quota Items'],
      totalQuantityKg: totalKg > 0 ? totalKg : 15.0,
      totalAmount: totalAmt,
      shopName: _currentShop.name,
      verificationType: 'Aadhaar Biometric e-POS',
    );

    _transactions.insert(0, tx);
    _transactionsController.add(List.unmodifiable(_transactions));

    if (_currentUser != null) {
      _currentUser = RationUser(
        uid: _currentUser!.uid,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        nfsaId: _currentUser!.nfsaId,
        cardType: _currentUser!.cardType,
        cardNumber: _currentUser!.cardNumber,
        familySize: _currentUser!.familySize,
        shopId: _currentUser!.shopId,
        shopName: _currentUser!.shopName,
        shopAddress: _currentUser!.shopAddress,
        shopDealerName: _currentUser!.shopDealerName,
        shopDealerPhone: _currentUser!.shopDealerPhone,
        isAadhaarLinked: _currentUser!.isAadhaarLinked,
        state: _currentUser!.state,
        district: _currentUser!.district,
        pincode: _currentUser!.pincode,
        familyMembers: _currentUser!.familyMembers,
        lastClaimDate: DateTime.now(),
      );
      _userController.add(_currentUser);
    }

    addNotification(
      uid: uid,
      title: 'Full Quota Collected! 🎉',
      body: 'Successfully claimed ${claimedNames.length} items (${totalKg.toStringAsFixed(1)} kg) for this billing cycle.',
      type: 'quota',
    );

    if (firestore != null) {
      try {
        final batch = firestore!.batch();
        final commRef = firestore!.collection('users').doc(uid).collection('commodities');
        for (final item in _commodities) {
          batch.update(commRef.doc(item.id), {
            'status': EntitlementStatus.collected.name,
            'lastCollectedDate': Timestamp.now(),
          });
        }
        await batch.commit();
        await firestore!.collection('transactions').doc(tx.id).set(tx.toMap());
      } catch (e) {
        debugPrint('Firestore claimAll error: $e');
      }
    }

    return tx;
  }

  Future<void> resetMonthlyQuota(String uid) async {
    for (int i = 0; i < _commodities.length; i++) {
      final item = _commodities[i];
      _commodities[i] = Commodity(
        id: item.id,
        name: item.name,
        localName: item.localName,
        icon: item.icon,
        quantity: item.quantity,
        unit: item.unit,
        pricePerUnit: item.pricePerUnit,
        status: EntitlementStatus.available,
        schemeNote: item.schemeNote,
        category: item.category,
        lastCollectedDate: null,
      );
    }
    _commoditiesController.add(List.unmodifiable(_commodities));

    if (firestore != null) {
      try {
        final batch = firestore!.batch();
        final commRef = firestore!.collection('users').doc(uid).collection('commodities');
        for (final item in _commodities) {
          batch.update(commRef.doc(item.id), {
            'status': EntitlementStatus.available.name,
            'lastCollectedDate': null,
          });
        }
        await batch.commit();
      } catch (e) {
        debugPrint('Firestore reset quota error: $e');
      }
    }
  }

  // ─── GRIEVANCES ────────────────────────────────────────────────────────────
  Future<String> fileGrievance({
    required String userId,
    required String userName,
    required String cardNumber,
    required String shopId,
    required String shopName,
    required String category,
    required String description,
  }) async {
    final id = 'GRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final grievance = Grievance(
      id: id,
      userId: userId,
      userName: userName,
      cardNumber: cardNumber,
      shopId: shopId,
      shopName: shopName,
      category: category,
      description: description,
      status: 'Submitted',
      createdAt: DateTime.now(),
      resolutionNote: 'Assigned to Taluk Food Supply Officer (Ward 12). Expected resolution in 48 hours.',
    );

    _grievances.insert(0, grievance);

    addNotification(
      uid: userId,
      title: 'Grievance Registered (#${id.toUpperCase()})',
      body: 'Your complaint regarding $category has been logged with the Taluk Supply Office.',
      type: 'grievance',
    );

    if (firestore != null) {
      try {
        await firestore!.collection('grievances').doc(id).set(grievance.toMap());
      } catch (e) {
        debugPrint('Firestore grievance error: $e');
      }
    }

    return id;
  }

  // ─── NOTICES ───────────────────────────────────────────────────────────────
  Future<String> postNotice(CommunityNotice notice) async {
    final id = notice.id.isNotEmpty ? notice.id : 'n_${DateTime.now().millisecondsSinceEpoch}';
    final newNotice = CommunityNotice(
      id: id,
      title: notice.title,
      body: notice.body,
      category: notice.category,
      date: notice.date,
      isUrgent: notice.isUrgent,
      imageUrl: notice.imageUrl,
      extraLabel: notice.extraLabel,
      extraValue: notice.extraValue,
      audioTextHi: notice.audioTextHi,
      audioTextTa: notice.audioTextTa,
      audioTextEn: notice.audioTextEn ?? notice.body,
      actionLabel: notice.actionLabel,
      actionType: notice.actionType,
    );

    _notices.insert(0, newNotice);
    _noticesController.add(List.unmodifiable(_notices));

    if (_currentUser != null) {
      addNotification(
        uid: _currentUser!.uid,
        title: 'New Announcement: ${newNotice.title}',
        body: newNotice.body,
        type: 'notice',
      );
    }

    if (firestore != null) {
      try {
        await firestore!.collection('notices').doc(id).set(newNotice.toMap());
      } catch (e) {
        debugPrint('Firestore post notice error: $e');
      }
    }

    return id;
  }

  // ─── NOTIFICATIONS ─────────────────────────────────────────────────────────
  Future<void> addNotification({
    required String uid,
    required String title,
    required String body,
    String type = 'notice',
  }) async {
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${_notifications.length}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
    );

    _notifications.insert(0, notification);
    _notificationsController.add(List.unmodifiable(_notifications));

    if (firestore != null) {
      try {
        await firestore!
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toMap());
      } catch (e) {
        debugPrint('Firestore notification error: $e');
      }
    }
  }

  Future<void> markNotificationRead(String uid, String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final old = _notifications[idx];
      _notifications[idx] = AppNotification(
        id: old.id,
        title: old.title,
        body: old.body,
        timestamp: old.timestamp,
        isRead: true,
        type: old.type,
      );
      _notificationsController.add(List.unmodifiable(_notifications));
    }

    if (firestore != null) {
      try {
        await firestore!
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
      } catch (e) {
        debugPrint('Firestore markRead error: $e');
      }
    }
  }

  Future<void> markAllNotificationsRead(String uid) async {
    for (int i = 0; i < _notifications.length; i++) {
      final old = _notifications[i];
      _notifications[i] = AppNotification(
        id: old.id,
        title: old.title,
        body: old.body,
        timestamp: old.timestamp,
        isRead: true,
        type: old.type,
      );
    }
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  // ─── DEFAULT SEED DATA HELPERS ─────────────────────────────────────────────
  void _seedDefaultShopStock() {
    _shopStock.clear();
    _shopStock.addAll([
      const ShopCommodity(
        id: 'st_rice',
        name: 'Rice (Raw / Boiled)',
        localName: 'அரிசி / Chawal',
        icon: 'grain',
        pricePerUnit: 3.0,
        unit: 'kg',
        stockStatus: StockStatus.available,
        stockKg: 12500.0,
        cap: '5kg/unit • Antyodaya & BPL',
        category: 'Grains',
      ),
      const ShopCommodity(
        id: 'st_wheat',
        name: 'Wheat (Grade A)',
        localName: 'கோதுமை / Gehun',
        icon: 'grass',
        pricePerUnit: 2.0,
        unit: 'kg',
        stockStatus: StockStatus.available,
        stockKg: 8400.0,
        cap: '5kg/unit • Standard Allocation',
        category: 'Grains',
      ),
      const ShopCommodity(
        id: 'st_sugar',
        name: 'Refined Sugar',
        localName: 'சர்க்கரை / Cheeni',
        icon: 'cookie',
        pricePerUnit: 13.5,
        unit: 'kg',
        stockStatus: StockStatus.lowStock,
        replenishmentNote: '< 40 kg left in stock (Fresh consignment arriving tomorrow)',
        stockKg: 38.0,
        cap: '1kg/card',
        category: 'Sugar & Essentials',
      ),
      const ShopCommodity(
        id: 'st_dal',
        name: 'Split Toor Dal',
        localName: 'பருப்பு / Dal',
        icon: 'spa',
        pricePerUnit: 15.0,
        unit: 'kg',
        stockStatus: StockStatus.available,
        stockKg: 1200.0,
        cap: '1kg/card • Protein Quota',
        category: 'Pulses',
      ),
      const ShopCommodity(
        id: 'st_oil',
        name: 'Mustard Oil (Pouch)',
        localName: 'எண்ணெய் / Sarsou',
        icon: 'water_drop',
        pricePerUnit: 30.0,
        unit: 'L',
        stockStatus: StockStatus.available,
        stockKg: 650.0,
        cap: '2L/card • Fortified',
        category: 'Oils',
      ),
      const ShopCommodity(
        id: 'st_kerosene',
        name: 'Subsidized Kerosene',
        localName: 'மண்ணெண்ணெய்',
        icon: 'oil_barrel',
        pricePerUnit: 18.0,
        unit: 'L',
        stockStatus: StockStatus.outOfStock,
        replenishmentNote: 'Expected tanker replenishment on Friday',
        stockKg: 0.0,
        cap: '2L/card (Non-LPG Households)',
        category: 'Fuel',
      ),
    ]);
  }

  void _seedDefaultNotices() {
    _notices.clear();
    _notices.addAll([
      CommunityNotice(
        id: 'n_1',
        title: 'Fresh Ponni Rice & Sugar Consignment Received',
        body: 'We have received 500 bags of Ponni Rice and 100 bags of Refined Sugar at Kendra #42. Biometric counters are operational with zero wait times this morning. Please collect your quotas.',
        category: 'stock',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        isUrgent: true,
        extraLabel: 'Stock Status',
        extraValue: '12,500 kg Available',
        audioTextHi: 'गणेश राशन दुकान में 500 बोरी चावल और 100 बोरी चीनी का नया स्टॉक आ चुका है। वितरण चालू है।',
        audioTextTa: 'ரேஷன் கடை எண் 42 இல் 500 மூட்டை பொன்னி அரிசி மற்றும் சர்க்கரை வந்துள்ளது. வந்து பெற்றுக் கொள்ளவும்.',
        audioTextEn: 'Fresh consignment of Ponni Rice and refined sugar has arrived at FPS Kendra #42. Distribution is ongoing.',
        actionLabel: 'Check My Quota',
        actionType: 'quota',
      ),
      CommunityNotice(
        id: 'n_2',
        title: 'Shop Closure Notice for Upcoming Holiday',
        body: 'Fair Price Shop #42 will remain closed on Friday for the public holiday. All beneficiaries are requested to collect their allocated ration before Thursday 7:00 PM.',
        category: 'timings',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isUrgent: false,
        extraLabel: 'Holiday Date',
        extraValue: 'Upcoming Friday (All Day)',
        audioTextHi: 'सार्वजनिक अवकाश के कारण आगामी शुक्रवार को राशन दुकान बंद रहेगी। कृपया गुरुवार तक राशन प्राप्त कर लें।',
        audioTextTa: 'பொது விடுமுறை காரணமாக வரும் வெள்ளிக்கிழமை கடை இயங்காது. வியாழக்கிழமைக்குள் பெற்றுக் கொள்ளவும்.',
        audioTextEn: 'Fair price shop will remain closed on Friday for public holiday. Please collect quota by Thursday.',
        actionLabel: 'Set Reminder',
        actionType: 'reminder',
      ),
      CommunityNotice(
        id: 'n_3',
        title: 'Extra 1kg Chana Dal Under Garib Kalyan Scheme',
        body: 'Under the expanded Central Food Security directive, all BPL and Antyodaya (AAY) cardholders are entitled to an additional 1 kg Chana Dal free of cost this billing cycle.',
        category: 'schemes',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isUrgent: false,
        extraLabel: 'Eligible Cards',
        extraValue: 'BPL & AAY Cards',
        audioTextHi: 'गरीब कल्याण योजना के तहत सभी बीपीएल और अंत्योदय कार्ड धारकों को 1 किलो चना दाल मुफ्त दी जाएगी।',
        audioTextTa: 'அனைத்து பிபிஎல் மற்றும் ஏஏஒய் அட்டைதாரர்களுக்கு கூடுதல் 1 கிலோ பருப்பு இலவசமாக வழங்கப்படும்.',
        audioTextEn: 'All BPL and AAY cardholders are eligible for an extra 1kg Chana Dal free this month.',
        actionLabel: 'Read Directive',
        actionType: 'directive',
      ),
    ]);
  }

  void _seedDefaultTransactions(String uid) {
    _transactions.clear();
    _transactions.addAll([
      RationTransaction(
        id: 'tx_prev_1',
        userId: uid,
        receiptNo: 'RCP-89421',
        date: DateTime.now().subtract(const Duration(days: 4)),
        itemNames: ['Toor Dal / Chana Dal (2 kg)', 'Fortified Mustard Oil (1 L)'],
        totalQuantityKg: 3.0,
        totalAmount: 60.0,
        shopName: 'Ganesh Fair Price Shop #42',
        verificationType: 'Aadhaar Biometric e-POS',
      ),
      RationTransaction(
        id: 'tx_prev_2',
        userId: uid,
        receiptNo: 'RCP-77810',
        date: DateTime.now().subtract(const Duration(days: 34)),
        itemNames: ['Rice (20 kg)', 'Fortified Wheat (20 kg)', 'Refined Sugar (1 kg)'],
        totalQuantityKg: 41.0,
        totalAmount: 113.5,
        shopName: 'Ganesh Fair Price Shop #42',
        verificationType: 'Aadhaar Biometric e-POS',
      ),
    ]);
  }

  void _seedDefaultNotifications() {
    _notifications.clear();
    _notifications.addAll([
      AppNotification(
        id: 'notif_1',
        title: 'Fresh Stock Arrived at Kendra #42',
        body: '500 Bags of Rice & Sugar unloaded. Biometric counters open.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
        type: 'stock',
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Monthly Quota Allocation Ready',
        body: 'Your September ration allocation has been updated for all family members.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        type: 'quota',
      ),
    ]);
  }

  Future<void> seedGlobalDataIfNeeded() async {
    // Kept for backward compatibility
  }

  void clearSession() {
    _currentUser = null;
    _userController.add(null);
  }
}

