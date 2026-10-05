import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../auth/providers/auth_provider.dart';

// ─── Active filter tab provider ───────────────────────────────────────────────
final noticeFilterProvider = StateProvider<String>((ref) => 'all');

// ─── Voice Broadcast playback state ──────────────────────────────────────────
final activeAudioNoticeIdProvider = StateProvider<String?>((ref) => null);
final selectedAudioLangProvider = StateProvider<String>((ref) => 'hi'); // 'hi', 'ta', 'en'

// ─── Notices stream provider ─────────────────────────────────────────────────
final noticesProvider = StreamProvider<List<CommunityNotice>>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.noticesStream();
});

// ─── Filtered notices based on active category ───────────────────────────────
final filteredNoticesProvider =
    Provider<AsyncValue<List<CommunityNotice>>>((ref) {
  final filter = ref.watch(noticeFilterProvider);
  final noticesAsync = ref.watch(noticesProvider);

  return noticesAsync.whenData((notices) {
    if (filter == 'all') return notices;
    if (filter == 'urgent') return notices.where((n) => n.isUrgent).toList();
    return notices.where((n) => n.category.toLowerCase() == filter.toLowerCase()).toList();
  });
});
