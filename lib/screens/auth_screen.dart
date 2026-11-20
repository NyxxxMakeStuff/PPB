import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Budi');
  final TextEditingController _emailController = TextEditingController(text: 'budi@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'rahasia123');
  bool _obscurePassword = true;
  bool _isRegistering = false;

  void _handleAuth() async {
    final state = AppStateProvider.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isRegistering && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, email, dan kata sandi tidak boleh kosong.'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    final String? error = _isRegistering
        ? await state.register(
            name,
            email,
            password,
          )
        : await state.login(
            email,
            password,
          );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.accentOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleGuest() {
    final state = AppStateProvider.of(context);
    state.loginAsGuest();
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Lupa Kata Sandi', style: AppTheme.serifTitle(fontSize: 20)),
        content: const Text(
          'Tautan pemulihan kata sandi telah dikirim ke email Anda. Silakan periksa kotak masuk Anda.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF386B49),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(26, 16),
                    painter: WaveformPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'FitJournal',
                style: AppTheme.serifTitle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catat latihan dan makananmu setiap hari,\ntanpa perlu internet.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              if (_isRegistering) ...[
                const Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.darkCharcoal, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Budi',
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.darkCharcoal, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'nama@email.com',
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Kata sandi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.darkCharcoal, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: const Text(
                    'Lupa kata sandi?',
                    style: TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkCharcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isRegistering ? 'Daftar' : 'Masuk',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppColors.divider)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'atau',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _handleGuest,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkCharcoal, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Lanjut tanpa akun',
                    style: TextStyle(
                      color: AppColors.darkCharcoal,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Data tetap tersimpan di perangkatmu. Akun hanya dibutuhkan kalau kamu ingin cadangan ke cloud.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegistering ? 'Sudah punya akun? ' : 'Belum punya akun? ',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                      });
                    },
                    child: Text(
                      _isRegistering ? 'Masuk' : 'Daftar',
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.38, size.height * 0.1);
    path.lineTo(size.width * 0.52, size.height * 0.9);
    path.lineTo(size.width * 0.65, size.height * 0.35);
    path.lineTo(size.width * 0.78, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
