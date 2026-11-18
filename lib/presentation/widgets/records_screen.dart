import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import 'empty_state.dart';
import 'error_state.dart';

class RecordDetailField {
  const RecordDetailField(this.label, this.value);

  final String label;
  final String? value;
}

class RecordsScreen<T> extends StatefulWidget {
  const RecordsScreen({
    required this.title,
    required this.icon,
    required this.loadRecords,
    required this.titleFor,
    required this.subtitleFor,
    this.detailsFor,
    this.deleteRecord,
    this.canDelete,
    super.key,
  });

  final String title;
  final IconData icon;
  final Future<ApiCollection<T>> Function() loadRecords;
  final String Function(T record) titleFor;
  final String Function(T record) subtitleFor;
  final List<RecordDetailField> Function(T record)? detailsFor;
  final Future<void> Function(T record)? deleteRecord;
  final bool Function(T record)? canDelete;

  @override
  State<RecordsScreen<T>> createState() => _RecordsScreenState<T>();
}

class _RecordsScreenState<T> extends State<RecordsScreen<T>> {
  late Future<ApiCollection<T>> _recordsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recordsFuture = widget.loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = widget.loadRecords();
    setState(() => _recordsFuture = future);
    try {
      await future;
    } catch (_) {
      // El FutureBuilder muestra el error y permite reintentar.
    }
  }

  Future<void> _confirmDelete(T record) async {
    final deleteRecord = widget.deleteRecord;
    if (deleteRecord == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Deseas eliminar «${widget.titleFor(record)}»? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await deleteRecord(record);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title}: registro eliminado.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el registro: $error')),
      );
    }
  }

  Future<void> _showDetails(T record) async {
    final details = widget.detailsFor?.call(record);
    if (details == null || details.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.titleFor(record),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitleFor(record),
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 12),
              for (final detail in details)
                if (detail.value?.isNotEmpty == true)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(detail.label),
                    subtitle: Text(detail.value!),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => unawaited(_refresh()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar en ${widget.title.toLowerCase()}',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<ApiCollection<T>>(
              future: _recordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: () => unawaited(_refresh()),
                  );
                }

                final records = snapshot.data?.items ?? <T>[];
                if (records.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 360,
                          child: EmptyState(
                            title: 'No hay registros',
                            message: 'Este módulo no tiene datos para mostrar.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final query = _searchController.text.trim().toLowerCase();
                final filtered = records.where((record) {
                  if (query.isEmpty) return true;
                  final text =
                      '${widget.titleFor(record)} ${widget.subtitleFor(record)}'
                          .toLowerCase();
                  return text.contains(query);
                }).toList(growable: false);

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 360,
                          child: EmptyState(
                            icon: Icons.search_off,
                            title: 'Sin coincidencias',
                            message: 'Prueba con otro nombre o término.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final record = filtered[index];
                      final deleteEnabled = widget.canDelete?.call(record) ?? true;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            child: Icon(widget.icon),
                          ),
                          onTap: widget.detailsFor == null
                              ? null
                              : () => unawaited(_showDetails(record)),
                          title: Text(widget.titleFor(record)),
                          subtitle: Text(widget.subtitleFor(record)),
                          trailing: widget.deleteRecord == null
                              ? null
                              : IconButton(
                                  tooltip: deleteEnabled
                                      ? 'Eliminar registro'
                                      : 'No se puede eliminar: falta UUID',
                                  onPressed: deleteEnabled
                                      ? () => unawaited(_confirmDelete(record))
                                      : null,
                                  icon: const Icon(Icons.delete_outline),
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
