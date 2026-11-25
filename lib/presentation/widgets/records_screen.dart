import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'app_chrome.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'record_editor.dart';

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
    this.headerSubtitle,
    this.searchHint,
    this.navigationIndex = 3,
    this.filters = const [],
    this.extraActionsFor,
    this.openEditorOnStart = false,
    this.editorConfig,
    this.createRecord,
    this.updateRecord,
    this.canEdit,
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
  final String? headerSubtitle;
  final String? searchHint;
  final int navigationIndex;
  final List<RecordFilter<T>> filters;
  final List<RecordCardAction> Function(BuildContext context, T record)?
  extraActionsFor;
  final bool openEditorOnStart;
  final FutureOr<RecordEditorConfig> Function(T? record)? editorConfig;
  final Future<void> Function(Map<String, Object?> values)? createRecord;
  final Future<void> Function(T record, Map<String, Object?> values)?
  updateRecord;
  final bool Function(T record)? canEdit;
  final Future<void> Function(T record)? deleteRecord;
  final bool Function(T record)? canDelete;

  @override
  State<RecordsScreen<T>> createState() => _RecordsScreenState<T>();
}

class _RecordsScreenState<T> extends State<RecordsScreen<T>> {
  late Future<ApiCollection<T>> _recordsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _openingEditor = false;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _recordsFuture = widget.loadRecords();
    if (widget.openEditorOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_openEditor());
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = widget.loadRecords();
    setState(() {
      _recordsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // El FutureBuilder muestra el error y permite reintentar.
    }
  }

  Future<void> _openEditor([T? record]) async {
    final editorConfig = widget.editorConfig;
    final createRecord = widget.createRecord;
    final updateRecord = widget.updateRecord;
    if (editorConfig == null ||
        (record == null ? createRecord == null : updateRecord == null) ||
        _openingEditor) {
      return;
    }

    setState(() => _openingEditor = true);
    try {
      final config = await editorConfig(record);
      if (!mounted) return;
      setState(() => _openingEditor = false);

      final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => RecordEditorForm(
          title: record == null
              ? 'Agregar ${widget.title.toLowerCase()}'
              : 'Editar ${widget.title.toLowerCase()}',
          config: config,
          isEditing: record != null,
          onSave: (values) async {
            if (record == null) {
              await createRecord!(values);
            } else {
              await updateRecord!(record, values);
            }
          },
        ),
      );

      if (saved != true || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            record == null
                ? '${widget.title}: registro creado.'
                : '${widget.title}: registro actualizado.',
          ),
        ),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el registro: $error')),
      );
    } finally {
      if (mounted && _openingEditor) setState(() => _openingEditor = false);
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
                style: Theme.of(sheetContext).textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              for (final detail in details)
                if (detail.value?.trim().isNotEmpty == true)
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
    return FutureBuilder<ApiCollection<T>>(
      future: _recordsFuture,
      builder: (context, snapshot) {
        final connectionStatus = snapshot.hasError
            ? ApiConnectionStatus.offline
            : snapshot.connectionState == ConnectionState.waiting
            ? ApiConnectionStatus.connecting
            : snapshot.hasData
            ? ApiConnectionStatus.connected
            : ApiConnectionStatus.unknown;
        final records = snapshot.data?.items ?? <T>[];
        final query = _searchController.text.trim().toLowerCase();
        final filterIndex = widget.filters.isEmpty
            ? 0
            : _selectedFilter.clamp(0, widget.filters.length - 1).toInt();
        final filtered = records
            .where((record) {
              if (widget.filters.isNotEmpty &&
                  filterIndex != 0 &&
                  !widget.filters[filterIndex].matches(record)) {
                return false;
              }
              if (query.isEmpty) return true;
              final details = widget.detailsFor?.call(record) ?? const [];
              final searchable = [
                widget.titleFor(record),
                widget.subtitleFor(record),
                ...details.map((detail) => detail.value ?? ''),
              ].join(' ').toLowerCase();
              return searchable.contains(query);
            })
            .toList(growable: false);

        return Scaffold(
          appBar: BrandHeader(
            status: connectionStatus,
            onProfileTap: () =>
                Navigator.of(context).pushNamed('/configuracion'),
          ),
          bottomNavigationBar: AppBottomNavigationBar(
            selectedIndex: widget.navigationIndex,
          ),
          floatingActionButton: widget.editorConfig == null
              ? null
              : FloatingActionButton(
                  tooltip: 'Agregar ${widget.title.toLowerCase()}',
                  onPressed: _openingEditor
                      ? null
                      : () => unawaited(_openEditor()),
                  child: _openingEditor
                      ? const SizedBox.square(
                          dimension: 23,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppTheme.text,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (widget.headerSubtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.headerSubtitle!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardHigh,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        'Total: ${snapshot.data?.count ?? '—'}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primarySoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText:
                        widget.searchHint ??
                        'Buscar en ${widget.title.toLowerCase()}',
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
                  ),
                ),
              ),
              if (widget.filters.isNotEmpty && records.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = widget.filters[index];
                      final count = index == 0
                          ? records.length
                          : records.where(filter.matches).length;
                      return ChoiceChip(
                        selected: filterIndex == index,
                        label: Text('${filter.label} ($count)'),
                        onSelected: (_) =>
                            setState(() => _selectedFilter = index),
                      );
                    },
                  ),
                ),
              Expanded(
                child: _buildRecordsBody(context, snapshot, records, filtered),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordsBody(
    BuildContext context,
    AsyncSnapshot<ApiCollection<T>> snapshot,
    List<T> records,
    List<T> filtered,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return ErrorState(
        message: snapshot.error.toString(),
        onRetry: () => unawaited(_refresh()),
      );
    }
    if (records.isEmpty || filtered.isEmpty) {
      final noRecords = records.isEmpty;
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 360,
              child: EmptyState(
                icon: noRecords ? Icons.inbox_outlined : Icons.search_off,
                title: noRecords ? 'No hay registros' : 'Sin coincidencias',
                message: noRecords
                    ? 'Este módulo todavía no tiene datos para mostrar.'
                    : 'Prueba otra búsqueda o selecciona un filtro diferente.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 116),
        itemCount: filtered.length,
        itemBuilder: (context, index) =>
            _buildRecordCard(context, filtered[index]),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, T record) {
    final details = (widget.detailsFor?.call(record) ?? const [])
        .where((detail) => detail.value?.trim().isNotEmpty == true)
        .toList(growable: false);
    final extraActions =
        widget.extraActionsFor?.call(context, record) ??
        const <RecordCardAction>[];
    final canEdit = widget.canEdit?.call(record) ?? true;
    final canDelete = widget.canDelete?.call(record) ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.detailsFor == null
            ? null
            : () => unawaited(_showDetails(record)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(widget.icon, color: AppTheme.primarySoft),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titleFor(record),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.text,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitleFor(record),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      for (final detail in details.take(3))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.data_object_outlined,
                                size: 17,
                                color: AppTheme.muted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                detail.label,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.muted),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  detail.value!,
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (extraActions.isNotEmpty) ...[
                const SizedBox(height: 13),
                Row(
                  children: [
                    for (
                      var index = 0;
                      index < extraActions.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: 8),
                      Expanded(
                        child: extraActions[index].isPrimary
                            ? FilledButton.tonalIcon(
                                onPressed: extraActions[index].onPressed,
                                icon: Icon(extraActions[index].icon, size: 18),
                                label: Text(
                                  extraActions[index].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: extraActions[index].onPressed,
                                icon: Icon(extraActions[index].icon, size: 18),
                                label: Text(
                                  extraActions[index].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ],
              if (widget.updateRecord != null ||
                  widget.deleteRecord != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        details.isEmpty ? 'Acciones del registro' : 'Gestionar',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppTheme.primarySoft),
                      ),
                    ),
                    if (widget.updateRecord != null)
                      IconButton(
                        tooltip: canEdit
                            ? 'Editar registro'
                            : 'No se puede editar: falta UUID',
                        onPressed: canEdit
                            ? () => unawaited(_openEditor(record))
                            : null,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    if (widget.deleteRecord != null)
                      IconButton(
                        tooltip: canDelete
                            ? 'Eliminar registro'
                            : 'No se puede eliminar: falta UUID',
                        onPressed: canDelete
                            ? () => unawaited(_confirmDelete(record))
                            : null,
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
