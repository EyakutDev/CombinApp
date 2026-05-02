import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:combin_app/cekirdek/sabitler/api_sabitleri.dart';
import 'package:combin_app/cekirdek/sabitler/renkler.dart';

/// Görsel seçme, kırpma, sıkıştırma ve thumbnail oluşturma yardımcısı.
/// Tüm görsel işleme cihaz tarafında yapılır — sunucu maliyeti yok.
class GorselYardimcilari {
  static final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  /// Fotoğraf seç veya çek
  /// [kaynak] ImageSource.camera veya ImageSource.gallery
  /// Döndürür: seçilen dosya yolu veya null (iptal edildi)
  static Future<String?> fotografSec({
    required ImageSource kaynak,
  }) async {
    final secilen = await _picker.pickImage(
      source: kaynak,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (secilen == null) return null;
    return secilen.path;
  }

  /// Fotoğrafı 1:1 oranında kırp
  static Future<String?> fotografKirp(String dosyaYolu) async {
    final kirpilan = await ImageCropper().cropImage(
      sourcePath: dosyaYolu,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Kıyafeti Kırp',
          toolbarColor: AppRenkler.anaVurgu,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppRenkler.anaVurgu,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Kıyafeti Kırp',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return kirpilan?.path;
  }

  /// Görseli sıkıştır + boyutlandır → WebP olarak kaydet
  /// Hedef: max 800x800, ~200KB, WebP format
  static Future<String?> gorselSikistir(String dosyaYolu) async {
    final geciciDizin = await getTemporaryDirectory();
    final hedefYol = '${geciciDizin.path}/${_uuid.v4()}.webp';

    final sonuc = await FlutterImageCompress.compressAndGetFile(
      dosyaYolu,
      hedefYol,
      minWidth: ApiSabitleri.gorselMaxGenislik,
      minHeight: ApiSabitleri.gorselMaxYukseklik,
      quality: ApiSabitleri.gorselKalitesi,
      format: CompressFormat.webp,
    );

    return sonuc?.path;
  }

  /// Thumbnail oluştur (200x200, düşük kalite)
  static Future<String?> thumbnailOlustur(String dosyaYolu) async {
    final geciciDizin = await getTemporaryDirectory();
    final hedefYol = '${geciciDizin.path}/thumb_${_uuid.v4()}.webp';

    final sonuc = await FlutterImageCompress.compressAndGetFile(
      dosyaYolu,
      hedefYol,
      minWidth: ApiSabitleri.thumbnailBoyutu,
      minHeight: ApiSabitleri.thumbnailBoyutu,
      quality: 60,
      format: CompressFormat.webp,
    );

    return sonuc?.path;
  }

  /// Tam pipeline: Seç → Kırp → Sıkıştır → Thumbnail
  /// Döndürür: {orijinal: path, thumbnail: path} veya null
  static Future<Map<String, String>?> tamPipeline({
    required ImageSource kaynak,
  }) async {
    // 1. Fotoğraf seç
    final secilen = await fotografSec(kaynak: kaynak);
    if (secilen == null) return null;

    // 2. Kırp (1:1)
    final kirpilan = await fotografKirp(secilen);
    if (kirpilan == null) return null;

    // 3. Sıkıştır (orijinal boyut)
    final sikistirilmis = await gorselSikistir(kirpilan);
    if (sikistirilmis == null) return null;

    // 4. Thumbnail oluştur
    final thumbnail = await thumbnailOlustur(kirpilan);
    if (thumbnail == null) return null;

    return {
      'orijinal': sikistirilmis,
      'thumbnail': thumbnail,
    };
  }

  /// Benzersiz dosya adı oluştur
  static String benzersizDosyaAdi() {
    return '${_uuid.v4()}.webp';
  }

  /// Geçici dosyaları temizle
  static Future<void> geciciDosyalariTemizle() async {
    try {
      final geciciDizin = await getTemporaryDirectory();
      final dosyalar = geciciDizin.listSync();
      for (final dosya in dosyalar) {
        if (dosya is File && dosya.path.endsWith('.webp')) {
          await dosya.delete();
        }
      }
    } catch (_) {
      // Sessizce geç — kritik değil
    }
  }
}
