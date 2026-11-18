import 'package:adso4089_mobile/core/services/api_service.dart';
import 'package:adso4089_mobile/presentation/widgets/module_card.dart';
import 'package:adso4089_mobile/presentation/widgets/record_editor.dart';
import 'package:adso4089_mobile/presentation/widgets/records_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza la fecha HTTP de aprendices para el formulario', () {
    expect(dateForEditor('Wed, 15 May 2002 00:00:00 GMT'), '2002-05-15');
  });

  testWidgets('la tarjeta muestra el conteo y permite navegar', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 190,
            child: ModuleCard(
              title: 'Aprendices',
              icon: Icons.school_outlined,
              count: 2,
              isLoading: false,
              hasError: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aprendices'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  testWidgets('la tarjeta no muestra una cantidad falsa si falla el endpoint', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 190,
            child: ModuleCard(
              title: 'Cursos',
              icon: Icons.menu_book_outlined,
              count: null,
              isLoading: false,
              hasError: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.text('No disponible'), findsOneWidget);
  });

  testWidgets('elimina solo después de confirmar', (tester) async {
    String? deletedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: RecordsScreen<String>(
          title: 'Personas',
          icon: Icons.person_outline,
          loadRecords: () async => const ApiCollection<String>(
            items: ['Persona de prueba'],
            count: 1,
          ),
          titleFor: (record) => record,
          subtitleFor: (_) => 'Documento',
          canDelete: (_) => true,
          deleteRecord: (record) async {
            deletedRecord = record;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Eliminar registro'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmar eliminación'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(deletedRecord, isNull);

    await tester.tap(find.byTooltip('Eliminar registro'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(deletedRecord, 'Persona de prueba');
  });

  testWidgets('permite reintentar después de un error de carga', (
    tester,
  ) async {
    var attempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: RecordsScreen<String>(
          title: 'Personas',
          icon: Icons.person_outline,
          loadRecords: () async {
            attempts++;
            if (attempts == 1) throw const ApiException('Error de conexión');
            return const ApiCollection<String>(items: ['Persona'], count: 1);
          },
          titleFor: (record) => record,
          subtitleFor: (_) => 'Documento',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar los datos'), findsOneWidget);
    await tester.tap(find.text('Intentar de nuevo'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Persona'), findsOneWidget);
  });

  testWidgets('muestra información ampliada al abrir un registro', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecordsScreen<String>(
          title: 'Personas',
          icon: Icons.person_outline,
          loadRecords: () async => const ApiCollection<String>(
            items: ['Persona de prueba'],
            count: 1,
          ),
          titleFor: (record) => record,
          subtitleFor: (_) => 'Documento',
          detailsFor: (_) => const [
            RecordDetailField('Número de documento', '1001'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.text('Número de documento'), findsOneWidget);
    expect(find.text('1001'), findsOneWidget);
  });

  testWidgets('crea un registro con el formulario y refresca la lista', (
    tester,
  ) async {
    String? createdRecord;
    var loadCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: RecordsScreen<String>(
          title: 'Personas',
          icon: Icons.person_outline,
          loadRecords: () async => ApiCollection<String>(
            items: loadCount++ == 0 ? const ['Persona anterior'] : const [],
            count: 0,
          ),
          titleFor: (record) => record,
          subtitleFor: (_) => 'Documento',
          editorConfig: (_) => const RecordEditorConfig(
            fields: [
              RecordEditorField(
                name: 'pri_nombre',
                label: 'Primer nombre',
                type: RecordEditorFieldType.text,
              ),
            ],
          ),
          createRecord: (values) async {
            createdRecord = values['pri_nombre'] as String?;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar registro'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Persona nueva');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(createdRecord, 'Persona nueva');
    expect(loadCount, 2);
  });

  testWidgets('edita un registro con valores precargados', (tester) async {
    String? updatedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: RecordsScreen<String>(
          title: 'Personas',
          icon: Icons.person_outline,
          loadRecords: () async => const ApiCollection<String>(
            items: ['Persona original'],
            count: 1,
          ),
          titleFor: (record) => record,
          subtitleFor: (_) => 'Documento',
          editorConfig: (record) => RecordEditorConfig(
            fields: const [
              RecordEditorField(
                name: 'pri_nombre',
                label: 'Primer nombre',
                type: RecordEditorFieldType.text,
              ),
            ],
            initialValues: {'pri_nombre': record ?? ''},
          ),
          createRecord: (_) async {},
          updateRecord: (_, values) async {
            updatedRecord = values['pri_nombre'] as String?;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar registro'));
    await tester.pumpAndSettle();
    final nameField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(nameField.controller?.text, 'Persona original');

    await tester.enterText(find.byType(TextFormField), 'Persona editada');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(updatedRecord, 'Persona editada');
  });
}
