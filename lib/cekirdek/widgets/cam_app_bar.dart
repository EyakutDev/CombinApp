import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS 26 tarzı buzlu cam (Light Glass) AppBar bileşeni.
/// Aşağı kaydırıldığında arka plandaki içeriği flulaştırarak gösterir.
class CamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final SystemUiOverlayStyle? systemOverlayStyle;
  
  /// Camın arka plan rengi ve şeffaflığı. Belirtilmezse varsayılan kullanılır.
  final Color? arkaPlanRengi;
  
  /// Bulanıklık derecesi. Varsayılan: 30.0
  final double bulaniklik;

  const CamAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.systemOverlayStyle,
    this.arkaPlanRengi,
    this.bulaniklik = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: bulaniklik, sigmaY: bulaniklik),
              child: Container(
                decoration: BoxDecoration(
                  color: arkaPlanRengi ?? Colors.white.withValues(alpha: 0.15), // Çok daha şeffaf varsayılan
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: title,
                      actions: actions,
                      leading: leading,
                      automaticallyImplyLeading: automaticallyImplyLeading,
                      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.dark,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                    ),
                    if (bottom != null) bottom!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 24 + (bottom?.preferredSize.height ?? 0.0));
}
