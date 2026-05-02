import 'package:equatable/equatable.dart';
import 'package:combin_app/ozellikler/kombin/alan/modeller/kombin_modeli.dart';

/// Haftalık plan modeli — bir güne atanmış kombin.
class PlanModeli extends Equatable {
  final String? id;
  final String kullaniciId;
  final String kombinId;
  final DateTime tarih;
  final KombinModeli? kombin; // join ile doldurulur

  const PlanModeli({
    this.id,
    required this.kullaniciId,
    required this.kombinId,
    required this.tarih,
    this.kombin,
  });

  /// Supabase JSON'dan oluştur
  factory PlanModeli.fromJson(Map<String, dynamic> json) {
    return PlanModeli(
      id: json['id'] as String,
      kullaniciId: json['kullanici_id'] as String,
      kombinId: json['kombin_id'] as String,
      tarih: DateTime.parse(json['tarih'] as String),
    );
  }

  /// Supabase'e kaydetmek için JSON
  Map<String, dynamic> toJson() {
    return {
      'kullanici_id': kullaniciId,
      'kombin_id': kombinId,
      'tarih': '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}',
    };
  }

  PlanModeli kopyala({
    String? id,
    String? kullaniciId,
    String? kombinId,
    DateTime? tarih,
    KombinModeli? kombin,
  }) {
    return PlanModeli(
      id: id ?? this.id,
      kullaniciId: kullaniciId ?? this.kullaniciId,
      kombinId: kombinId ?? this.kombinId,
      tarih: tarih ?? this.tarih,
      kombin: kombin ?? this.kombin,
    );
  }

  @override
  List<Object?> get props => [id, kullaniciId, kombinId, tarih];
}

/// Hafta modeli — 7 günlük plan listesi
class HaftaModeli {
  final DateTime haftaninIlkGunu; // Pazartesi
  final Map<DateTime, PlanModeli?> gunler; // tarih → plan (null = boş gün)

  HaftaModeli({
    required this.haftaninIlkGunu,
    Map<DateTime, PlanModeli?>? gunler,
  }) : gunler = gunler ?? {};

  /// Haftanın 7 gününü döndür
  List<DateTime> get haftaGunleri {
    return List.generate(7, (i) => haftaninIlkGunu.add(Duration(days: i)));
  }

  /// Belirli bir gündeki plan
  PlanModeli? gunPlan(DateTime tarih) {
    final normalTarih = DateTime(tarih.year, tarih.month, tarih.day);
    return gunler[normalTarih];
  }

  /// Planlı gün sayısı
  int get planliGunSayisi => gunler.values.where((p) => p != null).length;
}
