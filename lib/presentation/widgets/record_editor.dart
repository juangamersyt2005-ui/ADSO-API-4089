import 'package:flutter/material.dart';

enum RecordEditorFieldType { text, integer, decimal, date, selection }

class RecordEditorOption {
  const RecordEditorOption({required this.value, required this.label});

  final String value;
  final String label;
}

class RecordEditorField {
  const RecordEditorField({
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = true,
    this.nullable = false,
    this.minimum,
    this.maximum,
    this.options = const [],
    this.emptyOptionsMessage,
  });

  final String name;
  final String label;
  final RecordEditorFieldType type;
  final bool isRequired;
  final bool nullable;
  final double? minimum;
  final double? maximum;
  final List<RecordEditorOption> options;
  final String? emptyOptionsMessage;
}

class RecordEditorConfig {
  const RecordEditorConfig({
    required this.fields,
    this.initialValues = const {},
  });

  final List<RecordEditorField> fields;
  final Map<String, String> initialValues;
}

String dateForEditor(String? value) {
  if (value == null || value.trim().isEmpty) return '';

  final parsed = DateTime.tryParse(value.trim()) ?? _parseRfcDate(value.trim());
  if (parsed == null) return '';

  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '${parsed.year}-$month-$day';
}

DateTime? _parseRfcDate(String value) {
  final match = RegExp(r'^[A-Za-z]{3},\s*(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})')
      .firstMatch(value);
  if (match == null) return null;

  const months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  final day = int.tryParse(match.group(1)!);
  final month = months[match.group(2)!];
  final year = int.tryParse(match.group(3)!);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

class RecordEditorForm extends StatefulWidget {
  const RecordEditorForm({
    required this.title,
    required this.config,
    required this.onSave,
    required this.isEditing,
    super.key,
  });

  final String title;
  final RecordEditorConfig config;
  final Future<void> Function(Map<String, Object?> values) onSave;
  final bool isEditing;

  @override
  State<RecordEditorForm> createState() => _RecordEditorFormState();
}

class _RecordEditorFormState extends State<RecordEditorForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String?> _selections;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.config.fields)
        if (field.type != RecordEditorFieldType.selection)
          field.name: TextEditingController(
            text: widget.config.initialValues[field.name] ?? '',
          ),
    };
    _selections = {
      for (final field in widget.config.fields)
        if (field.type == RecordEditorFieldType.selection)
          field.name: widget.config.initialValues[field.name],
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(RecordEditorField field, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      if (field.isRequired) return 'Este campo es obligatorio.';
      return null;
    }

    if (field.type == RecordEditorFieldType.integer ||
        field.type == RecordEditorFieldType.decimal) {
      final number = field.type == RecordEditorFieldType.integer
          ? int.tryParse(value)?.toDouble()
          : double.tryParse(value.replaceAll(',', '.'));
      if (number == null || !number.isFinite) {
        return field.type == RecordEditorFieldType.integer
            ? 'Ingresa un número entero válido.'
            : 'Ingresa un número válido.';
      }
      if (field.minimum != null && number < field.minimum!) {
        return 'El valor mínimo es ${field.minimum}.';
      }
      if (field.maximum != null && number > field.maximum!) {
        return 'El valor máximo es ${field.maximum}.';
      }
    }

    if (field.type == RecordEditorFieldType.date &&
        _parseEditorDate(value) == null) {
      return 'Selecciona una fecha válida.';
    }

    return null;
  }

  DateTime? _parseEditorDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  Future<void> _selectDate(RecordEditorField field) async {
    final controller = _controllers[field.name]!;
    final initialDate = _parseEditorDate(controller.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: 'Selecciona ${field.label.toLowerCase()}',
    );
    if (date == null || !mounted) return;

    setState(() {
      controller.text =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      _errorMessage = null;
    });
  }

  Widget _buildField(RecordEditorField field) {
    if (field.type == RecordEditorFieldType.selection) {
      final selectedValue = _selections[field.name];
      final selectionExists = field.options.any(
        (option) => option.value == selectedValue,
      );
      return DropdownButtonFormField<String>(
        key: ValueKey(field.name),
        initialValue: selectionExists ? selectedValue : null,
        decoration: InputDecoration(
          labelText: field.label,
          helperText: field.options.isEmpty
              ? field.emptyOptionsMessage ?? 'No hay opciones disponibles.'
              : null,
        ),
        items: [
          for (final option in field.options)
            DropdownMenuItem(value: option.value, child: Text(option.label)),
        ],
        onChanged: _saving || field.options.isEmpty
            ? null
            : (value) => setState(() {
                _selections[field.name] = value;
                _errorMessage = null;
              }),
        validator: (value) {
          if (!field.isRequired) return null;
          if (field.options.isEmpty) {
            return field.emptyOptionsMessage ?? 'No hay opciones disponibles.';
          }
          return value == null
              ? 'Selecciona ${field.label.toLowerCase()}.'
              : null;
        },
      );
    }

    final isDate = field.type == RecordEditorFieldType.date;
    final keyboardType = switch (field.type) {
      RecordEditorFieldType.integer => TextInputType.number,
      RecordEditorFieldType.decimal => const TextInputType.numberWithOptions(
        decimal: true,
      ),
      _ => TextInputType.text,
    };

    return TextFormField(
      controller: _controllers[field.name],
      keyboardType: keyboardType,
      readOnly: isDate,
      onTap: isDate ? () => _selectDate(field) : null,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: isDate ? 'AAAA-MM-DD' : null,
        suffixIcon: isDate ? const Icon(Icons.calendar_month_outlined) : null,
      ),
      validator: (value) => _validate(field, value),
    );
  }

  Map<String, Object?> _buildPayload() {
    final payload = <String, Object?>{};
    for (final field in widget.config.fields) {
      final rawValue = field.type == RecordEditorFieldType.selection
          ? _selections[field.name]
          : _controllers[field.name]?.text;
      final value = rawValue?.trim() ?? '';

      if (value.isEmpty && field.nullable) {
        payload[field.name] = null;
        continue;
      }

      payload[field.name] = switch (field.type) {
        RecordEditorFieldType.text => value,
        RecordEditorFieldType.integer => int.parse(value),
        RecordEditorFieldType.selection => int.parse(value),
        RecordEditorFieldType.decimal => double.parse(
          value.replaceAll(',', '.'),
        ),
        RecordEditorFieldType.date => value,
      };
    }
    return payload;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(_buildPayload());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                for (final field in widget.config.fields) ...[
                  _buildField(field),
                  const SizedBox(height: 12),
                ],
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              widget.isEditing
                                  ? Icons.save_outlined
                                  : Icons.add,
                            ),
                      label: Text(_saving ? 'Guardando…' : 'Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
