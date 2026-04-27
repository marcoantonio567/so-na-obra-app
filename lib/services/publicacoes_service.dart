import '../data/local_database.dart';
import '../data/seed/publicacoes_seed.dart';
import '../models/publicacao.dart';

class PublicacoesService {
  const PublicacoesService();

  Future<List<Publicacao>> _listarPublicacoesComTimeout() {
    return LocalDatabase.instance
        .listarPublicacoes()
        .timeout(const Duration(seconds: 1));
  }

  bool _temPublicacoesSeed(List<Publicacao> lista) {
    return lista.any((p) => p.criadoPorId == seedUserId);
  }

  bool _temPublicacoesDoUsuario(List<Publicacao> lista, String userId) {
    return lista.any((p) => p.criadoPorId == userId);
  }

  bool _temAnuncioSeedComImagem(List<Publicacao> lista) {
    return lista.any(
      (p) =>
          p.criadoPorId == seedUserId &&
          p.tipo == PublicacaoTipo.anuncio &&
          p.imagens.isNotEmpty,
    );
  }

  Future<List<Publicacao>> carregar({
    required String userId,
    required String userName,
  }) async {
    var lista = await _listarPublicacoesComTimeout();
    if (!_temPublicacoesSeed(lista)) {
      await inserirPublicacoesFicticias(LocalDatabase.instance);
      lista = await _listarPublicacoesComTimeout();
    }

    if (!_temAnuncioSeedComImagem(lista)) {
      await inserirAnunciosFicticiosComImagens(LocalDatabase.instance);
      lista = await _listarPublicacoesComTimeout();
    }

    if (!_temPublicacoesDoUsuario(lista, userId)) {
      await inserirPublicacoesFicticiasDoUsuario(
        database: LocalDatabase.instance,
        userId: userId,
        userName: userName,
      );
      lista = await _listarPublicacoesComTimeout();
    }

    return lista;
  }

  Future<void> salvar(Publicacao publicacao) {
    return LocalDatabase.instance.inserirPublicacao(publicacao);
  }
}
