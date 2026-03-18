class UploadItemImageException implements Exception {
  const UploadItemImageException();
  @override
  String toString() => 'Erro ao fazer upload da imagem.';
}

class CreateLostAndFoundItemException implements Exception {
  const CreateLostAndFoundItemException();
  @override
  String toString() => 'Erro ao criar o item de perdidos e achados.';
}

class UpdateLostAndFoundItemException implements Exception {
  const UpdateLostAndFoundItemException();
  @override
  String toString() => 'Erro ao atualizar o item de perdidos e achados.';
}

class DeleteLostAndFoundItemException implements Exception {
  const DeleteLostAndFoundItemException();
  @override
  String toString() => 'Erro ao deletar o item de perdidos e achados.';
}

class GetLostAndFoundItemException implements Exception {
  const GetLostAndFoundItemException();
  @override
  String toString() => 'Erro ao obter o item de perdidos e achados.';
}
