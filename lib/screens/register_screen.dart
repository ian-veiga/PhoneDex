import 'package:flutter/material.dart';
import 'package:pphonedex/components/custom_bottom_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  Widget build(BuildContext context) {
    // Captura o tamanho da tela
  final screenSize = MediaQuery.of(context).size;
  // Define um tamanho relativo (por ex. 25% da largura)
  final logoWidth  = screenSize.width * 0.5;
  final logoHeight = logoWidth; // mantém quadrado
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                  'assets/images/logo_com_nome.png',
                  width:logoWidth,
                  height: logoHeight,
                ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
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
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email),
                            border: UnderlineInputBorder(),
                          ),
                          validator: (val) => val == null || !val.contains('@')
                              ? 'Informe um e-mail válido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(_hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword
                                  ? Icons.lock
                                  : Icons.lock_open),
                              onPressed: () {
                                setState(() => _hidePassword = !_hidePassword);
                              },
                            ),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 8) {
                              return 'Use 8 ou mais caracteres';
                            }
                            if (!RegExp(r'\d').hasMatch(val)) {
                              return 'Use números (1234...)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text('▶ Use 8 ou mais caracteres'),
                        const Text('▶ Use números (1234...)'),
                        const SizedBox(height: 16),
                        TextFormField(
                          obscureText: _hideConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            prefixIcon: Icon(_hideConfirm
                                ? Icons.visibility_off
                                : Icons.visibility),
                            suffixIcon: IconButton(
                              icon: Icon(_hideConfirm
                                  ? Icons.lock
                                  : Icons.lock_open),
                              onPressed: () {
                                setState(() => _hideConfirm = !_hideConfirm);
                              },
                            ),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Confirme a senha' : null,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // cadastro
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text('CADASTRA-SE',
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
                  const SizedBox(height: 80),
                ],
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