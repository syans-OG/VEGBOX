import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/utils/validators.dart';
import 'root_shell.dart';
import 'services/user_service.dart';
import 'ui/colors.dart';
import 'ui/typography.dart';
import 'ui/widgets/app_button.dart';
import 'ui/widgets/app_text_field.dart';
import 'ui/widgets/brand_mark.dart';
import 'ui/widgets/feedback.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  int _mode = 0;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  bool get _isRegister => _mode == 1;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMode(int mode) {
    if (_mode == mode) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(() {
      _mode = mode;
      _obscurePassword = true;
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isRegister) {
      getIt<UserService>().updateName(_nameController.text);
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const RootShell()));
  }

  Future<void> _showForgotPassword() async {
    final controller = TextEditingController();
    String? error;

    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void send() {
              final message = validatePhone(controller.text);
              if (message != null) {
                setDialogState(() => error = message);
                return;
              }
              Navigator.pop(dialogContext, true);
            }

            return AlertDialog(
              title: const Text('Reset password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the phone number linked to your account. We will send a reset link.',
                    style: bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => send(),
                    onChanged: (_) {
                      if (error != null) setDialogState(() => error = null);
                    },
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(onPressed: send, child: const Text('Send link')),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (sent == true && mounted) {
      showAppSnackBar(context, 'Reset link sent. Check your messages.');
    }
  }

  void _showTerms() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Terms & privacy'),
          content: const SingleChildScrollView(
            child: Text(
              'VegBox is a learning project built with Flutter. Orders, payments, and delivery in this demo are simulated.\n\n'
              'Your profile details stay on this device and are only used to personalise the demo experience. '
              'Product information is provided by the local vegetables API and may be replaced with local data when the API is unavailable.\n\n'
              'No real transactions are processed.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _socialLogin(String provider) {
    showAppSnackBar(
      context,
      '$provider sign-in is not available in this demo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            children: [
              _AuthHero(isRegister: _isRegister),
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: _buildSheet(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: forestDeep.withValues(alpha: 0.16),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthTabs(mode: _mode, onChanged: _switchMode),
            const SizedBox(height: 20),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                key: ValueKey(_mode),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegister ? 'Create your account' : 'Welcome back',
                    style: h2,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isRegister
                        ? 'A few details and your basket is ready to go.'
                        : 'Your weekly dose of fresh, delivered with care.',
                    style: bodySmall,
                  ),
                  const SizedBox(height: 20),
                  if (_isRegister) ...[
                    AppTextField(
                      label: 'Full name',
                      hint: 'Syakib',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      validator: validateName,
                    ),
                    const SizedBox(height: 14),
                  ],
                  AppTextField(
                    label: 'Phone number',
                    hint: '0851 9103 9930',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: validatePhone,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: _isRegister ? 'Set password' : 'Password',
                    hint: 'At least 6 characters',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscurePassword,
                    autofillHints: _isRegister
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    validator: validatePassword,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  if (!_isRegister) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                          visualDensity: VisualDensity.standard,
                        ),
                        const SizedBox(width: 2),
                        Text('Remember me', style: bodySmall),
                        const Spacer(),
                        TextButton(
                          onPressed: _showForgotPassword,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: label.copyWith(
                              color: forest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const SizedBox(height: 4),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _isRegister ? 'Create account' : 'Log in',
                    icon: _isRegister
                        ? Icons.arrow_forward_rounded
                        : Icons.login_rounded,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with', style: caption),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata_rounded,
                    variant: AppButtonVariant.outline,
                    height: 48,
                    onPressed: () => _socialLogin('Google'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Apple',
                    icon: Icons.apple,
                    variant: AppButtonVariant.outline,
                    height: 48,
                    onPressed: () => _socialLogin('Apple'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('By continuing, you agree to our', style: caption),
                TextButton(
                  onPressed: _showTerms,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Terms & Privacy',
                    style: caption.copyWith(
                      color: forest,
                      decoration: TextDecoration.underline,
                      decorationColor: forest,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.mode, required this.onChanged});

  final int mode;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(context, 'Log in', 0)),
          Expanded(child: _tab(context, 'Register', 1)),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String tabLabel, int index) {
    final isActive = mode == index;
    return Semantics(
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: () => onChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: forestDeep.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            tabLabel,
            style: label.copyWith(
              color: isActive ? forest : muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final compact = screen.width < 370 || screen.height < 880;
    final clusterSize = compact ? 92.0 : 104.0;

    return Container(
      height: compact ? 286 : 312,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [forestDeep, forest, leaf],
          stops: [0, 0.62, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -30,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lime.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 46),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const BrandMark(onDark: true, size: 36),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: lime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'FARM FRESH',
                              style: overline.copyWith(
                                color: white.withValues(alpha: 0.86),
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Fresh groceries,\npicked with care.',
                    style: display.copyWith(
                      color: white,
                      fontSize: compact ? 30 : 34,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          isRegister
                              ? 'Join vegbox and start filling\nyour basket with the good stuff.'
                              : 'Local farms. Honest prices.\nDelivered to your door.',
                          style: bodySmall.copyWith(
                            color: white.withValues(alpha: 0.72),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: clusterSize,
                        height: clusterSize,
                        child: _PhotoCluster(compact: compact),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCluster extends StatelessWidget {
  const _PhotoCluster({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final big = compact ? 84.0 : 94.0;
    final small = compact ? 40.0 : 46.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: big,
            height: big,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: white.withValues(alpha: 0.35),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: forestDeep.withValues(alpha: 0.3),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'asset/image/vegetables/4.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'Fresh lettuce',
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            width: small,
            height: small,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: lime, width: 3),
              boxShadow: [
                BoxShadow(
                  color: forestDeep.withValues(alpha: 0.26),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'asset/image/vegetables/6.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'Fresh tomatoes',
              ),
            ),
          ),
        ),
        Positioned(
          right: compact ? 4 : 8,
          bottom: compact ? 12 : 18,
          child: Container(
            width: compact ? 26 : 32,
            height: compact ? 26 : 32,
            decoration: const BoxDecoration(
              color: lime,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_rounded,
              size: compact ? 14 : 17,
              color: forest,
            ),
          ),
        ),
      ],
    );
  }
}
