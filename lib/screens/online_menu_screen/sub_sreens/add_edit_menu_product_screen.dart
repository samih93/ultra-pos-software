import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/app_text_style.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;

class AddEditMenuProductScreen extends ConsumerStatefulWidget {
  final ProductModel? p;
  final CategoryModel c;
  const AddEditMenuProductScreen({this.p, required this.c, super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEditMenuProductScreenState();
}

class _AddEditMenuProductScreenState
    extends ConsumerState<AddEditMenuProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  bool _isOffer = false;
  File? _selectedImage;
  bool _isSaving = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data or empty
    _nameController = TextEditingController(text: widget.p?.name ?? '');
    _priceController = TextEditingController(
      text: widget.p?.sellingPrice?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.p?.description ?? '',
    );
    _isOffer = widget.p?.isOffer ?? false;
    _selectedImage = widget.p?.pickedImageFile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['jpg', 'png', 'jpeg', 'webp'],
        type: FileType.custom,
      );
      if (result != null) {
        // Load image into memory
        Uint8List imageBytes = await File(
          result.files.single.path!,
        ).readAsBytes();

        // Decode image
        img.Image? decodedImage = img.decodeImage(imageBytes);
        if (decodedImage == null) {
          throw Exception("Unable to decode image");
        }

        // Resize if necessary (smaller for menu items)
        if (decodedImage.width > 300 || decodedImage.height > 300) {
          decodedImage = img.copyResize(
            decodedImage,
            width: decodedImage.width > decodedImage.height ? 300 : null,
            height: decodedImage.height >= decodedImage.width ? 300 : null,
          );
        }

        // Encode back to bytes
        Uint8List resizedBytes = Uint8List.fromList(
          img.encodeJpg(decodedImage, quality: 80),
        );

        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ToastUtils.showToast(
        message: 'Error picking image: $e',
        type: RequestState.error,
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final product = ProductModel(
      id: widget.p?.id,
      name: _nameController.text.trim(),
      sellingPrice: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      isOffer: _isOffer,
      categoryId: widget.c.id,
      isActive: true,
      sortOrder: widget.p?.sortOrder ?? 50,
      selected: null,
    );

    try {
      if (widget.p == null) {
        // Create new product
        await ref.read(menuControllerProvider.notifier).createMenuItem(product);
      } else {
        // Update existing product
        await ref.read(menuControllerProvider.notifier).updateMenuItem(product);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      ToastUtils.showToast(
        message: 'Error saving product: $e',
        type: RequestState.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.p != null
              ? "${S.of(context).edit} ${widget.p!.name}"
              : S.of(context).addProductButton,
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          AppSquaredOutlinedButton(
            backgroundColor: Pallete.whiteColor,
            states: _isSaving ? [RequestState.loading] : const [],
            onPressed: () => _isSaving == true ? null : _saveProduct(),
            child: const Icon(FontAwesomeIcons.floppyDisk, size: 20),
          ),
          defaultGap,
        ],
      ),
      body: Container(
        color: context.cardColor,
        padding: defaultPadding,
        margin: defaultMargin,
        child: SizedBox(
          height: context.height,
          width: context.width,
          child: Form(
            key: _formKey,
            child: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: context.isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormFields(),
                          kGap20,
                          _buildImageSection(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildFormFields()),
                          Expanded(child: _buildImageSection()),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Display (Read-only)
        DefaultTextView(
          text: S.of(context).category,
          fontWeight: FontWeight.bold,
        ),
        kGap10,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Pallete.greyColor),
            borderRadius: BorderRadius.circular(8),
            color: Pallete.greyColor.withValues(alpha: 0.1),
          ),
          width: double.infinity,
          child: DefaultTextView(text: widget.c.name ?? 'N/A'),
        ),
        AppTextFormField(
          showText: true,
          controller: _nameController,
          hinttext: S.of(context).name,
          onvalidate: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter product name';
            }
            return null;
          },
        ),
        AppTextFormField(
          showText: true,
          controller: _priceController,
          hinttext: S.of(context).sellingPrice,
          format: numberTextFormatter,
          onvalidate: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter selling price';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
        ),
        AppTextFormField(
          showText: true,
          controller: _descriptionController,
          hinttext: S.of(context).description,
          minline: 3,
          maxligne: 4,
          height: 80,
        ),
        // Is Offer Toggle
        Row(
          children: [
            DefaultTextView(
              text: S.of(context).offerOnMenu,
              fontWeight: FontWeight.bold,
            ),
            kGap10,
            Checkbox(
              value: _isOffer,
              onChanged: (value) {
                setState(() {
                  _isOffer = value!;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Product Image
        DefaultTextView(
          text: S.of(context).productImage,
          fontWeight: FontWeight.bold,
        ),
        kGap10,
        Center(
          child: DropTarget(
            onDragEntered: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragExited: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            onDragDone: (details) async {
              setState(() {
                _isDragging = false;
              });
              // Handle the dropped files
              for (var file in details.files) {
                final fileName = file.path.toLowerCase();
                // Check if it's an image file
                if (fileName.endsWith('.png') ||
                    fileName.endsWith('.webp') ||
                    fileName.endsWith('.jpg') ||
                    fileName.endsWith('.jpeg') ||
                    fileName.endsWith('.gif')) {
                  // Read the file and set it as the product image
                  final imageFile = File(file.path);

                  setState(() {
                    _selectedImage = imageFile;
                  });
                  // Decode and resize

                  break; // Only take the first valid image
                }
              }
            },
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: _isDragging
                      ? Border.all(color: context.primaryColor, width: 2)
                      : Border.all(color: Pallete.greyColor, width: 1),
                ),
                child: _selectedImage != null
                    ? Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: context.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _isDragging
                              ? context.primaryColor.withValues(alpha: 0.1)
                              : Pallete.greyColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 60,
                              color: _isDragging
                                  ? context.primaryColor
                                  : Pallete.greyColor,
                            ),
                            kGap10,
                            DefaultTextView(
                              text: S.of(context).dragDropImage,
                              color: _isDragging
                                  ? context.primaryColor
                                  : Pallete.greyColor,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
