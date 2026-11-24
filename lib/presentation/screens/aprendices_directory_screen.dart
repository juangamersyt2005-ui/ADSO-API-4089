import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/services/aprendiz_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/aprendiz.dart';
import '../widgets/record_editor.dart';
import 'module_editor_configs.dart';

class AprendicesDirectoryScreen extends StatefulWidget {
  const AprendicesDirectoryScreen({super.key, this.fichaNumero = 2824089});

  final int fichaNumero;

  @override
  State<AprendicesDirectoryScreen> createState() =>
      _AprendicesDirectoryScreenState();
}

class _AprendicesDirectoryScreenState extends State<AprendicesDirectoryScreen> {
  static const primaryTeal = Color(0xFF0F766E);
  static const surfaceLight = Color(0xFFF8F9FF);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const borderSubtle = Color(0xFFE2E8F0);

  late Future<ApiCollection<Aprendiz>> _future;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = AprendizService().obtenerAprendices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = AprendizService().obtenerAprendices();
    setState(() => _future = future);
    await future;
  }

  Future<void> _openEditor([Aprendiz? aprendiz]) async {
    try {
      final config = await cargarEditorAprendiz(aprendiz);
      if (!mounted) return;

      final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => RecordEditorForm(
          title: aprendiz == null ? 'Registrar aprendiz' : 'Editar aprendiz',
          config: config,
          isEditing: aprendiz != null,
          onSave: (values) async {
            if (aprendiz == null) {
              await AprendizService().crearAprendiz(values);
            } else {
              await AprendizService().actualizarAprendiz(
                aprendiz.uuid ?? '',
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
              aprendiz == null
                  ? 'Aprendiz registrado correctamente.'
                  : 'Aprendiz actualizado correctamente.',
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

  Future<void> _confirmDelete(Aprendiz aprendiz) async {
    final uuid = aprendiz.uuid?.trim();
    if (uuid == null || uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este registro no tiene UUID válido.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar aprendiz'),
        content: Text('¿Deseas eliminar a ${aprendiz.titulo}?'),
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
      await AprendizService().eliminarAprendiz(uuid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aprendiz eliminado correctamente.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }

  List<Aprendiz> _filtrar(List<Aprendiz> records) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return records;
    return records
        .where((aprendiz) {
          return '${aprendiz.titulo} ${aprendiz.subtitulo}'
              .toLowerCase()
              .contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: primaryTeal, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Aprendices',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ficha ${widget.fichaNumero}',
                    style: const TextStyle(color: textSecondary, fontSize: 11),
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
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        onPressed: () => unawaited(_openEditor()),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Registrar Aprendiz'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: primaryTeal,
        child: FutureBuilder<ApiCollection<Aprendiz>>(
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
                              color: textSecondary,
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

            final records = snapshot.data?.items ?? const <Aprendiz>[];
            final filtered = _filtrar(records);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildCensoCard(records.length)),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Aprendices (${filtered.length})',
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No se encontraron aprendices')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAprendizCard(filtered[index]),
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

  Widget _buildCensoCard(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.groups, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CENSO FORMATIVO',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count Aprendices',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.cloud_done_outlined,
            color: Color(0xFF10B981),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Buscar por nombre o documento...',
          prefixIcon: const Icon(Icons.search, size: 20, color: textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderSubtle),
          ),
        ),
      ),
    );
  }

  Widget _buildAprendizCard(Aprendiz aprendiz) {
    final initial = aprendiz.titulo.isNotEmpty
        ? aprendiz.titulo.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryTeal,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aprendiz.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  aprendiz.subtitulo,
                  style: const TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Acciones',
            onSelected: (value) {
              if (value == 'edit') {
                unawaited(_openEditor(aprendiz));
              } else if (value == 'delete') {
                unawaited(_confirmDelete(aprendiz));
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
