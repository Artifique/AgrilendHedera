import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class KycVerificationScreen extends ConsumerStatefulWidget {
  final String userType;
  
  const KycVerificationScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _idTypeController = TextEditingController();
  
  File? _idFrontImage;
  File? _idBackImage;
  File? _selfieImage;
  bool _isProcessing = false;
  bool _isAutoMode = true; // Mode développement automatique
  int _currentStep = 4;
  int _totalSteps = 6;

  @override
  void initState() {
    super.initState();
    if (_isAutoMode) {
      _initializeAutoMode();
    }
  }

  void _initializeAutoMode() {
    // Initialiser automatiquement les données pour le mode développement
    _idTypeController.text = 'CNI';
    _idNumberController.text = '123456789';
    
    // Simuler des images (optionnel)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showAutoModeDialog();
      }
    });
  }

  void _showAutoModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.developer_mode_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Mode Développement'),
          ],
        ),
        content: const Text(
          'En mode développement, la vérification KYC est automatique.\n\n'
          'Voulez-vous continuer avec la vérification automatique ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isAutoMode = false;
              setState(() {});
            },
            child: const Text('Mode Manuel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startAutoVerification();
            },
            child: const Text('Continuer Automatiquement'),
          ),
        ],
      ),
    );
  }

  void _startAutoVerification() async {
    setState(() {
      _isProcessing = true;
    });

    // Simuler le processus de vérification automatique
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      // Naviguer vers l'écran de confirmation avec le type d'utilisateur
      context.go('/registration-complete?userType=${widget.userType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/personal-info'),
        ),
        title: const Text('Vérification KYC'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildIdInfoFields(),
                const SizedBox(height: 20),
                _buildIdFrontUpload(),
                const SizedBox(height: 20),
                _buildIdBackUpload(),
                const SizedBox(height: 20),
                _buildSelfieUpload(),
                const SizedBox(height: 32),
                if (_isAutoMode) _buildAutoModeButton(),
                const SizedBox(height: 16),
                _buildNextButton(),
              ],
            ),
          ),
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
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            size: 40,
            color: Colors.purple,
          ),
        ).animate().scale(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        ),
        const SizedBox(height: 16),
        Text(
          'Vérification d\'identité',
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
          'Téléchargez vos documents d\'identité pour vérification',
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

  Widget _buildIdInfoFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _idTypeController.text.isEmpty ? null : _idTypeController.text,
          decoration: const InputDecoration(
            labelText: 'Type de pièce d\'identité',
            prefixIcon: Icon(Icons.credit_card_rounded),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'CNI', child: Text('Carte Nationale d\'Identité')),
            DropdownMenuItem(value: 'PASSPORT', child: Text('Passeport')),
            DropdownMenuItem(value: 'DRIVER_LICENSE', child: Text('Permis de conduire')),
          ],
          onChanged: (value) {
            _idTypeController.text = value ?? '';
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner le type de pièce';
            }
            return null;
          },
        ).animate().slideX(
          delay: const Duration(milliseconds: 800),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _idNumberController,
          decoration: const InputDecoration(
            labelText: 'Numéro de pièce d\'identité',
            prefixIcon: Icon(Icons.numbers_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le numéro de pièce';
            }
            return null;
          },
        ).animate().slideX(
          delay: const Duration(milliseconds: 1000),
          duration: const Duration(milliseconds: 600),
          begin: 1,
          end: 0,
        ),
      ],
    );
  }

  Widget _buildIdFrontUpload() {
    return _buildImageUpload(
      title: 'Recto de la pièce d\'identité',
      image: _idFrontImage,
      onTap: () => _pickImage(ImageSource.camera, (file) {
        setState(() {
          _idFrontImage = file;
        });
      }),
      delay: const Duration(milliseconds: 1200),
    );
  }

  Widget _buildIdBackUpload() {
    return _buildImageUpload(
      title: 'Verso de la pièce d\'identité',
      image: _idBackImage,
      onTap: () => _pickImage(ImageSource.camera, (file) {
        setState(() {
          _idBackImage = file;
        });
      }),
      delay: const Duration(milliseconds: 1400),
    );
  }

  Widget _buildSelfieUpload() {
    return _buildImageUpload(
      title: 'Selfie avec votre pièce d\'identité',
      image: _selfieImage,
      onTap: () => _pickImage(ImageSource.camera, (file) {
        setState(() {
          _selfieImage = file;
        });
      }),
      delay: const Duration(milliseconds: 1600),
    );
  }

  Widget _buildImageUpload({
    required String title,
    required File? image,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: image != null ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: image != null ? Colors.green.withOpacity(0.05) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                image != null ? Icons.check_circle : Icons.upload_rounded,
                color: image != null ? Colors.green : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: image != null ? Colors.green : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(image != null ? 'Remplacer' : 'Prendre une photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: image != null ? Colors.green : null,
                side: BorderSide(
                  color: image != null ? Colors.green : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(
      delay: delay,
      duration: const Duration(milliseconds: 600),
      begin: 1,
      end: 0,
    );
  }

  Widget _buildAutoModeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.developer_mode_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Mode Développement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Vérification automatique disponible pour les tests',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _startAutoVerification,
              icon: _isProcessing 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isProcessing ? 'Vérification...' : 'Vérification Automatique'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(
      delay: const Duration(milliseconds: 1700),
      duration: const Duration(milliseconds: 600),
      begin: 1,
      end: 0,
    );
  }

  Widget _buildNextButton() {
    final isComplete = _idFrontImage != null && 
                      _idBackImage != null && 
                      _selfieImage != null &&
                      _idNumberController.text.isNotEmpty &&
                      _idTypeController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: isComplete ? _handleNext : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Continuer'),
    ).animate().scale(
      delay: const Duration(milliseconds: 1800),
      duration: const Duration(milliseconds: 600),
    );
  }

  Future<void> _pickImage(ImageSource source, Function(File) onImagePicked) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        onImagePicked(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNext() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isProcessing = true;
    });

    // Simuler le traitement KYC
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      // Naviguer vers l'écran de confirmation avec le type d'utilisateur
      context.go('/registration-complete?userType=${widget.userType}');
    }
  }
}
