import 'dart:io';
import 'package:find_uf/models/enums/item_category.dart';
import 'package:find_uf/models/enums/item_status.dart';
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/items/lost_and_found_item_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateUpdateLostAndFoundItemView extends StatefulWidget {
  final LostAndFoundItem? item;

  const CreateUpdateLostAndFoundItemView({super.key, this.item});
  
  @override
  _CreateUpdateLostAndFoundItemViewState createState() =>
      _CreateUpdateLostAndFoundItemViewState();
}

class _CreateUpdateLostAndFoundItemViewState
    extends State<CreateUpdateLostAndFoundItemView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localizacaoController = TextEditingController();

  ItemCategory? _selectedCategory;
  ItemStatus? _selectedStatus;
  DateTime? _lostOrFoundAt;
  
  // Listas para gerenciar fotos
  List<XFile> _selectedImages = []; // Novas fotos locais
  List<String> _existingPhotosUrls = []; // URLs das fotos já no servidor
  List<String> _photosToDelete = []; // URLs marcadas para deletar
  
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExistingItemIfExists();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _chooseImageSource() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tirar foto"),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final img = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (img != null) {
                      setState(() {
                        _selectedImages.add(img);
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao tirar foto: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Escolher da galeria"),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final List<XFile> images = await _picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      setState(() {
                        _selectedImages.addAll(images);
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao selecionar imagens: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      final url = _existingPhotosUrls[index];
      _photosToDelete.add(url);
      _existingPhotosUrls.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lostOrFoundAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _lostOrFoundAt = picked;
      });
    }
  }

  String _getCategoryLabel(ItemCategory category) {
    final labels = {
      ItemCategory.documents: 'Documentos',
      ItemCategory.keys: 'Chaves',
      ItemCategory.electronics: 'Eletrônicos',
      ItemCategory.bags: 'Bolsas/Mochilas',
      ItemCategory.wallet: 'Carteira',
      ItemCategory.clothing: 'Roupas',
      ItemCategory.books: 'Livros',
      ItemCategory.accessories: 'Acessórios',
      ItemCategory.bottles: 'Garrafas',
      ItemCategory.others: 'Outros',
    };
    return labels[category] ?? category.name;
  }

  String _getStatusLabel(ItemStatus status) {
    final labels = {ItemStatus.lost: 'Perdido', ItemStatus.found: 'Encontrado'};
    return labels[status] ?? status.name;
  }

  Future<void> _loadExistingItemIfExists() async {
    if (widget.item != null) {
      final item = widget.item!;
      setState(() {
        _tituloController.text = item.titulo;
        _descricaoController.text = item.descricao;
        _localizacaoController.text = item.localizacao;
        _selectedCategory = item.categoria;
        _selectedStatus = item.status;
        _lostOrFoundAt = item.lostOrFoundAt;
        
        // Carrega as URLs existentes
        _existingPhotosUrls = List<String>.from(item.fotosUrls);
        _selectedImages = []; // Novas imagens vazias
        _photosToDelete = []; // Nada marcado para deletar
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida se tem pelo menos 1 foto (existente OU nova)
    if (_existingPhotosUrls.isEmpty && _selectedImages.isEmpty) {
      showErrorDialog(
        context,
        title: "Erro ao cadastrar",
        message: "Selecione ao menos uma foto.",
      );
      return;
    }

    if (_lostOrFoundAt == null) {
      showErrorDialog(
        context,
        title: "Erro ao cadastrar",
        message: "Selecione a data do ocorrido.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String userId = (await AuthService.supabase().getUser)!.id;
      final String titulo = _tituloController.text.trim();
      final String descricao = _descricaoController.text.trim();
      final String localizacao = _localizacaoController.text.trim();
      final ItemCategory categoria = _selectedCategory!;
      final ItemStatus status = _selectedStatus!;
      final DateTime lostOrFoundAt = _lostOrFoundAt!;
      final List<File> imageFiles =
          _selectedImages.map((xfile) => File(xfile.path)).toList();

      if (widget.item != null) {
        // Modo EDIÇÃO
        await LostAndFoundItemService().updateItem(
          itemId: widget.item!.id,
          userId: userId,
          titulo: titulo,
          descricao: descricao,
          localizacao: localizacao,
          categoria: categoria,
          status: status,
          lostOrFoundAt: lostOrFoundAt,
          imageFiles: imageFiles.isNotEmpty ? imageFiles : null,
          existingPhotosUrls: _existingPhotosUrls,
          photosToDelete: _photosToDelete,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item atualizado com sucesso!')),
          );
          Navigator.pop(context, true); // Retorna true indicando sucesso
        }
      } else {
        // Modo CRIAÇÃO
        await LostAndFoundItemService().createLostAndFoundItem(
          userId: userId,
          titulo: titulo,
          descricao: descricao,
          localizacao: localizacao,
          categoria: categoria,
          status: status,
          lostOrFoundAt: lostOrFoundAt,
          imageFiles: imageFiles,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item criado com sucesso!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(
          context,
          title: widget.item != null ? "Erro ao atualizar item" : "Erro ao criar item",
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.item != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Editar Item' : 'Criar Reporte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo: Título
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Item',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (value.trim().length < 3) {
                      return 'Mínimo de 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (value.trim().length < 10) {
                      return 'Mínimo de 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Localização
                TextFormField(
                  controller: _localizacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Localização',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Biblioteca, laboratório de info.',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Categoria
                DropdownButtonFormField<ItemCategory>(
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: ItemCategory.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryLabel(category)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Selecione uma categoria' : null,
                ),
                const SizedBox(height: 16),

                // Campo: Status
                DropdownButtonFormField<ItemStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items: ItemStatus.values
                      .where((status) => status != ItemStatus.resolved)
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Selecione um status' : null,
                ),
                const SizedBox(height: 16),

                // Campo: Data/Hora do Ocorrido
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data do Ocorrido',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _lostOrFoundAt == null
                          ? 'Selecione a data'
                          : DateFormat('dd/MM/yyyy').format(_lostOrFoundAt!),
                      style: TextStyle(
                        color: _lostOrFoundAt == null
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Seção: Fotos
                const Text(
                  'Fotos do Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Grid de fotos (existentes + novas)
                if (_existingPhotosUrls.isNotEmpty || _selectedImages.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingPhotosUrls.length + _selectedImages.length,
                      itemBuilder: (context, index) {
                        // Fotos existentes do servidor
                        if (index < _existingPhotosUrls.length) {
                          final url = _existingPhotosUrls[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stack) {
                                      return Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeExistingPhoto(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Novas fotos locais
                        final localIndex = index - _existingPhotosUrls.length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[localIndex].path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(localIndex),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),

                // Botão: Adicionar Fotos
                OutlinedButton.icon(
                  onPressed: _chooseImageSource,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(
                    (_selectedImages.isEmpty && _existingPhotosUrls.isEmpty)
                        ? 'Adicionar Fotos'
                        : 'Adicionar Mais Fotos',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão: Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEditMode ? 'Salvar Alterações' : 'Enviar',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}