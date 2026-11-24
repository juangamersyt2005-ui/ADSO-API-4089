import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/services/api_service.dart';
import '../../core/services/aprendiz_service.dart';
import '../../data/models/aprendiz.dart';

enum EstadoAsistencia { presente, falla, excusa, retardo }

class AprendizAsistencia {
  AprendizAsistencia({required this.aprendiz, this.estado = EstadoAsistencia.presente});

  final Aprendiz aprendiz;
  EstadoAsistencia estado;
  String? novedadDetalle;
  String? horaIngreso;
}

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key, this.fichaNumero = 2824089});

  final int fichaNumero;

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  static const _primary = Color(0xFF0F766E);
  static const _surface = Color(0xFFF8F9FF);
  static const _border = Color(0xFFE2E8F0);
  static const _dark = Color(0xFF1E293B);
  static const _secondary = Color(0xFF64748B);

  DateTime _fechaSeleccionada = DateTime.now();
  EstadoAsistencia? _filtroActivo;
  String _busqueda = '';
  bool _sincronizando = false;
  bool _cargando = true;
  String? _error;
  List<AprendizAsistencia> _aprendices = [];

  final _searchController = TextEditingController();
  final _observacionController = TextEditingController(
    text: 'Sesión presencial. Registrar novedades relevantes de la clase.',
  );

  @override
  void initState() {
    super.initState();
    unawaited(_cargarAprendices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _cargarAprendices() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final collection = await AprendizService().obtenerAprendices();
      if (!mounted) return;
      setState(() {
        _aprendices = collection.items
            .map((aprendiz) => AprendizAsistencia(aprendiz: aprendiz))
            .toList();
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _cargando = false;
      });
    }
  }

  int get _presentes => _aprendices.where((item) => item.estado == EstadoAsistencia.presente).length;
  int get _fallas => _aprendices.where((item) => item.estado == EstadoAsistencia.falla).length;
  int get _excusas => _aprendices.where((item) => item.estado == EstadoAsistencia.excusa).length;
  int get _retardos => _aprendices.where((item) => item.estado == EstadoAsistencia.retardo).length;

  List<AprendizAsistencia> get _filtrados {
    final query = _busqueda.trim().toLowerCase();
    return _aprendices.where((item) {
      final aprendiz = item.aprendiz;
      final coincideBusqueda = query.isEmpty ||
          aprendiz.titulo.toLowerCase().contains(query) ||
          (aprendiz.subtitulo).toLowerCase().contains(query);
      final coincideFiltro = _filtroActivo == null || item.estado == _filtroActivo;
      return coincideBusqueda && coincideFiltro;
    }).toList();
  }

  void _marcarTodosPresentes() {
    setState(() {
      for (final item in _aprendices) {
        item.estado = EstadoAsistencia.presente;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos los aprendices fueron marcados como presentes [P]')),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaSeleccionada = fecha);
  }

  Future<void> _sincronizar() async {
    if (_aprendices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay aprendices disponibles para sincronizar.')),
      );
      return;
    }

    setState(() => _sincronizando = true);

    final fecha = '${_fechaSeleccionada.year.toString().padLeft(4, '0')}-'
        '${_fechaSeleccionada.month.toString().padLeft(2, '0')}-'
        '${_fechaSeleccionada.day.toString().padLeft(2, '0')}';

    final asistencias = _aprendices.map((item) {
      final aprendiz = item.aprendiz;
      return <String, Object?>{
        'aprendiz_id': aprendiz.uuid ?? aprendiz.id,
        'ficha_id': widget.fichaNumero,
        'fecha': fecha,
        'estado': item.estado.toUpperCode(),
        'observacion': item.novedadDetalle ?? '',
        if (item.horaIngreso != null) 'hora_ingreso': item.horaIngreso,
      };
    }).toList();

    try {
      await ApiService.instance.postJson('/asistencias/batch', <String, Object?>{
        'ficha_id': widget.fichaNumero,
        'fecha': fecha,
        'bitacora': _observacionController.text.trim(),
        'asistencias': asistencias,
      });

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Sincronización exitosa'),
            ],
          ),
          content: Text('Se enviaron ${asistencias.length} registros al lote de asistencia.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Control de asistencia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Ficha ${widget.fichaNumero}', style: const TextStyle(fontSize: 12, color: _secondary)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarAprendices,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildSessionCard()),
            SliverToBoxAdapter(child: _buildMetrics()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildFilters()),
            if (_cargando)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(child: _buildError())
            else if (_filtrados.isEmpty)
              const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No se encontraron aprendices')))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildAprendizCard(_filtrados[index]),
                  childCount: _filtrados.length,
                ),
              ),
            SliverToBoxAdapter(child: _buildBitacora()),
            SliverToBoxAdapter(child: _buildActions()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard() {
    final fecha = '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/'
        '${_fechaSeleccionada.month.toString().padLeft(2, '0')}/'
        '${_fechaSeleccionada.year}';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: _primary),
              const SizedBox(width: 8),
              Text('ADSO 4089', style: const TextStyle(color: _primary, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(fecha),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Desarrollo Móvil con Flutter', style: TextStyle(fontWeight: FontWeight.w600, color: _dark)),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _metric('P', _presentes, const Color(0xFF10B981), Icons.check_circle_outline),
          const SizedBox(width: 8),
          _metric('F', _fallas, const Color(0xFFEF4444), Icons.cancel_outlined),
          const SizedBox(width: 8),
          _metric('E', _excusas, const Color(0xFF6366F1), Icons.medical_services_outlined),
          const SizedBox(width: 8),
          _metric('R', _retardos, const Color(0xFFF59E0B), Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _metric(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 3),
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: _secondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _busqueda = value),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cédula...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: _marcarTodosPresentes,
            child: const Text('Todos [P]'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = <EstadoAsistencia?>[null, ...EstadoAsistencia.values];
    final labels = <EstadoAsistencia?, String>{
      null: 'Todos',
      EstadoAsistencia.presente: 'Presentes',
      EstadoAsistencia.falla: 'Fallas',
      EstadoAsistencia.excusa: 'Excusas',
      EstadoAsistencia.retardo: 'Retardos',
    };

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _filtroActivo == filter;
          return ChoiceChip(
            label: Text(labels[filter]!),
            selected: selected,
            onSelected: (_) => setState(() => _filtroActivo = filter),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: _secondary),
            const SizedBox(height: 10),
            Text(_error ?? 'No fue posible cargar los aprendices', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: _cargarAprendices, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildAprendizCard(AprendizAsistencia item) {
    final aprendiz = item.aprendiz;
    const colors = <EstadoAsistencia, Color>{
      EstadoAsistencia.presente: Color(0xFF10B981),
      EstadoAsistencia.falla: Color(0xFFEF4444),
      EstadoAsistencia.excusa: Color(0xFF6366F1),
      EstadoAsistencia.retardo: Color(0xFFF59E0B),
    };
    const letters = <EstadoAsistencia, String>{
      EstadoAsistencia.presente: 'P',
      EstadoAsistencia.falla: 'F',
      EstadoAsistencia.excusa: 'E',
      EstadoAsistencia.retardo: 'R',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _primary,
                child: Text(
                  aprendiz.titulo.isNotEmpty ? aprendiz.titulo.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(aprendiz.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: _dark)),
                    Text(aprendiz.subtitulo, style: const TextStyle(fontSize: 12, color: _secondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: colors[item.estado]!.withAlpha(28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  letters[item.estado]!,
                  style: TextStyle(color: colors[item.estado], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: EstadoAsistencia.values.map((estado) {
              final selected = item.estado == estado;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: estado != EstadoAsistencia.retardo ? 8 : 0),
                  child: InkWell(
                    onTap: () => setState(() => item.estado = estado),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? colors[estado] : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          letters[estado]!,
                          style: TextStyle(
                            color: selected ? Colors.white : _dark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBitacora() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: _primary),
              SizedBox(width: 8),
              Text('Bitácora y observaciones', style: TextStyle(fontWeight: FontWeight.bold, color: _dark)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observacionController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Escriba novedades de la sesión...'),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: _sincronizando ? null : _sincronizar,
          icon: _sincronizando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(_sincronizando
              ? 'Sincronizando...'
              : 'Sincronizar asistencia (${_aprendices.length} registros)'),
        ),
      ),
    );
  }
}

extension _EstadoAsistenciaName on EstadoAsistencia {
  String toUpperCode() => switch (this) {
        EstadoAsistencia.presente => 'P',
        EstadoAsistencia.falla => 'F',
        EstadoAsistencia.excusa => 'E',
        EstadoAsistencia.retardo => 'R',
      };
}
