import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meta.dart';
import '../repository/metas_repository.dart';

class MetaCadastroPage extends StatefulWidget {
  final Meta? metaParaEdicao;
  const MetaCadastroPage({super.key, this.metaParaEdicao});

  @override
  State<MetaCadastroPage> createState() => _MetaCadastroPageState();
}

class _MetaCadastroPageState extends State<MetaCadastroPage> {
  User? user;

  final metasRepo = MetasRepository();

  final nomeController = TextEditingController();

  final valorController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');
  final saldoController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;

    final meta = widget.metaParaEdicao;

    if (meta != null) {
      nomeController.text = meta.nome;
      valorController.text =
          NumberFormat.simpleCurrency(locale: 'pt_BR').format(meta.valorMeta);
      saldoController.text =
          NumberFormat.simpleCurrency(locale: 'pt_BR').format(meta.saldo);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Meta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNome(),
                const SizedBox(height: 30),
                _buildValor(),
                const SizedBox(height: 30),
                _buildSaldo(),
                const SizedBox(height: 30),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildNome() {
    return TextFormField(
      controller: nomeController,
      decoration: const InputDecoration(
        hintText: 'Informe o nome da meta',
        labelText: 'Nome da Meta',
        prefixIcon: Icon(Ionicons.text_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um Nome';
        }
        return null;
      },
    );
  }

  TextFormField _buildValor() {
    return TextFormField(
      controller: valorController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Informe o valor da Meta',
        labelText: 'Meta Financeira',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Ionicons.cash_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um Valor';
        }
        final valor = NumberFormat.currency(locale: 'pt_BR')
            .parse(valorController.text.replaceAll('R\$', ''));
        if (valor <= 0) {
          return 'Informe um valor maior que zero';
        }
        return null;
      },
    );
  }

  TextFormField _buildSaldo() {
    return TextFormField(
      controller: saldoController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Informe o saldo inicial',
        labelText: 'Saldo Inicial',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Ionicons.cash_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um Saldo';
        }

        final saldo = NumberFormat.currency(locale: 'pt_BR')
            .parse(value.replaceAll('R\$', ''));
        final meta = NumberFormat.currency(locale: 'pt_BR')
            .parse(valorController.text.replaceAll('R\$', ''));

        if (saldo > meta) {
          return 'O saldo inicial deve ser menor do que a meta financeira';
        }

        return null;
      },
    );
  }

  SizedBox _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            final nome = nomeController.text;

            final userId = user?.id ?? '';

            final valor = NumberFormat.currency(locale: 'pt_BR')
                .parse(valorController.text.replaceAll('R\$', ''));

            final saldo = NumberFormat.currency(locale: 'pt_BR')
                .parse(saldoController.text.replaceAll('R\$', ''));

            final meta = Meta(
              id: 0,
              userId: userId,
              nome: nome,
              valorMeta: valor.toDouble(),
              saldo: saldo.toDouble(),
            );

            if (widget.metaParaEdicao == null) {
              await _cadastrarMeta(meta);
            } else {
              meta.id = widget.metaParaEdicao!.id;
              await _alterarMeta(meta);
            }
          }
        },
        child: const Text('Cadastrar'),
      ),
    );
  }

  Future<void> _cadastrarMeta(Meta meta) async {
    final scaffold = ScaffoldMessenger.of(context);
    await metasRepo.cadastrarMeta(meta).then((_) {
      // Mensagem de Sucesso
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Meta cadastrada com sucesso',
        ),
      ));
      Navigator.pop(context, true);
    }).catchError((error) {
      // Mensagem de Erro
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Erro ao cadastrar a meta',
        ),
      ));

      Navigator.pop(context, false);
    });
  }

  Future<void> _alterarMeta(Meta meta) async {
    final scaffold = ScaffoldMessenger.of(context);
    await metasRepo.alterarMeta(meta).then((_) {
      // Mensagem de Sucesso
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Meta alterada com sucesso',
        ),
      ));
      Navigator.pop(context, true);
    }).catchError((error) {
      // Mensagem de Erro
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Erro ao cadastrar a meta',
        ),
      ));

      Navigator.pop(context, false);
    });
  }
}
