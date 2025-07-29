// lib/presentation/features/venue/widgets/yorumlar_sayfasi.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/widgets/yorum_karti.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart'; // Auth provider'ı import et
import 'package:mobil_flutter/presentation/features/auth/screens/giris_ekrani.dart'; // Giriş ekranını import et

//--- SAYFA 2: YORUMLAR (GÜNCELLENMİŞ) ---
class YorumlarSayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const YorumlarSayfasi({super.key, required this.mekan});

  @override
  ConsumerState<YorumlarSayfasi> createState() => _YorumlarSayfasiState();
}

class _YorumlarSayfasiState extends ConsumerState<YorumlarSayfasi> {
  bool _isEditing = false;

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  final authState = ref.watch(authProvider);
  final bool girisYapildi = authState == AuthStatus.girisYapildi;
  final userId = girisYapildi ? ref.watch(userProfileProvider).value?.id : null;

  // --- DÜZELTME BURADA ---
  final YorumModel? kullaniciYorumu;
  if (girisYapildi && userId != null) {
    // 'where' kullanarak güvenli bir şekilde arama yapıyoruz.
    final eslesenYorumlar = widget.mekan.yorumlar.where((yorum) => yorum.yazar.id == userId);
    kullaniciYorumu = eslesenYorumlar.isNotEmpty ? eslesenYorumlar.first : null;
  } else {
    kullaniciYorumu = null;
  }
  // --- DÜZELTME BİTTİ ---

  final bool kullaniciMetinliYorumYaptiMi =
      kullaniciYorumu != null && (kullaniciYorumu.icerik?.trim().isNotEmpty ?? false);
  final digerYorumlar = widget.mekan.yorumlar
      .where((yorum) => yorum.yazar.id != userId)
      .toList();

    // DÜZELTME: Scaffold ve AppBar kaldırıldı, artık direkt içeriği döndürüyoruz.
    return Column(
      children: [
        Expanded(
          child: digerYorumlar.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      l10n.noCommentsYet, // Çeviri anahtarı kullanıldı
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  itemCount: digerYorumlar.length,
                  itemBuilder: (context, index) {
                    final yorum = digerYorumlar[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: YorumKarti(yorum: yorum),
                    );
                  },
                ),
        ),
        
        // --- KULLANICI YORUM/GİRİŞ ALANI (AKILLI MANTIK) ---
        if (girisYapildi)
          // Eğer kullanıcı giriş yapmışsa...
          if (kullaniciMetinliYorumYaptiMi && !_isEditing)
            // ve yazılı bir yorumu varsa ve düzenleme modunda değilse, yorumunu göster
            _KullaniciYorumuGoster(
              yorum: kullaniciYorumu!,
              onEditPressed: () => setState(() => _isEditing = true),
            )
          else
            // Yazılı yorumu yoksa veya düzenleme modundaysa, yazma alanını göster
            _YorumYazmaAlani(
              mekanId: widget.mekan.id,
              duzenlenecekYorum: kullaniciYorumu,
              onCommentSubmitted: () => setState(() => _isEditing = false),
            )
        else
          // Eğer kullanıcı misafir ise, giriş yapma butonu göster
          _GirisYapmaButonu(),
      ],
    );
  }
}

// YENİ: Misafirler için giriş yapma butonu
class _GirisYapmaButonu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: const Text("Yorum yapmak için giriş yapın"),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GirisEkrani()));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}


//--- KULLANICININ KENDİ YORUMUNU GÖSTEREN WIDGET ---
class _KullaniciYorumuGoster extends StatelessWidget {
  final YorumModel yorum;
  final VoidCallback onEditPressed;
  const _KullaniciYorumuGoster({
    required this.yorum,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.yourComment,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: Text(l10n.edit),
                onPressed: onEditPressed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          YorumKarti(
            yorum: yorum
          ),
        ],
      ),
    );
  }
}

//--- YORUM YAZMA ALANI WIDGET'I ---
class _YorumYazmaAlani extends ConsumerStatefulWidget {
  final String mekanId;
  final YorumModel? duzenlenecekYorum;
  final VoidCallback? onCommentSubmitted;

  const _YorumYazmaAlani({
    required this.mekanId,
    this.duzenlenecekYorum,
    this.onCommentSubmitted,
  });

  @override
  ConsumerState<_YorumYazmaAlani> createState() => __YorumYazmaAlaniState();
}

class __YorumYazmaAlaniState extends ConsumerState<_YorumYazmaAlani> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.duzenlenecekYorum?.icerik ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _yorumGonder() {
    final icerik = _controller.text.trim();
    if (icerik.isEmpty && widget.duzenlenecekYorum?.puan == null) return;

    ref
        .read(yorumSubmitProvider.notifier)
        .gonder(mekanId: widget.mekanId, icerik: icerik);

    _controller.clear();
    FocusScope.of(context).unfocus();
    widget.onCommentSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(userProfileProvider);
    final yorumState = ref.watch(yorumSubmitProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          userAsync.when(
            data: (user) => CircleAvatar(
              backgroundImage:
                  (user.profilFotoUrl != null && user.profilFotoUrl!.isNotEmpty)
                  ? NetworkImage(user.profilFotoUrl!)
                  : null,
              child: (user.profilFotoUrl == null || user.profilFotoUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            loading: () =>
                const CircleAvatar(child: CircularProgressIndicator()),
            error: (e, s) => const CircleAvatar(child: Icon(Icons.person)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.addComment,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (yorumState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: _yorumGonder,
            ),
        ],
      ),
    );
  }
}
