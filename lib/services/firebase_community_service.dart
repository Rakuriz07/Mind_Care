import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare/models/app_models.dart';

class FirebaseCommunityService {
  static final FirebaseCommunityService _instance =
      FirebaseCommunityService._internal();
  static FirebaseCommunityService get instance => _instance;

  FirebaseCommunityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('community_posts');

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  /// Stream postingan komunitas secara Real-Time dari Cloud Firestore
  Stream<List<CommunityPost>> streamCommunityPosts({String? currentUserEmail}) {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
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
    });
  }

  /// Tambah postingan baru ke Firestore
  Future<void> createPost(CommunityPost post) async {
    final docRef = post.id.isNotEmpty ? _postsRef.doc(post.id) : _postsRef.doc();
    await docRef.set({
      'id': docRef.id,
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
  }

  /// Hapus postingan dari Firestore
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.doc(postId).delete();
    } catch (_) {}
  }

  /// Toggle Like/Pelukan Hangat pada postingan
  Future<void> toggleLike(
    String postId,
    String userEmail, {
    String senderPseudonym = 'Teman MindCare',
    String senderAvatar = '',
  }) async {
    final docRef = _postsRef.doc(postId);
    final cleanEmail = userEmail.toLowerCase().trim();

    try {
      await _firestore.runTransaction((transaction) async {
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

          // Create notification for post author
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

        transaction.update(docRef, {
          'likedByEmails': likedBy,
          'likesCount': likesCount,
        });
      });
    } catch (_) {}
  }

  /// Tambah komentar pada postingan di Firestore
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

        // Notification
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

  /// Hapus komentar dari postingan di Firestore
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
