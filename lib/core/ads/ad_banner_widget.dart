// lib/core/ads/ad_banner_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class NexorBannerAd extends StatefulWidget {
  const NexorBannerAd({super.key});

  @override
  State<NexorBannerAd> createState() => _NexorBannerAdState();
}

class _NexorBannerAdState extends State<NexorBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Substitua pelos seus IDs reais do AdMob (estes são de teste do Google)
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner, // Ou AdSize.fluid para nativo
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          print('Erro ao carregar anúncio: ${err.message}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se não carregou, não mostre um espaço em branco feio. Retorne SizedBox.
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: AppTheme.surface, // Fundo para integrar
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}