class UsuarioModel {
  const UsuarioModel({
    required this.idUsuario,
    required this.idEmpresa,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.perfil,
    required this.status,
  });

  final int idUsuario;
  final int idEmpresa;
  final String nome;
  final String email;
  final String telefone;
  final String perfil;
  final String status;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['id_usuario'] as int? ?? 0,
      idEmpresa: json['id_empresa'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefone: json['telefone'] as String? ?? '',
      perfil: json['perfil'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'id_empresa': idEmpresa,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'perfil': perfil,
        'status': status,
      };

  @override
  String toString() =>
      'UsuarioModel(id: $idUsuario, nome: $nome, email: $email, perfil: $perfil)';
}