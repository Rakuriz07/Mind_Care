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

class PsychologistAppointment {
  final String id;
  final String patientName;
  final String patientAge;
  final String patientAvatar;
  final String date;
  final String time;
  final String issueSummary;
  final int screeningScore;
  final String screeningCategory;
  final String consultationType; // 'Online Video Call' or 'Tatap Muka di Klinik'
  String status; // 'Upcoming', 'Ongoing', 'Completed'

  PsychologistAppointment({
    required this.id,
    required this.patientName,
    required this.patientAge,
    required this.patientAvatar,
    required this.date,
    required this.time,
    required this.issueSummary,
    required this.screeningScore,
    required this.screeningCategory,
    required this.consultationType,
    this.status = 'Upcoming',
  });
}
