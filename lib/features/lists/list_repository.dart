import 'package:family_tracker/model/list.dart';
import 'package:family_tracker/model/list_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListRepository {
  final SupabaseClient client;

  ListRepository(this.client);

  // 🔹 Получить списки
  Future<List<Lists>> fetchLists(int familyId) async {
    final response = await client
        .from('list')
        .select()
        .eq('family_id', familyId);

    return (response as List).map((e) => Lists.fromJson(e)).toList();
  }


  // 🔹 Получить детали списки
    Future<List<ListItem>> fetchListItems(int listId) async {
    final response = await client
        .from('list_item') // correct table name
        .select()
        .eq('list_id', listId);

    return (response as List).map((e) => ListItem.fromJson(e)).toList();
  }

  // 🔹 Создать список
  /// возвращает id созданного списка
  Future<int> createList({
    required int familyId,
    required String title,
  }) async {
     final response = await client
        .from('list')
        .insert({
          'family_id': familyId,
          'title': title,
        })
        .select()
        .single();
     // response может быть Map
     return (response)['id'] as int;
  }

  // 🔹 Обновить заголовок списка
  Future<void> updateList({
    required int listId,
    required String title,
  }) async {
    await client
        .from('list')
        .update({'title': title})
        .eq('id', listId);
  }

  // 🔹 Перезаписать элементы списка
  // Для простоты: удаляем все старые и вставляем переданные
  Future<void> upsertListItems(int listId, List<ListItem> items) async {
    // удаляем существующие
    await client.from('list_item').delete().eq('list_id', listId);

    if (items.isEmpty) return;

    final inserts = items.map((i) {
      return {
        'list_id': listId,
        'title': i.title,
        'completed': i.completed,
        'order_index': i.orderIndex,
        'comment': i.comment,
      };
    }).toList();

    await client.from('list_item').insert(inserts);
  }

  // 🔹 Удалить список и все его элементы
  Future<void> deleteList(int listId) async {
    await client.from('list_item').delete().eq('list_id', listId);
    await client.from('list').delete().eq('id', listId);
  }

}
