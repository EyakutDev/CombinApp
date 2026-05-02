import 'package:flutter/material.dart';
import '../sabitler/renkler.dart';

/// Yükleniyor göstergesi — ana vurgu renginde spinner.
class Yukleniyor extends StatelessWidget {
  /// Spinner boyutu
  final double boyut;

  /// Spinner rengi (varsayılan: ana vurgu)
  final Color? renk;

  const Yukleniyor({
    super.key,
    this.boyut = 36.0,
    this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: boyut,
        height: boyut,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: renk ?? AppRenkler.anaVurgu,
        ),
      ),
    );
  }
}
