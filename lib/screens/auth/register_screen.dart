import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/firebase_auth_service.dart';
import '../../utils/constants.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    // Fermer le clavier
    FocusScope.of(context).unfocus();
    
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    
    final success = await authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (success && mounted) {
      // Redirection vers l'écran principal
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? 'Erreur de connexion.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context);
    final isLoading = authService.status == AuthStatus.authenticating;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo et titre
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenue sur Limux',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour accéder à votre espace personnel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Formulaire de connexion
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Champ email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Entrez votre adresse email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'Entrez votre mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 8),
                      
                      // Options "Se souvenir de moi" et "Mot de passe oublié"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                activeColor: AppColors.accent,
                              ),
                              const Text('Se souvenir de moi'),
                            ],
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Bouton de connexion
                      ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Lien vers la page d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous n\'avez pas de compte ?',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                      child: const Text('S\'inscrire'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}