import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/services/api_service.dart';
import '../../core/services/persona_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/persona.dart';
import '../widgets/record_editor.dart';
import 'module_editor_configs.dart';

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key, this.fichaNumero = 2824089});

  final int fichaNumero;

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  late Future<ApiCollection<Persona>> _future;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = PersonaService().obtenerPersonas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = PersonaService().obtenerPersonas();
    setState(() => _future = future);
    await future;
  }

  Future<void> _openEditor([Persona? persona]) async {
    try {
      final config = cargarEditorPersona(persona);
      final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => RecordEditorForm(
          title: persona == null ? 'Registrar persona' : 'Editar persona',
          config: config,
          isEditing: persona != null,
          onSave: (values) async {
            if (persona == null) {
              await PersonaService().crearPersona(values);
            } else {
              await PersonaService().actualizarPersona(
                persona.uuid ?? '',
                values,
              );
            }
          },
        ),
      );

      if (saved == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              persona == null
                  ? 'Persona registrada correctamente.'
                  : 'Persona actualizada correctamente.',
            ),
          ),
        );
        await _refresh();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el formulario: $error')),
      );
    }
  }

  Future<void> _confirmDelete(Persona persona) async {
    final uuid = persona.uuid?.trim();
    if (uuid == null || uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta persona no tiene UUID válido.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text('¿Deseas eliminar a ${persona.titulo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PersonaService().eliminarPersona(uuid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Persona eliminada correctamente.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }

  List<Persona> _filtrar(List<Persona> records) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return records;
    return records
        .where((persona) {
          return '${persona.titulo} ${persona.subtitulo}'
              .toLowerCase()
              .contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Directorio de Personas',
                    style: TextStyle(
                      color: AppTheme.dark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Ficha ${widget.fichaNumero} • ADSO',
                    style: const TextStyle(
                      color: AppTheme.neutral,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => unawaited(_refresh()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => unawaited(_openEditor()),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nueva persona'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primary,
        child: FutureBuilder<ApiCollection<Persona>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 420,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 42,
                              color: AppTheme.neutral,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: () => unawaited(_refresh()),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final records = snapshot.data?.items ?? const <Persona>[];
            final filtered = _filtrar(records);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSummary(records.length)),
                SliverToBoxAdapter(child: _buildSearch()),
                SliverToBoxAdapter(child: _buildFilters()),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No se encontraron personas')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPersonaCard(filtered[index]),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.groups, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMUNIDAD FORMATIVA',
                  style: TextStyle(
                    color: AppTheme.neutral,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count Personas',
                  style: const TextStyle(
                    color: AppTheme.dark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.cloud_done_outlined, color: Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: 'Buscar por nombre o documento...',
          prefixIcon: Icon(Icons.search, color: AppTheme.neutral),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _FilterChip(label: 'Todos', selected: true),
          _FilterChip(label: 'Instructores'),
          _FilterChip(label: 'Directivos'),
          _FilterChip(label: 'Bienestar'),
        ],
      ),
    );
  }

  Widget _buildPersonaCard(Persona persona) {
    final initial = persona.titulo.isNotEmpty
        ? persona.titulo.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  persona.subtitulo,
                  style: const TextStyle(color: AppTheme.neutral, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                unawaited(_openEditor(persona));
              } else if (value == 'delete') {
                unawaited(_confirmDelete(persona));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      selectedColor: AppTheme.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.dark,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? AppTheme.primary : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
