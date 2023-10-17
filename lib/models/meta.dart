class Meta {
  int id;
  String userId;
  String nome;
  double valorMeta;
  double saldo;

  Meta({
    required this.id,
    required this.userId,
    required this.nome,
    required this.valorMeta,
    required this.saldo,
  });

  factory Meta.fromMap(Map<String, dynamic> map) {
    return Meta(
      id: map['id'],
      userId: map['user_id'],
      nome: map['nome'],
      valorMeta: map['valor_meta'],
      saldo: map['saldo'],
    );
  }
}
