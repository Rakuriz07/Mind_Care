import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mindcare/models/app_models.dart';

/// ============================================================================
/// FIREBASE COMMUNITY SERVICE (Layanan Komunitas Cloud Firestore)
/// ----------------------------------------------------------------------------
/// 📖 KAMUS KONSEP & KATA KUNCI PENTING UNTUK BELAJAR:
///
/// 1. `async` (Asynchronous):
///    Penanda bahwa sebuah fungsi berjalan secara *asinkronus* (di latar belakang).
///    Fungsi `async` tidak membekukan (freeze) layar UI saat menunggu data dari server.
///
/// 2. `await` (Wait / Menunggu):
///    Perintah untuk MENUNGGU proses operasi jaringan atau database selesai
///    sebelum melanjutkan ke baris perintah berikutnya di dalam fungsi `async`.
///
/// 3. `Future<T>` (Nilai Masa Depan):
///    Objek janji (promise) yang akan menghasilkan SATU NILAI di masa depan
///    setelah operasi asinkronus (seperti menyimpan data ke Firebase) selesai.
///
/// 4. `Stream<T>` (Aliran Data Real-Time):
///    Pipa data berkelanjutan yang secara otomatis memancarkan data baru ke UI
///    setiap kali terjadi perubahan data di database server (Real-Time Live Update).
///
/// 5. `runTransaction`:
///    Fitur transaksi aman di Cloud Firestore. Memastikan pembacaan dan penulisan data
///    terisolasi secara utuh (atomic), sehingga angka Like/Komentar tidak pernah bentrok
///    meskipun banyak pengguna mengklik secara bersamaan.
/// ============================================================================
class FirebaseCommunityService {
  // Singleton Pattern: Memastikan hanya ada 1 instance layanan yang berjalan di seluruh aplikasi.
  static final FirebaseCommunityService _instance =
      FirebaseCommunityService._internal();
  static FirebaseCommunityService get instance => _instance;

  FirebaseCommunityService._internal();

  // Instance Cloud Firestore untuk mengakses koleksi & dokumen di server Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referensi ke koleksi dokumen 'community_posts' di Cloud Firestore
  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('community_posts');

  // Referensi ke koleksi dokumen 'notifications' di Cloud Firestore
  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  /// ==========================================================================
  /// 1. STREAM POSTINGAN KOMUNITAS REAL-TIME (`Stream<List<CommunityPost>>`)
  /// --------------------------------------------------------------------------
  /// Penjelasan: Mengembalikan `Stream` (aliran data live). Setiap kali ada pengguna
  /// baru yang membuat cerita atau memberi komentar di Firebase, fungsi `.snapshots()`
  /// akan otomatis mengirimkan daftar postingan terbaru ke UI.
  /// ==========================================================================
  Stream<List<CommunityPost>> streamCommunityPosts({String? currentUserEmail}) {
    // `.snapshots()` mendengarkan perubahan realtime dari koleksi Firestore
    return _postsRef.snapshots().map((snapshot) {
      // `.map()` mengubah setiap dokumen Firestore menjadi objek CommunityPost
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        final likedBy = List<String>.from(data['likedByEmails'] ?? []);
        final isLiked = currentUserEmail != null &&
            currentUserEmail.isNotEmpty &&
            likedBy.contains(currentUserEmail.toLowerCase().trim());

        final commentsRaw = (data['comments'] as List? ?? []);
        final comments = commentsRaw
            .map((c) => CommunityComment.fromJson(Map<String, dynamic>.from(c)))
            .toList();

        return CommunityPost(
          id: doc.id,
          authorEmail: data['authorEmail'] as String? ?? '',
          authorPseudonym: data['authorPseudonym'] as String? ?? 'Anonim',
          authorAvatar: data['authorAvatar'] as String? ?? '',
          authorMood: data['authorMood'] as String? ?? 'Butuh Teman 🫂',
          content: data['content'] as String? ?? '',
          categoryTag: data['categoryTag'] as String? ?? '#Semua',
          likesCount: data['likesCount'] as int? ?? likedBy.length,
          commentsCount: data['commentsCount'] as int? ?? comments.length,
          date: data['dateStr'] as String? ?? _formatTimestamp(data['createdAt']),
          isLiked: isLiked,
          comments: comments,
        );
      }).toList();

      // Urutkan postingan berdasarkan ID / waktu terbaru di posisi paling atas
      posts.sort((a, b) => b.id.compareTo(a.id));
      return posts;
    });
  }

  /// ==========================================================================
  /// 2. STREAM NOTIFIKASI PENGGUNA REAL-TIME (`Stream<List<AppNotification>>`)
  /// --------------------------------------------------------------------------
  /// Penjelasan: Mendengarkan koleksi 'notifications' yang `recipientEmail`-nya cocok
  /// dengan email pengguna aktif. Jika ada notifikasi baru, UI lonceng akan langsung menyala.
  /// ==========================================================================
  Stream<List<AppNotification>> streamNotifications({required String userEmail}) {
    final cleanEmail = userEmail.toLowerCase().trim();
    if (cleanEmail.isEmpty) return Stream.value([]);

    return _notificationsRef
        .where('recipientEmail', isEqualTo: cleanEmail)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return AppNotification(
          id: doc.id,
          title: data['title'] as String? ?? 'Dukungan Baru 💬',
          message: data['message'] as String? ?? '',
          date: data['dateStr'] as String? ?? _formatTimestamp(data['createdAt']),
          senderPseudonym: data['senderPseudonym'] as String? ?? 'Teman MindCare',
          senderAvatar: data['senderAvatar'] as String? ?? '',
          recipientEmail: data['recipientEmail'] as String? ?? cleanEmail,
          targetPostId: data['targetPostId'] as String? ?? '',
          type: data['type'] as String? ?? 'comment',
          isRead: data['isRead'] as bool? ?? false,
        );
      }).toList();
      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    });
  }

  /// ==========================================================================
  /// 3. MEMBUAT POSTINGAN CERITA BARU (`Future<void> createPost`)
  /// --------------------------------------------------------------------------
  /// Penjelasan: `async` & `await` digunakan di sini karena menyimpan data ke server
  /// membutuhkan waktu pengiriman jaringan (network latency).
  /// ==========================================================================
  Future<void> createPost(CommunityPost post) async {
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final docRef = post.id.isNotEmpty ? _postsRef.doc(post.id) : _postsRef.doc();
      
      await docRef.set({
        'id': docRef.id,
        'authorId': currentUid,
        'authorEmail': post.authorEmail.toLowerCase().trim(),
        'authorPseudonym': post.authorPseudonym,
        'authorAvatar': post.authorAvatar,
        'authorMood': post.authorMood,
        'content': post.content,
        'categoryTag': post.categoryTag,
        'likesCount': 0,
        'commentsCount': 0,
        'likedByEmails': [],
        'comments': [],
        'dateStr': post.date,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating community post in Firebase: $e');
    }
  }

  /// ==========================================================================
  /// 4. MENGHAPUS POSTINGAN CERITA (`Future<void> deletePost`)
  /// ==========================================================================
  Future<void> deletePost(String postId) async {
    try {
      // `await` menunggu penghapusan dokumen di Cloud Firestore selesai
      await _postsRef.doc(postId).delete();
    } catch (_) {}
  }

  /// ==========================================================================
  /// 5. TOGGLE LIKE / PELUKAN HANGAT (Firestore Transaction)
  /// --------------------------------------------------------------------------
  /// Penjelasan: Menggunakan `runTransaction` agar penambahan/pengurangan Like
  /// diuji terlebih dahulu oleh Firestore server, menghindari konflik jika 2 user meng-like bersamaan.
  /// ==========================================================================
  Future<void> toggleLike(
    String postId,
    String userEmail, {
    String senderPseudonym = 'Teman MindCare',
    String senderAvatar = '',
  }) async {
    final docRef = _postsRef.doc(postId);
    final cleanEmail = userEmail.toLowerCase().trim();

    try {
      // Execute `runTransaction` secara asinkronus dengan `await`
      await _firestore.runTransaction((transaction) async {
        // Ambil data snapshot terbaru dari Firestore
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final likedBy = List<String>.from(data['likedByEmails'] ?? []);
        int likesCount = data['likesCount'] as int? ?? 0;
        final bool alreadyLiked = likedBy.contains(cleanEmail);

        if (alreadyLiked) {
          likedBy.remove(cleanEmail);
          likesCount = (likesCount - 1).clamp(0, 999999);
        } else {
          likedBy.add(cleanEmail);
          likesCount += 1;

          // Buat dokumen notifikasi baru untuk penulis postingan jika disukai pengguna lain
          final authorEmail =
              (data['authorEmail'] as String? ?? '').toLowerCase().trim();
          if (authorEmail.isNotEmpty && authorEmail != cleanEmail) {
            final content = (data['content'] as String? ?? '');
            final snippet =
                content.length > 35 ? '${content.substring(0, 35)}...' : content;

            final notifRef = _notificationsRef.doc();
            transaction.set(notifRef, {
              'id': notifRef.id,
              'title': 'Pelukan Hangat 🫂',
              'message':
                  '$senderPseudonym memberikan pelukan hangat pada postingan Anda: "$snippet"',
              'dateStr': 'Baru saja',
              'senderPseudonym': senderPseudonym,
              'senderAvatar': senderAvatar,
              'recipientEmail': authorEmail,
              'targetPostId': postId,
              'type': 'hug',
              'isRead': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }

        // Perbarui jumlah like dan daftar email di dokumen Firestore
        transaction.update(docRef, {
          'likedByEmails': likedBy,
          'likesCount': likesCount,
        });
      });
    } catch (_) {}
  }

  /// ==========================================================================
  /// 6. MENAMBAH KOMENTAR DUKUNGAN (`Future<void> addComment`)
  /// --------------------------------------------------------------------------
  /// Penjelasan: Menyisipkan objek komentar baru ke array `comments` postingan di Firestore.
  /// ==========================================================================
  Future<void> addComment(
    String postId,
    CommunityComment comment, {
    required String postAuthorEmail,
  }) async {
    final docRef = _postsRef.doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final commentsRaw = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        int commentsCount = data['commentsCount'] as int? ?? commentsRaw.length;

        commentsRaw.insert(0, comment.toJson());
        commentsCount += 1;

        transaction.update(docRef, {
          'comments': commentsRaw,
          'commentsCount': commentsCount,
        });

        // Buat notifikasi baru untuk pemilik postingan jika pengomentar bukan dirinya sendiri
        final targetEmail = postAuthorEmail.toLowerCase().trim();
        final commenterEmail = comment.authorEmail.toLowerCase().trim();
        if (targetEmail.isNotEmpty && targetEmail != commenterEmail) {
          final snippet = comment.content.length > 35
              ? '${comment.content.substring(0, 35)}...'
              : comment.content;

          final notifRef = _notificationsRef.doc();
          transaction.set(notifRef, {
            'id': notifRef.id,
            'title': 'Dukungan Baru 💬',
            'message': '${comment.authorPseudonym} memberikan dukungan: "$snippet"',
            'dateStr': 'Baru saja',
            'senderPseudonym': comment.authorPseudonym,
            'senderAvatar': comment.authorAvatar,
            'recipientEmail': targetEmail,
            'targetPostId': postId,
            'type': 'comment',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (_) {}
  }

  /// ==========================================================================
  /// 7. MENGHAPUS KOMENTAR (`Future<void> deleteComment`)
  /// ==========================================================================
  Future<void> deleteComment(String postId, String commentId) async {
    final docRef = _postsRef.doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final commentsRaw = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        commentsRaw.removeWhere((c) => c['id'] == commentId);
        int commentsCount = commentsRaw.length;

        transaction.update(docRef, {
          'comments': commentsRaw,
          'commentsCount': commentsCount,
        });
      });
    } catch (_) {}
  }

  /// Helper internal untuk memformat tampilan timestamp (contoh: 'Baru saja', '5m lalu')
  static String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
      if (diff.inDays < 1) return '${diff.inHours}j lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return 'Baru saja';
  }
}
