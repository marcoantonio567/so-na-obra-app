# Só na Obra

Aplicativo Flutter com foco em anúncios e solicitações, com persistência local via SQLite (`sqflite`).

## Funcionalidades

- Login e cadastro (fluxo local para demonstração)
- Navegação por abas: Solicitações, Home (Anúncios), Criar, Carteira, Perfil
- Criação de anúncios e solicitações
- Upload de múltiplas imagens para anúncios (galeria)
- Busca por texto e filtro por período (hoje / últimos 7 / últimos 30 dias)
- Carteira (saldo, histórico de compras e confirmação de recebimento via PIN)
- Perfil (troca de nome e foto, geração/copiar PIN de recebimento)
- Persistência local (SQLite) e seeds automáticos na primeira execução

## Tecnologias

- Flutter / Dart
- `sqflite` + `path` (banco local)
- `image_picker` (seleção de imagens)
- `shared_preferences` (preferências simples, ex.: PIN no web)

## Como rodar

Pré-requisitos:

- Flutter instalado e configurado no PATH
- SDK do Dart compatível (o projeto usa `sdk: ^3.11.5`)

Comandos:

```bash
flutter pub get
flutter run
```

Dicas de dispositivos:

```bash
flutter devices
flutter run -d chrome
flutter run -d windows
```

## Como usar (demo)

- Na tela de Login, informe qualquer nome e uma senha com pelo menos 4 caracteres
- Após entrar, use a aba Criar para publicar um anúncio (com imagens) ou uma solicitação
- A aba Perfil permite alterar nome e foto (local)

## Dados e persistência

- Banco local: `so_na_obra.db` (SQLite via `sqflite`)
- Tabelas principais:
  - `publicacoes`: anúncios e solicitações
  - `user_settings`: configurações por usuário (ex.: `pin_recebimento`)
- Seeds: na primeira execução, o app popula publicações fictícias automaticamente (incluindo exemplos com imagens).

## Estrutura do projeto

- `lib/app.dart`: configuração do app e rota inicial
- `lib/screens/`: telas (login, navegação principal, anúncios, solicitações, criar, perfil, etc.)
- `lib/models/`: modelos (ex.: `Publicacao`)
- `lib/data/`: banco local (`LocalDatabase`) e seeds
- `lib/services/`: regras de carregamento/salvamento de publicações
- `lib/widgets/`: componentes reutilizáveis (ex.: card de publicação)

## Observações

- Web: `sqflite` não é suportado no navegador; algumas funcionalidades de persistência podem não funcionar corretamente em `-d chrome`.

## Testes e análise

```bash
flutter test
flutter analyze
```
