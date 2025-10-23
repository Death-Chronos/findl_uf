// Exceções de login
class InvalidCredentialsAuthException implements Exception {
  const InvalidCredentialsAuthException();
  @override
  String toString() => 'Email ou senha inválidos.';
}

class EmailNotConfirmedAuthException implements Exception {
  const EmailNotConfirmedAuthException();
  @override
  String toString() => 'Email não confirmado. Verifique sua caixa de entrada.';
}

class TooManyRequestsAuthException implements Exception {
  const TooManyRequestsAuthException();
  @override
  String toString() => 'Muitas tentativas. Tente novamente mais tarde.';
}

// Exceções de registro
class WeakPasswordAuthException implements Exception {
  const WeakPasswordAuthException();
  @override
  String toString() => 'Senha fraca. Deve conter ao menos 6 caracteres.';
}

class EmailAlreadyInUseAuthException implements Exception {
  const EmailAlreadyInUseAuthException();
  @override
  String toString() => 'Email já está em uso.';
}

class InvalidEmailAuthException implements Exception {
  const InvalidEmailAuthException();
  @override
  String toString() => 'Email inválido.';
}

// Exceções de recuperação de senha
class UserNotFoundAuthException implements Exception {
  const UserNotFoundAuthException();
  @override
  String toString() => 'Usuário não encontrado.';
}

class SamePasswordAuthException implements Exception {
  const SamePasswordAuthException();
  @override
  String toString() => 'A nova senha não pode ser igual à anterior.';
}

// Exceções genéricas
class GenericAuthException implements Exception {
  const GenericAuthException();
  @override
  String toString() => 'Ocorreu um erro inesperado.';
}

class UserNotLoggedInAuthException implements Exception {
  const UserNotLoggedInAuthException();
  @override
  String toString() => 'Você não está logado.';
}

class SessionExpiredAuthException implements Exception {
  const SessionExpiredAuthException();
  @override
  String toString() => 'Sessão expirada. Faça login novamente.';
}

class NetworkAuthException implements Exception {
  const NetworkAuthException();
  @override
  String toString() => 'Erro de conexão. Verifique sua internet.';
}