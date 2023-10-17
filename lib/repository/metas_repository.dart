import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meta.dart';

class MetasRepository {
  Future<List<Meta>> listarMetas({required String userId}) async {
    final supabase = Supabase.instance.client;

    var query = supabase
        .from('metas')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', userId);

    var data = await query;

    final list = data.map((map) {
      return Meta.fromMap(map);
    }).toList();

    return list;
  }

  Future cadastrarMeta(Meta meta) async {
    final supabase = Supabase.instance.client;

    await supabase.from('metas').insert({
      'user_id': meta.userId,
      'nome': meta.nome,
      'valor_meta': meta.valorMeta,
      'saldo': meta.saldo,
    });
  }

  Future alterarMeta(Meta meta) async {
    final supabase = Supabase.instance.client;

    await supabase.from('metas').update({
      'user_id': meta.userId,
      'nome': meta.nome,
      'valor_meta': meta.valorMeta,
      'saldo': meta.saldo,
    }).match({'id': meta.id});
  }

  Future excluirMeta(int id) async {
    final supabase = Supabase.instance.client;

    await supabase.from('metas').delete().match({'id': id});
  }
}
