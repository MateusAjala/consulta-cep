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
  bool _carregando = false;

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
      _carregando = true;
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
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de CEP'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _campoCep,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: 'Ex.: 01001000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _carregando ? null : buscarCep,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 24),
            if (_carregando) const Center(child: CircularProgressIndicator()),
            if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            _montarCard(),
          ],
        ),
      ),
    );
  }

  Widget _montarCard() {
    if (_endereco == null) {
      return const SizedBox();
    }

    final String complemento = _endereco!['complemento'] ?? '';

    return Card(
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(_endereco!['logradouro'] ?? ''),
            subtitle: Text(
              complemento.isEmpty ? 'Sem complemento' : complemento,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Bairro'),
            subtitle: Text(_endereco!['bairro'] ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Cidade'),
            subtitle: Text(
              '${_endereco!['localidade'] ?? ''} - ${_endereco!['uf'] ?? ''}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.markunread_mailbox),
            title: const Text('CEP'),
            subtitle: Text(_endereco!['cep'] ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('DDD'),
            subtitle: Text(_endereco!['ddd'] ?? ''),
          ),
        ],
      ),
    );
  }
}
