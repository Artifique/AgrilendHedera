import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // Explicitly import widgets.dart
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerStatefulWidget
import 'package:agrilend/models/product.dart'; // Import Product model
import 'package:agrilend/features/buyer/providers/buyer_providers.dart'; // Import productsProvider
import 'package:agrilend/core/providers/offer_provider.dart'; // Import offerServiceProvider

class CreateOfferScreen extends ConsumerStatefulWidget {
  const CreateOfferScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct; // To store the selected product
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availabilityDateController =
      TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _availabilityDateController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _availabilityDateController.dispose();
    super.dispose();
  }

  void _submitForm() async { // Make it async
    if (_formKey.currentState!.validate()) {
      // Process data
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un produit')),
        );
        return;
      }

      final offerService = ref.read(offerServiceProvider); // Use ref.read

      final int productId = _selectedProduct!.id!;
      final double availableQuantity = double.parse(_quantityController.text);
      final double suggestedUnitPrice = double.parse(_priceController.text);
      final String availabilityDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final String notes = _descriptionController.text;

      final bool success = await offerService.createOffer(
        productId: productId,
        availableQuantity: availableQuantity,
        suggestedUnitPrice: suggestedUnitPrice,
        availabilityDate: availabilityDate,
        notes: notes,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Offre créée pour ${_selectedProduct!.name} le $availabilityDate')),
        );
        GoRouter.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la création de l\'offre')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider); // Watch productsProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Offre'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Détails de l'Offre",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                decoration: InputDecoration(
                  labelText: 'Sélectionner un produit',
                  hintText: 'Ex: Tomates fraîches',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.agriculture_rounded),
                ),
                items: products.map((product) { // Use products from ref.watch
                  return DropdownMenuItem<Product>(
                    value: product,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (Product? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                    if (_selectedProduct != null) {
                      _descriptionController.text = _selectedProduct!.description ?? '';
                      _quantityController.text = _selectedProduct!.unit;
                    } else {
                      _descriptionController.clear();
                      _quantityController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un produit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description du produit',
                  hintText:
                      'Ex: Tomates rouges, juteuses, cultivées localement',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_rounded),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantité',
                        hintText: 'Ex: 100 (kg, litres, etc.)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.numbers_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la quantité';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prix suggéré (FCFA)',
                        hintText: 'Ex: 500',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _availabilityDateController,
                decoration: InputDecoration(
                  labelText: 'Date de disponibilité',
                  hintText: 'Sélectionnez une date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white),
                label: Text(
                  "Créer l'offre",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => GoRouter.of(context).pop(),
                icon: const Icon(Icons.cancel_outlined),
                label: Text(
                  'Annuler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
