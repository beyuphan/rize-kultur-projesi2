// lib/presentation/screens/profil_duzenle_ekrani.dart (TAMAMEN DEĞİŞTİR)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobil_flutter/data/models/user_model.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';
import 'package:mobil_flutter/presentation/screens/profil_ekrani.dart';
import 'package:mobil_flutter/presentation/providers/user_providers.dart';
import 'package:mobil_flutter/presentation/providers/auth_providers.dart';


// State Notifier'ları ve Provider'ları güncelleyelim
final profileUpdateProvider = StateNotifierProvider.autoDispose<ProfileUpdateNotifier, AsyncValue<void>>((ref) {
  return ProfileUpdateNotifier(ref);
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileUpdateNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> updateProfile({
    String? kullaniciAdi,
    XFile? profilFoto,
    String? eskiSifre,
    String? yeniSifre,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      // Şifre alanları doluysa önce şifreyi değiştir
      if (eskiSifre != null && yeniSifre != null && eskiSifre.isNotEmpty && yeniSifre.isNotEmpty) {
        await authService.changePassword(eskiSifre: eskiSifre, yeniSifre: yeniSifre);
      }
      // Sonra profil bilgilerini güncelle
      await authService.updateProfile(kullaniciAdi: kullaniciAdi, profilFoto: profilFoto);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class ProfilDuzenleEkrani extends ConsumerStatefulWidget {
  final UserModel mevcutKullanici;
  const ProfilDuzenleEkrani({super.key, required this.mevcutKullanici});

  @override
  ConsumerState<ProfilDuzenleEkrani> createState() => _ProfilDuzenleEkraniState();
}

class _ProfilDuzenleEkraniState extends ConsumerState<ProfilDuzenleEkrani> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kullaniciAdiController;
  final _eskiSifreController = TextEditingController();
  final _yeniSifreController = TextEditingController();
  XFile? _secilenResim;

  @override
  void initState() {
    super.initState();
    _kullaniciAdiController = TextEditingController(text: widget.mevcutKullanici.kullaniciAdi);
  }

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _eskiSifreController.dispose();
    _yeniSifreController.dispose();
    super.dispose();
  }

  Future<void> _resimSec() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _secilenResim = image;
      });
    }
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      // Şifre validasyonu: İkisi de boş olmalı veya ikisi de dolu olmalı
      final eskiSifre = _eskiSifreController.text;
      final yeniSifre = _yeniSifreController.text;
      if (eskiSifre.isNotEmpty && yeniSifre.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen yeni şifrenizi girin.')));
        return;
      }

      await ref.read(profileUpdateProvider.notifier).updateProfile(
        kullaniciAdi: _kullaniciAdiController.text,
        profilFoto: _secilenResim,
        eskiSifre: eskiSifre,
        yeniSifre: yeniSifre,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(profileUpdateProvider, (_, state) {
      if (!mounted) return;
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ${state.error}')));
      }
      if (state is AsyncData && !state.isLoading) {
        ref.invalidate(userProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla güncellendi!')));
        Navigator.of(context).pop();
      }
    });

    final updateState = ref.watch(profileUpdateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fotoğraf Seçme Alanı
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _secilenResim != null
                        ? FileImage(File(_secilenResim!.path))
                        : (widget.mevcutKullanici.profilFotoUrl != null && widget.mevcutKullanici.profilFotoUrl!.isNotEmpty)
                            ? NetworkImage(widget.mevcutKullanici.profilFotoUrl!) as ImageProvider
                            : null,
                    child: (_secilenResim == null && (widget.mevcutKullanici.profilFotoUrl == null || widget.mevcutKullanici.profilFotoUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _resimSec,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kullanıcı Adı
              TextFormField(
                controller: _kullaniciAdiController,
                decoration: InputDecoration(labelText: l10n.username, border: const OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? l10n.usernameCannotBeEmpty : null,
              ),
              const SizedBox(height: 16),

              // Şifre Değiştirme
              Text(l10n.changePassword, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _eskiSifreController,
                decoration: InputDecoration(labelText: l10n.oldPassword, border: const OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yeniSifreController,
                decoration: InputDecoration(labelText: l10n.newPassword, border: const OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: updateState.isLoading ? null : _kaydet,
                child: updateState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}