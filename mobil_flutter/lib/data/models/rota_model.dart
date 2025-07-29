class Rota {
  final String id;
  final String adKey; // ad -> adKey
  final String aciklamaKey; // aciklama -> aciklamaKey
  final String kapakFotografiUrl;
  final String tahminiSureKey; // tahminiSure -> tahminiSureKey
  final String zorlukSeviyesiKey; // zorlukSeviyesi -> zorlukSeviyesiKey
  final List<String> mekanIdleri;

  Rota({
    required this.id,
    required this.adKey,
    required this.aciklamaKey,
    required this.kapakFotografiUrl,
    required this.tahminiSureKey,
    required this.zorlukSeviyesiKey,
    required this.mekanIdleri,
  });
}
