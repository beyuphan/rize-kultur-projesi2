import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/data/models/mekan_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/widgets/yorum_karti.dart';
import 'package:mobil_flutter/data/models/yorum_model.dart';
import 'package:mobil_flutter/presentation/providers/mekan_providers.dart';

//--- SAYFA 2: YORUMLAR (AKILLI MANTIK) ---
class YorumlarSayfasi extends ConsumerStatefulWidget {
  final MekanModel mekan;
  const YorumlarSayfasi({required this.mekan});

  @override
  ConsumerState<YorumlarSayfasi> createState() => _YorumlarSayfasiState();
}

class _YorumlarSayfasiState extends ConsumerState<YorumlarSayfasi> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;
    final userId = userAsync.value?.id;

    final eslesenYorumlar = widget.mekan.yorumlar.where(
      (yorum) => yorum.yazar.id == userId,
    );
    final YorumModel? kullaniciYorumu = eslesenYorumlar.isNotEmpty
        ? eslesenYorumlar.first
        : null;
    final bool kullaniciMetinliYorumYaptiMi =
        kullaniciYorumu != null &&
        (kullaniciYorumu.icerik?.trim().isNotEmpty ?? false);
    final digerYorumlar = widget.mekan.yorumlar
        .where((yorum) => yorum.yazar.id != userId)
        .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${langCode == 'tr' ? widget.mekan.isim.tr : widget.mekan.isim.en} - ${l10n.reviews}',
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true, // Geri butonunu aktif eder
      ),
      body: Column(
        children: [
          Expanded(
            child: digerYorumlar.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "yorum yok şuan",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: digerYorumlar.length,
                    itemBuilder: (context, index) {
                      final yorum = digerYorumlar[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: YorumKarti(
                          kullaniciAdi: yorum.yazar.kullaniciAdi,
                          puan: yorum.puan,
                          yorum: yorum.icerik,
                          kullaniciImageUrl: yorum.yazar.profilFotoUrl,
                          yorumTarihi: yorum.yorumTarihi,
                        ),
                      );
                    },
                  ),
          ),
          if (userId != null)
            if (kullaniciMetinliYorumYaptiMi && !_isEditing)
              _KullaniciYorumuGoster(
                yorum: kullaniciYorumu!,
                onEditPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              )
            else
              _YorumYazmaAlani(
                mekanId: widget.mekan.id,
                duzenlenecekYorum: kullaniciYorumu,
                onCommentSubmitted: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
              ),
        ],
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
            kullaniciAdi: yorum.yazar.kullaniciAdi,
            puan: yorum.puan,
            yorum: yorum.icerik,
            kullaniciImageUrl: yorum.yazar.profilFotoUrl,
            yorumTarihi: yorum.yorumTarihi,
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
