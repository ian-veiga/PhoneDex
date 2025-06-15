import 'package:flutter/material.dart';
import 'package:pphonedex/components/bottombar.dart';
import 'package:pphonedex/services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  // Adicione controladores para os campos de email e senha
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService(); // Instância correta

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoWidth = screenSize.width * 0.5;
    final logoHeight = logoWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/images/logo_com_nome.png',
                      width: logoWidth,
                      height: logoHeight,
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: emailController, // Adicionado
                            decoration: const InputDecoration(
                              labelText: 'Usuário',
                              prefixIcon: Icon(Icons.person),
                              border: UnderlineInputBorder(),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Informe seu usuário' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController, // Adicionado
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(
                                _hidePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_hidePassword ? Icons.lock : Icons.lock_open),
                                onPressed: () {
                                  setState(() => _hidePassword = !_hidePassword);
                                },
                              ),
                              border: const UnderlineInputBorder(),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Informe sua senha' : null,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                    await _authService.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                  Navigator.pushReplacementNamed(context, '/home');
                                } catch (e) {
                                  // Se falhar, mostra mensagem de erro
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Usuário ou senha inválidos, ou usuário não cadastrado.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: const Text(
                              'ENTRAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () async{
                             if (_formKey.currentState!.validate()) {
                              try {
                                await AuthService().login(emailController.text, passwordController.text);
                                Navigator.pushReplacementNamed(context, '/home');
                              } catch (e) {
                                // Handle login errors
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                              child: const Text(
                                'OU',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: const Text(
                              'CADASTRE-SE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomBar(),
          ),
        ],
      ),
    );
  }
}
