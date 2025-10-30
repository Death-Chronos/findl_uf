
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class MyAuthUser {
  final String id;
  final String email;
  final bool emailConfirmado;

  const MyAuthUser({
    required this.id,
    required this.email,
    required this.emailConfirmado,
  });

  factory MyAuthUser.fromJson(Map<String, dynamic> json) {
    return MyAuthUser(
      id: json['id'],
      email: json['email'],
      emailConfirmado: json['confirmed_at'] != null,

    );
  }

  factory MyAuthUser.fromSupabase(User user) {
      return MyAuthUser(
        id: user.id,
        email: user.email!, 
        emailConfirmado: user.emailConfirmedAt != null,
        );
    }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  MyAuthUser copyWith({
    String? id,
    String? email,
    bool? emailConfirmado,
  }) {
    return MyAuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      emailConfirmado: emailConfirmado ?? this.emailConfirmado,
    );
  }

  @override
  String toString() {
    return 'UsuarioAuth(id: $id, email: $email, emailConfirmado: $emailConfirmado)';
  }

}