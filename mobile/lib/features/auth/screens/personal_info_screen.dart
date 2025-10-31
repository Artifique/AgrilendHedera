import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dio/dio.dart';
import 'package:agrilend/services/api_service.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  final String userType;
  final String email;
  final String password;

  const PersonalInfoScreen({
    super.key,
    required this.userType,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Buyer specific
  final _companyNameController = TextEditingController();
  final _activityTypeController = TextEditingController();

  // Farmer specific
  final _farmNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  
  int _currentStep = 3;
  int _totalSteps = 6;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _activityTypeController.dispose();
    _farmNameController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/basic-info'),
        ),
        title: const Text('Informations personnelles'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 32 : 24,
                vertical: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressIndicator(),
                    SizedBox(height: constraints.maxHeight * 0.03),
                    _buildHeader(),
                    SizedBox(height: constraints.maxHeight * 0.04),
                    _buildNameFields(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    _buildAddressField(),
                    const SizedBox(height: 16),
                    ..._buildUserSpecificFields(),
                    SizedBox(height: constraints.maxHeight * 0.04),
                    _buildNextButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < _currentStep;
        final isCurrent = stepNumber == _currentStep;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                    ? Colors.green 
                    : isCurrent 
                      ? Colors.green 
                      : Colors.grey.shade300,
                ),
                child: Center(
                  child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              if (index < _totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 40,
            color: Colors.blue,
          ),
        ).animate().scale(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        ),
        const SizedBox(height: 16),
        Text(
          'Informations personnelles',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ),
        const SizedBox(height: 8),
        Text(
          'Complétez vos informations personnelles',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              prefixIcon: Icon(Icons.person_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Requis';
              }
              return null;
            },
          ).animate().slideX(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 600),
            begin: -1,
            end: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Requis';
              }
              return null;
            },
          ).animate().slideX(
            delay: const Duration(milliseconds: 1000),
            duration: const Duration(milliseconds: 600),
            begin: 1,
            end: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Téléphone',
        prefixIcon: Icon(Icons.phone_rounded),
        hintText: '+237 6XX XXX XXX',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir votre téléphone';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 600),
      begin: -1,
      end: 0,
    );
  }

  Widget _buildAddressField() {
    String labelText;
    if (widget.userType == 'farmer') {
      labelText = 'Localisation de la ferme';
    } else if (widget.userType == 'buyer') {
      labelText = 'Adresse de l entreprise';
    } else {
      labelText = 'Adresse';
    }

    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.location_on_rounded),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir l\'adresse';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1800),
      duration: const Duration(milliseconds: 600),
      begin: 1,
      end: 0,
    );
  }

  List<Widget> _buildUserSpecificFields() {
    List<Widget> fields = [];
    
    if (widget.userType == 'farmer') {
      fields.addAll([
        TextFormField(
          controller: _farmNameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la ferme',
            prefixIcon: Icon(Icons.business_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le nom de la ferme';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _farmSizeController,
          decoration: const InputDecoration(
            labelText: 'Taille de la ferme',
            prefixIcon: Icon(Icons.square_foot_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir la taille de la ferme';
            }
            return null;
          },
        ),
      ]);
    } else if (widget.userType == 'buyer') {
      fields.addAll([
        TextFormField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Nom de l\'entreprise',
            prefixIcon: Icon(Icons.business_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le nom de l\'entreprise';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _activityTypeController,
          decoration: const InputDecoration(
            labelText: 'Type d\'activité',
            prefixIcon: Icon(Icons.work_outline_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le type d\'activité';
            }
            return null;
          },
        ),
      ]);
    }
    
    return fields;
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleNext,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          : const Text('Continuer'),
    ).animate().scale(
      delay: const Duration(milliseconds: 2400),
      duration: const Duration(milliseconds: 600),
    );
  }



  void _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> data = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': widget.email,
      'password': widget.password,
      'phone': _phoneController.text.trim(),
      'role': widget.userType.toUpperCase(),
    };

    if (widget.userType == 'farmer') {
      data.addAll({
        'farmName': _farmNameController.text.trim(),
        'farmLocation': _addressController.text.trim(),
        'farmSize': _farmSizeController.text.trim(),
      });
    } else if (widget.userType == 'buyer') {
      data.addAll({
        'companyName': _companyNameController.text.trim(),
        'activityType': _activityTypeController.text.trim(),
        'companyAddress': _addressController.text.trim(),
      });
    }

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/api/auth/register',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Succès'),
              content: const Text('Votre compte a été créé avec succès.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/kyc-verification?userType=${widget.userType}');
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: Text('Erreur: ${response.statusMessage}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } on DioException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur réseau'),
            content: Text('Erreur réseau: ${e.message}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
