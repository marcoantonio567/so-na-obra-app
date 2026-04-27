# Só na Obra

Aplicativo Flutter (mobile/desktop/web) com foco em anúncios e solicitações, com persistência local via SQLite.

## Funcionalidades

- Login e cadastro (fluxo local para demonstração)
- Navegação por abas: Solicitações, Home (Anúncios), Criar, Carteira, Perfil
- Criação de anúncios e solicitações
- Upload de múltiplas imagens para anúncios (galeria)
- Busca por texto e filtro por período (hoje / últimos 7 / últimos 30 dias)
- Persistência local com `sqflite` e dados seed automáticos na primeira execução

## Tecnologias

- Flutter / Dart
- `sqflite` + `path` (banco local)
- `image_picker` (seleção de imagens)

## Como rodar

Pré-requisitos:

- Flutter instalado e configurado no PATH
- Dart compatível (o projeto usa SDK `^3.11.5`)

Comandos:

```bash
flutter pub get
flutter run
```

## Como usar (demo)

- Na tela de Login, informe qualquer nome e uma senha com pelo menos 4 caracteres
- Após entrar, use a aba Criar para publicar um anúncio (com imagens) ou uma solicitação
- A aba Perfil permite alterar nome e foto (local)

## Estrutura do projeto

- `lib/app.dart`: configuração do app e rota inicial
- `lib/screens/`: telas (login, navegação principal, anúncios, solicitações, criar, perfil, etc.)
- `lib/models/`: modelos (ex.: `Publicacao`)
- `lib/data/`: banco local (`LocalDatabase`) e seeds
- `lib/services/`: regras de carregamento/salvamento de publicações
- `lib/widgets/`: componentes reutilizáveis (ex.: card de publicação)

## Testes e análise

```bash
flutter test
flutter analyze
```
