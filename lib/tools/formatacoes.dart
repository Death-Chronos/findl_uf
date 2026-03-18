String formatarTelefone(String num) {
  if (num.length == 11) {
    // Formato: (11) 99999-9999
    return num.replaceFirstMapped(
        RegExp(r'(\d{2})(\d{5})(\d{4})'), (m) => "(${m[1]}) ${m[2]}-${m[3]}");
  } else if (num.length == 10) {
    // Formato: (11) 9999-9999
    return num.replaceFirstMapped(
        RegExp(r'(\d{2})(\d{4})(\d{4})'), (m) => "(${m[1]}) ${m[2]}-${m[3]}");
  }
  return num; // Retorna original se não corresponder aos tamanhos
}