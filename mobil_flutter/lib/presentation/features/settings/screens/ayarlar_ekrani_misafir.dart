import 'package:flutter/material.dart';
import 'package:mobil_flutter/presentation/features/auth/screens/giris_ekrani.dart';

class AyarlarEkraniMisafir extends StatelessWidget {
  const AyarlarEkraniMisafir({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Uygulama Teması'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Dil'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login, color: Colors.green),
            title: const Text(
              'Giriş Yap veya Kaydol',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GirisEkrani()),
              );
            },
          ),
        ],
      ),
    );
  }
}
