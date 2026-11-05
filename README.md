# AlugaTudo — Plataforma Completa de Aluguel P2P (Full Stack)

Plataforma completa de economia compartilhada peer-to-peer **AlugaTudo**, fielmente reproduzida a partir da especificação do design Stitch com retenção de caução em custódia (**Escrow**), autenticação, vistoria fotográfica e validação de entrega via **PIN de 6 dígitos**.

A aplicação é **100% funcional e utilizável**, contando com portal web integrado no backend, API RESTful em arquitetura MVC, banco de dados relacional SQLite com persistência real e aplicativo cliente Flutter.

---

## 🚀 Tecnologias Utilizadas

### Backend & API REST
- **Node.js (v24+) & Express 4.x** (Arquitetura MVC desacoplada)
- **SQLite (sql.js / better-sqlite3)** com persistência e chaves estrangeiras
- **Bcryptjs & JWT (JSON Web Tokens)** para autenticação segura e hashing de senhas
- **CORS, Dotenv e tratamento centralizado de exceções**

### Frontend Web (Portal Integrado)
- **HTML5 semântico & CSS3 com Design Tokens Stitch** (Google Fonts *Inter*, tons Forest Green `#006C49`, `#10B981`, `#FAF8FF`)
- **JavaScript Moderno ES6+** com consumo reativo da API REST
- **FontAwesome 6.5** para iconografia oficial (Escudos de proteção, status de vistoria, filtros)

### Mobile & Multiplataforma (Flutter)
- **Flutter 3.x / Dart 3.x** (Material Design 3)
- **Provider** (`ChangeNotifier` para gerenciamento de estado)
- **Http Client** (`api_service.dart`) conectado aos endpoints REST locais

---

## 📱 Telas e Funcionalidades 100% Operacionais

1. **M-01: Explorar & Catálogo (`/` & `explore_view.dart`)**
   - Busca preditiva em tempo real por título, descrição ou tags
   - Filtro de categorias por chips (Todas, Ferramentas, Câmeras & Tech, Festas, Esportes)
   - Filtro dinâmico por raio geográfico (1 km até 25 km)
   - Alternância entre visualização em Grade (3 colunas) e Lista
   - Cards com selo oficial de **Caução Garantida**, distância estimada e botão de favoritar

2. **M-02: Detalhes do Item & Caução (`detailModal` & `item_detail_view.dart`)**
   - Galeria de imagens do equipamento
   - **Card de Transparência Financeira**: Diária + Valor da Caução retida em custódia Escrow
   - **Seletor de Período Reativo**: cálculo instantâneo de diárias, desconto de 15% para 3+ dias, taxa de serviço da plataforma (10%) e valor total
   - Perfil do locador com selo de verificação de identidade (KYC), reputação e localização

3. **M-03: Checkout & Bloqueio Caução (`checkoutModal` & `checkout_view.dart`)**
   - Resumo do pedido e opções de logística (Retirada grátis, Entrega pelo dono R$ 25, Courier R$ 35)
   - Métodos de pagamento: **Cartão de Crédito** (com validação) e **PIX Instantâneo** (com chave Copia e Cola)
   - Geração imediata de reserva no banco de dados com **PIN de entrega exclusivo de 6 dígitos**

4. **M-04: Chat & Gestão da Reserva / Entrega (`chatModal` & `chat_view.dart`)**
   - Banner de acompanhamento de status: `SOLICITADO`, `PAGO & CONFIRMADO`, `EM CURSO`, `FINALIZADO`
   - **Validação de PIN de Entrega**: modal para conferência física do código no momento da retirada, transicionando a reserva para `EM CURSO`
   - **Vistoria Fotográfica**: checklist e registro de fotos de conformidade pré e pós-locação
   - **Chat em Tempo Real**: troca de mensagens entre locatário e proprietário com respostas automatizadas de apoio

5. **M-05: Meus Aluguéis (`rentalsList` & `rentals_view.dart`)**
   - Histórico e acompanhamento de todas as locações ativas e finalizadas

6. **M-06: Anunciar Novo Item (`postItemModal` & `post_item_view.dart`)**
   - Formulário completo com validação para inclusão de novos equipamentos no catálogo

7. **M-07: Perfil & Validação de Identidade KYC (`sectionProfile` & `profile_view.dart`)**
   - Status da verificação documental (RG/CNH), reputação, total de locações e alternador de persona demo

---

## 🏗️ Estrutura de Diretórios (MVC)

```text
alugatudo_app/
├── backend/
│   ├── config/
│   │   └── env.js                   # Carregamento e validação de variáveis de ambiente
│   ├── controllers/
│   │   ├── authController.js        # Cadastro, login, perfil e KYC
│   │   ├── itemController.js        # Catálogo, busca, criação e favoritos
│   │   ├── rentalController.js      # Reservas, cálculo financeiro e PINs
│   │   └── chatController.js        # Mensagens e vistoria fotográfica
│   ├── database/
│   │   ├── alugatudo.sqlite         # Banco de dados relacional persistente
│   │   ├── db.js                    # Conexão SQLite (sql.js / better-sqlite3)
│   │   ├── schema.sql               # Estrutura DDL das tabelas
│   │   └── seed.js                  # Povoamento inicial com itens do Stitch
│   ├── middlewares/
│   │   ├── authMiddleware.js        # Validação de token JWT e sessão
│   │   └── errorHandler.js          # Tratamento centralizado de erros REST
│   ├── models/
│   │   ├── User.js                  # Modelo de usuários e reputação
│   │   ├── Item.js                  # Modelo de equipamentos
│   │   ├── Rental.js                # Modelo de locação e custódia escrow
│   │   └── Chat.js                  # Modelo de mensagens e vistorias
│   ├── public/                      # Portal Web 100% Funcional (Site)
│   │   ├── css/styles.css           # Estilos e tokens de design do Stitch
│   │   ├── js/app.js                # Lógica do cliente e consumo da API
│   │   └── index.html               # Aplicação SPA completa
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── itemRoutes.js
│   │   ├── rentalRoutes.js
│   │   ├── chatRoutes.js
│   │   └── index.js
│   ├── services/
│   │   ├── authService.js
│   │   ├── itemService.js
│   │   ├── rentalService.js
│   │   └── chatService.js
│   ├── .env                         # Configurações do ambiente
│   ├── .env.example
│   ├── package.json
│   └── server.js                    # Ponto de entrada do servidor Node.js
├── lib/                             # Aplicativo Flutter Cliente
│   ├── controllers/
│   ├── models/
│   ├── services/
│   │   └── api_service.dart         # Integração com a API REST local
│   ├── theme/
│   ├── views/
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 💻 Como Executar

### 1. Iniciar o Servidor Full Stack & Portal Web
```bash
# Entrar no diretório do backend
cd C:\Users\2devsesi\Documents\alugatudo_app\backend

# Instalar dependências (caso ainda não tenham sido instaladas)
npm install

# Iniciar o servidor
npm start
```
Após iniciar, acesse imediatamente no seu navegador:
- **Portal Web (Site 100% Funcional):** `http://localhost:3000`
- **Documentação / Healthcheck da API:** `http://localhost:3000/api/v1/health`

### 2. Executar o Aplicativo Flutter (Opcional)
```bash
# Entrar no diretório raiz do Flutter
cd C:\Users\2devsesi\Documents\alugatudo_app

# Baixar dependências
flutter pub get

# Executar no Chrome (Web)
flutter run -d chrome

# Ou executar nativamente no Windows Desktop
flutter run -d windows
```

---

## 🔑 Credenciais e Personas Demo (Ambiente Local)

| Nome | Email | Senha | Papel |
| :--- | :--- | :--- | :--- |
| **Vinicius Pini** | `vinicius.pini@email.com` | `123456` | Locatário (com reservas ativas) |
| **Lucas Mendes** | `lucas.mendes@email.com` | `123456` | Locador / Proprietário de Câmeras |
| **Carla Souza** | `carla.souza@email.com` | `123456` | Locadora de Ferramentas DeWalt |

---

## 🔒 Regras de Negócio e Segurança Implementadas

- **Caução (Custódia Escrow):** O valor da caução permanece congelado em garantia durante todo o aluguel e é estornado automaticamente após a confirmação da vistoria e devolução.
- **Validação com PIN de 6 Dígitos:** Previne fraudes físicas exigindo que o anfitrião e o locatário confirmem o código PIN no ato da entrega para ativar o status `EM CURSO`.
- **Validação de Identidade (KYC):** Locatários e locadores validam documentos oficiais antes de concluir aluguéis com retenção de caução.
- **Senhas Criptografadas:** Utilização de `bcryptjs` com salt rounds para armazenamento seguro no banco de dados.
