import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class JournalEntry {
  final String id;
  final String userEmail;
  final String title;
  final String date;
  final String preview;
  final String mood;
  final Color moodColor;
  final Color moodBg;
  final List<String> tags;

  JournalEntry({
    required this.id,
    this.userEmail = '',
    required this.title,
    required this.date,
    required this.preview,
    required this.mood,
    required this.moodColor,
    required this.moodBg,
    required this.tags,
  });
}

class ScreeningRecord {
  final String id;
  final String userEmail;
  final String userName;
  final String title;
  final String date;
  final int score;
  final Color color;
  final Color bg;
  final String image;

  ScreeningRecord({
    required this.id,
    this.userEmail = '',
    this.userName = '',
    required this.title,
    required this.date,
    required this.score,
    required this.color,
    required this.bg,
    required this.image,
  });
}

class UserProfile {
  String name;
  String email;
  String phone;
  String avatarUrl;
  Uint8List? avatarBytes;
  File? avatarFile;
  final String memberSince;
  String role; // 'patient' or 'psychologist'
  String specialization;
  String licenseNumber;
  String experienceYears;
  String consultationFee;
  bool isOnlineAccepting;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.avatarBytes,
    this.avatarFile,
    this.memberSince = 'Anggota sejak Agustus 2024',
    this.role = 'patient',
    this.specialization = 'Psikologi Klinis & Terapi Stres',
    this.licenseNumber = 'SIPP. 1984/HIMPSI/2023',
    this.experienceYears = '6 Tahun',
    this.consultationFee = 'Rp 150.000',
    this.isOnlineAccepting = true,
  });
}



class CommunityComment {
  final String id;
  final String authorEmail;
  final String authorPseudonym;
  final String authorAvatar;
  final String content;
  final String date;

  CommunityComment({
    required this.id,
    this.authorEmail = '',
    required this.authorPseudonym,
    required this.authorAvatar,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_email': authorEmail,
        'author_pseudonym': authorPseudonym,
        'author_avatar': authorAvatar,
        'content': content,
        'date': date,
      };

  factory CommunityComment.fromJson(Map<String, dynamic> json) => CommunityComment(
        id: json['id'] as String? ?? '',
        authorEmail: json['author_email'] as String? ?? '',
        authorPseudonym: json['author_pseudonym'] as String? ?? 'Anonim',
        authorAvatar: json['author_avatar'] as String? ?? '',
        content: json['content'] as String? ?? '',
        date: json['date'] as String? ?? '',
      );
}

class CommunityPost {
  final String id;
  final String authorEmail;
  final String authorPseudonym;
  final String authorAvatar;
  final String authorMood;
  final String content;
  final String categoryTag;
  int likesCount;
  int commentsCount;
  final String date;
  bool isLiked;
  final List<CommunityComment> comments;

  CommunityPost({
    required this.id,
    this.authorEmail = '',
    required this.authorPseudonym,
    required this.authorAvatar,
    this.authorMood = 'Butuh Teman 🫂',
    required this.content,
    required this.categoryTag,
    required this.likesCount,
    required this.commentsCount,
    required this.date,
    this.isLiked = false,
    List<CommunityComment>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_email': authorEmail,
        'author_pseudonym': authorPseudonym,
        'author_avatar': authorAvatar,
        'author_mood': authorMood,
        'content': content,
        'category_tag': categoryTag,
        'likes_count': likesCount,
        'comments_count': commentsCount,
        'date': date,
        'is_liked': isLiked,
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
        id: json['id'] as String? ?? '',
        authorEmail: json['author_email'] as String? ?? '',
        authorPseudonym: json['author_pseudonym'] as String? ?? 'Anonim',
        authorAvatar: json['author_avatar'] as String? ?? '',
        authorMood: json['author_mood'] as String? ?? 'Butuh Teman 🫂',
        content: json['content'] as String? ?? '',
        categoryTag: json['category_tag'] as String? ?? '#Semua',
        likesCount: json['likes_count'] as int? ?? 0,
        commentsCount: json['comments_count'] as int? ?? (json['comments'] as List? ?? []).length,
        date: json['date'] as String? ?? '',
        isLiked: json['is_liked'] as bool? ?? false,
        comments: (json['comments'] as List? ?? [])
            .map((c) => CommunityComment.fromJson(Map<String, dynamic>.from(c)))
            .toList(),
      );
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String date;
  final String senderPseudonym;
  final String senderAvatar;
  final String recipientEmail;
  final String targetPostId;
  final String type; // 'hug' (like) or 'comment' (support)
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.senderPseudonym,
    required this.senderAvatar,
    required this.recipientEmail,
    required this.targetPostId,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'date': date,
        'sender_pseudonym': senderPseudonym,
        'sender_avatar': senderAvatar,
        'recipient_email': recipientEmail,
        'target_post_id': targetPostId,
        'type': type,
        'is_read': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        date: json['date'] as String? ?? '',
        senderPseudonym: json['sender_pseudonym'] as String? ?? 'Teman MindCare',
        senderAvatar: json['sender_avatar'] as String? ?? '',
        recipientEmail: json['recipient_email'] as String? ?? '',
        targetPostId: json['target_post_id'] as String? ?? '',
        type: json['type'] as String? ?? 'hug',
        isRead: json['is_read'] as bool? ?? false,
      );
}


