import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController(text: 'admin@gym.tn');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordSheet(BuildContext context) {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réinitialisation du mot de passe', style: Theme.of(ctx).textTheme.displaySmall),
            const SizedBox(height: 8),
            const Text(
              'Saisissez votre e-mail pour recevoir le lien de réinitialisation.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Adresse e-mail',
              hintText: 'admin@gym.tn',
              controller: resetEmailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Envoyer le lien',
              icon: Icons.mark_email_read_rounded,
              onPressed: () async {
                if (resetEmailCtrl.text.isNotEmpty) {
                  await ctx.read<AuthController>().resetPassword(resetEmailCtrl.text.trim());
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Un e-mail de réinitialisation a été envoyé à ${resetEmailCtrl.text}'),
                        backgroundColor: AppColors.lime,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center_rounded, color: AppColors.lime, size: 48),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'GYM ADMIN',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 34,
                            letterSpacing: 2,
                            color: AppColors.lime,
                          ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Connexion Espace Administration',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 40),

                  AppTextField(
                    label: 'Adresse E-mail',
                    hintText: 'admin@gym.tn',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Mot de passe',
                    hintText: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordSheet(context),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: AppColors.lime, fontSize: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Consumer<AuthController>(
                    builder: (context, auth, child) {
                      return PrimaryButton(
                        label: 'Se connecter',
                        icon: Icons.login_rounded,
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          final success = await auth.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          if (success && context.mounted) {
                            context.go('/admin/home');
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Identifiants invalides'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
