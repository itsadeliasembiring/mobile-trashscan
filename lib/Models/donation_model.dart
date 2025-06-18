class Donation {
  final String id;
  final String title;
  final String? description;
  final String imageAsset;
  int totalDonation;

  Donation({
    required this.id,
    required this.title,
    this.description,
    required this.imageAsset,
    required this.totalDonation,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id_donasi'],
      title: json['nama_donasi'],
      description: json['deskripsi_donasi'],
      imageAsset: json['foto'] ?? 'assets/donation-default.png',
      totalDonation: json['total_donasi'] ?? 0,
    );
  }
}