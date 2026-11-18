import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext contexto) {
    return const MaterialApp(home: TelaCep());
  }
}

class TelaCep extends StatefulWidget {
  const TelaCep({super.key});

  @override
  State<TelaCep> createState() => _EstadoTelaCep();
}

class _EstadoTelaCep extends State<TelaCep> {
  final TextEditingController _campoCep = TextEditingController();

  Map<String, dynamic>? _endereco;
  String? _erro;

  Future<void> buscarCep() async {
    final String cep = _campoCep.text.replaceAll('-', '').trim();

    if (cep.length != 8) {
      setState(() {
        _erro = 'Digite um CEP com 8 números';
        _endereco = null;
      });
      return;
    }

    setState(() {
      _erro = null;
      _endereco = null;
    });

    final String url = 'https://viacep.com.br/ws/$cep/json/';

    try {
      final http.Response resposta = await http.get(Uri.parse(url));
      final Map<String, dynamic> dados = jsonDecode(resposta.body);

      if (dados['erro'] == true) {
        setState(() => _erro = 'CEP não encontrado');
        return;
      }

      setState(() => _endereco = dados);
    } catch (excecao) {
      setState(() => _erro = 'Erro ao consultar o CEP');
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de CEP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _campoCep,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: 'Ex.: 01001000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: buscarCep, child: const Text('Buscar')),
            const SizedBox(height: 24),
            if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            if (_endereco != null) ...[
              Text('CEP: ${_endereco!['cep']}'),
              Text('Rua: ${_endereco!['logradouro']}'),
              Text('Bairro: ${_endereco!['bairro']}'),
              Text('Cidade: ${_endereco!['localidade']} - ${_endereco!['uf']}'),
            ],
          ],
        ),
      ),
    );
  }
}