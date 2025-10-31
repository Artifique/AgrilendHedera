class AppConstants {
  static const String userTypeFarmer = 'farmer';
  static const String userTypeAgent = 'agent';
  static const String userTypeBuyer = 'buyer';
  static const List<String> cropTypes = [
    'Maïs',
    'Riz',
    'Coton',
    'Soja',
    'Manioc',
    'Ananas',
    'Autre'
  ];
  // App Info
  static const String appName = 'Agri-lend';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      "Plateforme numérique sécurisée, traçable et équitable pour connecter les agriculteurs et les acheteurs dans la chaîne d'approvisionnement agricole.";

  // API Constants
  static const String baseUrl = 'https://api.agri-lend.com';
  static const String apiVersion = 'v1';

  // Blockchain
  static const String hederaNetwork = 'testnet';
  static const String contractAddress = '0x...'; // Hedera contract address

  // Storage Keys
  static const String userBoxKey = 'user_box';
  static const String walletBoxKey = 'wallet_box';
}
