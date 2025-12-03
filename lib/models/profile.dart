class Profile {

  final String userId;
  final String nome;
  final String telefone;
  final String fotoUrl;

  const Profile({
    required this.userId,
    required this.nome,
    required this.telefone,
    required this.fotoUrl
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
      fotoUrl: json['foto_url'],
    );
  }

}