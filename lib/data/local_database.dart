import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/publicacao.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static const _dbName = 'so_na_obra.db';
  static const _dbVersion = 2;
  static const _publicacoesTable = 'publicacoes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_publicacoesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            criado_por_id TEXT NOT NULL,
            criado_por_nome TEXT NOT NULL,
            nome TEXT NOT NULL,
            descricao TEXT NOT NULL,
            preco REAL NOT NULL,
            criado_em TEXT NOT NULL,
            imagens_json TEXT NOT NULL,
            anuncio_logistica TEXT,
            entrega_cep TEXT,
            entrega_valor_por_km REAL,
            aceita_propostas INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $_publicacoesTable ADD COLUMN anuncio_logistica TEXT',
          );
          await db.execute(
            'ALTER TABLE $_publicacoesTable ADD COLUMN entrega_cep TEXT',
          );
          await db.execute(
            'ALTER TABLE $_publicacoesTable ADD COLUMN entrega_valor_por_km REAL',
          );
          await db.execute(
            'ALTER TABLE $_publicacoesTable ADD COLUMN aceita_propostas INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<List<Publicacao>> listarPublicacoes() async {
    final db = await database;
    final rows = await db.query(_publicacoesTable, orderBy: 'id DESC');
    return rows.map(Publicacao.fromDbMap).toList(growable: false);
  }

  Future<Publicacao> inserirPublicacao(Publicacao publicacao) async {
    final db = await database;
    final data = publicacao.toDbMap()..remove('id');
    final id = await db.insert(_publicacoesTable, data);
    return publicacao.copyWith(id: id);
  }
}
