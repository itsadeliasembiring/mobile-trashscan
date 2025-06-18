class EcoItem {
  final String id;
  final String title;
  final int points;
  final String imageAsset;
  int stock;
  final String? description;

  EcoItem({
    required this.id,
    required this.title,
    required this.points,
    required this.imageAsset,
    required this.stock,
    this.description,
  });

  factory EcoItem.fromJson(Map<String, dynamic> json) {
    return EcoItem(
      id: json['id_barang'],
      title: json['nama_barang'],
      points: json['bobot_poin'],
      imageAsset: json['foto'] ?? 'assets/fallback.png', // Fallback image
      stock: json['stok'],
      description: json['deskripsi_barang'],
    );
  }
}