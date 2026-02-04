import 'dart:io';
import 'package:find_uf/models/enums/item_category.dart';
import 'package:find_uf/models/enums/item_status.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/items/lost_and_found_item_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateLostAndFoundItemView extends StatefulWidget {
  const CreateLostAndFoundItemView({super.key});

  @override
  _CreateLostAndFoundItemViewState createState() => _CreateLostAndFoundItemViewState();
}

class _CreateLostAndFoundItemViewState extends State<CreateLostAndFoundItemView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localizacaoController = TextEditingController();

  ItemCategory? _selectedCategory;
  ItemStatus? _selectedStatus;
  DateTime? _lostOrFoundAt;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      showErrorDialog(context, title: "Erro ao cadastrar", message: "Selecione ao menos uma foto.");
      return;
    }

    if (_lostOrFoundAt == null) {
      
      showErrorDialog(context, title: "Erro ao cadastrar", message: "Selecione a data do ocorrido.");
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
      final List<File> imageFiles = _selectedImages.map((xfile) => File(xfile.path)).toList();
      
      await LostAndFoundItemService().createLostAndFoundItem(
        userId: userId, 
        titulo: titulo, 
        descricao: descricao, 
        localizacao: localizacao, 
        categoria: categoria, 
        status: status, 
        lostOrFoundAt: lostOrFoundAt, 
        imageFiles: imageFiles);


      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item criado com sucesso!')));

      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, title: "Erro ao criar item", message: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Reporte')),
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
                  items:
                      ItemCategory.values
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
                  validator:
                      (value) =>
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
                  items:
                      ItemStatus.values
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
                  validator:
                      (value) => value == null ? 'Selecione um status' : null,
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
                        color:
                            _lostOrFoundAt == null
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

                // Grid de fotos selecionadas
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
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
                    _selectedImages.isEmpty
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
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text(
                            'Enviar',
                            style: TextStyle(fontSize: 16),
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
