# 📊 README do PhoneDex

## 📌 Sobre o Projeto

Este projeto é um aplicativo de catálogo de celulares, a "PhoneDex", desenvolvido em Flutter para a disciplina de Desenvolvimento de Sistemas de Informação (DSI) da Universidade Federal Rural de Pernambuco. Ele permite que usuários visualizem, adicionem, comparem e avaliem diferentes modelos de smartphones.

## 🚀 Tecnologias Utilizadas

- **Flutter**
- **Dart**
- **Firebase** (Auth, Firestore, Storage)
- **Geoapify API** (para o mapa de lojas)

Outras tecnologias relevantes:

- **Provider**
- **Geolocator**
- **Image Picker**
- **Flutter Map**

## 🎯 Funcionalidades

- 🧑‍🤝‍🧑 **Autenticação e Perfis de Usuário:** Sistema completo de login, cadastro e gerenciamento de perfil com foto.
- 📱 **Catálogo de Celulares:** Visualize uma grade de celulares com busca e filtros por sistema operacional (iOS/Android).
- ⭐ **Favoritos e Comparações:** Adicione celulares aos favoritos e compare as especificações de dois modelos lado a lado.
- ➕ **Contribuição da Comunidade:** Usuários podem adicionar novos celulares, que passam por uma fila de aprovação de um administrador.
- ✍️ **Feed de Reviews:** Uma área social onde usuários podem postar avaliações e comentários sobre os celulares.
- 🗺️ **Mapa de Lojas:** Encontre lojas de eletrônicos próximas à sua localização atual.
- 🔐 **Painel de Administrador:** Admins podem aprovar ou rejeitar os celulares pendentes enviados pela comunidade.

## Passos para instalação

1.  Clone o repositório:
    ```bash
    git clone [https://github.com/ian-veiga/phonedex.git](https://github.com/ian-veiga/phonedex.git)
    ```

2.  Acesse o diretório do projeto:
    ```bash
    cd phonedex
    ```

3.  Instale as dependências do Flutter:
    ```bash
    flutter pub get
    ```

4.  Configure seu próprio projeto no Firebase e adicione os arquivos de configuração (`google-services.json` para Android e configure o `firebase_options.dart`).

5.  Adicione sua chave da API do Geoapify no arquivo `lib/services/geoapify_service.dart`.
    ```dart
    // lib/services/geoapify_service.dart
    final GeoapifyService _geoapifyService = GeoapifyService('SUA_CHAVE_DE_API_AQUI');
    ```

6.  Execute o projeto:
    ```bash
    flutter run
    ```