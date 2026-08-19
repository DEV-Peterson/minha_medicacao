import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Centraliza todos os caminhos privados usados pelo aplicativo.
class AppPaths {
  const AppPaths._();

  static Future<Directory> raiz() async {
    final documents = await getApplicationDocumentsDirectory();
    return documents..createSync(recursive: true);
  }

  static Future<Directory> banco() async {
    final root = await raiz();
    return Directory(p.join(root.path, 'banco'))..createSync(recursive: true);
  }

  static Future<File> arquivoBanco() async {
    final directory = await banco();
    return File(p.join(directory.path, 'minha_medicacao.sqlite'));
  }

  static Future<Directory> anexos() async {
    final root = await raiz();
    return Directory(p.join(root.path, 'anexos'))..createSync(recursive: true);
  }

  static Future<Directory> fotosMedicamentos() async {
    final directory = await anexos();
    return Directory(p.join(directory.path, 'medicamentos'))
      ..createSync(recursive: true);
  }

  static Future<Directory> receitas() async {
    final directory = await anexos();
    return Directory(p.join(directory.path, 'receitas'))
      ..createSync(recursive: true);
  }

  static Future<Directory> backups() async {
    final root = await raiz();
    return Directory(p.join(root.path, 'backups'))..createSync(recursive: true);
  }

  static Future<Directory> temporarios() async {
    final root = await getTemporaryDirectory();
    return Directory(p.join(root.path, 'minha_medicacao'))
      ..createSync(recursive: true);
  }
}
