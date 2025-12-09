class Validacoes {
  static String? validarEmail (String email) {
    if (email.isEmpty) return 'Email é obrigatório';

    email = email.trim();

    if (!email.contains('@')) return 'Email inválido';

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email)) return 'Formato de email inválido';

    return null; // null = válido
  }

  static String normalizar(String email) {
    return email.trim().toLowerCase();
  }

  static String? validarDominioUfersa(String email) {
    // Regex que verifica se o email termina com @[qualquercoisa.]ufersa.edu.br
    final regex = RegExp(
      r'^[^@]+@([a-zA-Z0-9-]+\.)?ufersa\.edu\.br$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(email.trim())) {
      return "Por favor, use um email acadêmico da UFERSA (@ufersa.edu.br)";
    }

    return null;
  }
}
