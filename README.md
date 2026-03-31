# find_uf

Sistema de Achados e Perdidos Universitário
Projeto Flutter/Dart para gerenciamento de itens perdidos e encontrados na universidade, utilizando Supabase como backend (SaaS).

## Funcionalidades
- Cadastro e autenticação de usuários (e-mail institucional)
- Recuperação e verificação de e-mail
- Cadastro de itens perdidos e encontrados (com fotos)
- Busca e filtro de itens por título, descrição, status e categoria
- Visualização de detalhes do item
- Edição e remoção de itens próprios
- Upload e gerenciamento de imagens
- Perfil do usuário e alteração de senha
- Deep links para navegação

## Dependências principais
- [Flutter](https://flutter.dev/) >= 3.7.0
- [supabase_flutter](https://pub.dev/packages/supabase_flutter)
- [image_picker](https://pub.dev/packages/image_picker)
- [app_links](https://pub.dev/packages/app_links)
- [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter)
- [path](https://pub.dev/packages/path)
- [url_launcher](https://pub.dev/packages/url_launcher)
- [cached_network_image](https://pub.dev/packages/cached_network_image)
- [photo_view](https://pub.dev/packages/photo_view)

## Como rodar o projeto
1. Instale o [Flutter](https://docs.flutter.dev/get-started/install) na sua máquina.
2. Clone este repositório.
3. Instale as dependências:
	```sh
	flutter pub get
	```
4. Configure as variáveis do Supabase em `lib/supabase.dart` (já preenchido para ambiente padrão):
	- `SUPABASE_URL`
	- `SUPABASE_ANON_KEY`
5. Execute o app:
	```sh
	flutter run
	```

## Observações
- O projeto utiliza autenticação por e-mail institucional (@ufersa.edu.br).
- Para rodar em dispositivos físicos, configure as permissões de câmera e galeria conforme a [documentação do image_picker](https://pub.dev/packages/image_picker#installation).
- Para builds web/mobile, consulte a documentação oficial do Flutter.
