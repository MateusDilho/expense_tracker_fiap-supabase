import 'package:expense_tracker/models/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../repository/metas_repository.dart';
import 'metas_cadastro_page.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({Key? key}) : super(key: key);

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  final metasRepo = MetasRepository();
  late Future<List<Meta>> futureMetas;
  User? user;

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;
    futureMetas = metasRepo.listarMetas(userId: user?.id ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suas Metas'),
      ),
      body: FutureBuilder<List<Meta>>(
        future: futureMetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar as metas"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Nenhuma meta encontrada"),
                  const SizedBox(height: 30),
                  _buildButton(),
                ],
              ),
            );
          } else {
            final metas = snapshot.data!;

            double totalValorMetas = 0.0;
            double totalValorSaldo = 0.0;

            for (final meta in metas) {
              totalValorMetas += meta.valorMeta;
              totalValorSaldo += meta.saldo;
            }

            double porcentagem = (totalValorSaldo / totalValorMetas) * 100;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGraph(porcentagem),
                  _buildTotal(totalValorMetas, totalValorSaldo),
                  _buildListGoals(metas),
                  _buildButton(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildGraph(double porcentagem) {
    return Container(
      height: 200,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 180,
            endAngle: 0,
            showLabels: false,
            minimum: 0,
            maximum: 100,
            canScaleToFit: true,
            showTicks: false,
            ranges: <GaugeRange>[
              GaugeRange(
                  startValue: 0,
                  endValue: porcentagem,
                  gradient: const SweepGradient(
                      colors: <Color>[Color(0xFFFF7676), Color(0xFFF54EA2)],
                      stops: <double>[0.25, 0.75]),
                  startWidth: 10,
                  endWidth: 10),
            ],
            pointers: <GaugePointer>[],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Text(
                      '${porcentagem.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  angle: 45,
                  axisValue: 10,
                  positionFactor: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(double totalValorMetas, double totalValorSaldo) {
    return Center(
      child: Container(
        width: 470,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Total:'),
                  Text('\$${totalValorSaldo.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18.0)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Meta Total:', style: TextStyle(fontSize: 16.0)),
                  Text('\$${totalValorMetas.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListGoals(List<Meta> metas) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: metas.length,
              itemBuilder: (context, index) {
                Meta meta = metas[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MetaCadastroPage(
                                metaParaEdicao: meta,
                              ),
                            ),
                          ) as bool?;

                          if (result == true) {
                            setState(() {
                              futureMetas = metasRepo.listarMetas(
                                userId: user?.id ?? '',
                              );
                            });
                          }
                        },
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        foregroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          await metasRepo.excluirMeta(meta.id);
                          setState(() {
                            metas.removeAt(index);
                          });
                        },
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        foregroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Excluir',
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.star),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(meta.nome),
                              Text('R\$${meta.valorMeta.toStringAsFixed(2)}'),
                            ],
                          ),
                          LinearProgressIndicator(
                            value: meta.saldo / meta.valorMeta,
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                          Text(
                            'R\$${meta.saldo.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/meta-cadastro') as bool?;

          if (result == true) {
            setState(
              () {
                futureMetas = metasRepo.listarMetas(
                  userId: user?.id ?? '',
                );
              },
            );
          }
        },
        icon: const Icon(Icons.add, color: Colors.grey),
        label: const Text(
          'Nova Meta',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(Size(100, 40)),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
          side: MaterialStateProperty.all<BorderSide>(
              const BorderSide(color: Colors.grey, width: 1.0)),
        ),
      ),
    );
  }
}
