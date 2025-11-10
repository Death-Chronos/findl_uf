class ValidarEmail {
  static String? validar(String email) {
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
}