## 🤖 Desafio Chatbot – Bot Agibank (Salesforce)

### Visão Geral
Este repositório implementa o desafio técnico de um chatbot para uma empresa de e-commerce e serviços, utilizando Salesforce (Einstein Bots, Apex, Flows e Embedded Messaging). O bot interage com clientes, toma decisões, integra-se a um banco de dados (Salesforce) e APIs externas, e registra etapas-chave da jornada.

## Como testar como usuário final
basta acessar a URL: https://orgfarm-3d6edf8a1d-dev-ed--c.develop.vf.force.com/apex/chatbot, e abrir o bot no canto direito inferior da tela.

## Testar como usuário interno fazendo o papel de atendente
- Acesse a URL: https://orgfarm-3d6edf8a1d-dev-ed.develop.lightning.force.com/
- username: user.agent@gmail.com.orgfarm-3d6edf8a1d
- senha: agentuser12345
Após isso, basta mudar o próprio status para "Online" na tab "Omni-Channel" que fica na barra inferior da página.
Com o status Online, o usuário pode atender chamados dos usuários finais.

## Endpoint
Mais abaixo é dado no endpoint e os dados que contém nele para teste.
- Endpoint: https://mocki.io/v1/8c76ff9b-3136-47ba-a939-ce4c4fca41be
- JSON contido na URL:
```json
[
  {
    "orderNumber": "12345",
    "status": "Pedido enviado",
    "deliveryDate": "15/08/2025",
    "customerId": "1345abcd-1234-5678-90abcdef1234",
    "customerName": "João Silva"
  },
  {
    "orderNumber": "56789",
    "status": "Pedido entregue",
    "deliveryDate": "08/08/2025",
    "customerId": "5678abcd-1234-5678-90abcdef5678",
    "customerName": "Maria Silva"
  },
  {
    "orderNumber": "09876",
    "status": "Em rota de entrega",
    "deliveryDate": "16/08/2025",
    "customerId": "0987abcd-1234-5678-90abcdef0987",
    "customerName": "José Sousa"
  }
]
```
### Objetivos do Desafio (Resumo)
- **Rastreamento de Pedido**: solicitar número do pedido, consultar API externa de logística e retornar status.
- **Suporte Técnico**: coletar detalhes, abrir Case, retornar protocolo e escalar para humano quando necessário.
- **Política de Devolução**: informar requisitos e, se aplicável, iniciar processo criando registro no Salesforce.
- **Contratação de Serviço**: apresentar opções, verificar elegibilidade/custos, gerar orçamento ou agendar contato.

---

## 🏗️ Como este projeto atende ao desafio

### Jornadas implementadas e onde encontrar
- **Rastreamento de Pedido**
  - Apex Service: `classes/OrderTrackingService.cls`
  - API externa (mock via Named Credential): `classes/OrdersApiClient.cls`
  - Controller/Tests: `classes/OrderTrackingController.cls`, `classes/OrderTrackingControllerTest.cls`
  - Repositórios/Factories: `AccountRepository`, `OrderRepository`, `ContractRepository`, `AccountFactory`, `OrderFactory`, `ContractFactory`

- **Suporte Técnico**
  - Flow: `flows/CreateCaseForSupport.flow-meta.xml` (criação de `Case` + roteamento)
  - Fallback para agente humano via bot/queue quando necessário

- **Política de Devolução**
  - Flows: `flows/CheckIfReturnIsAvailable.flow-meta.xml`, `flows/CreateReturnOrderRegisterByBot.flow-meta.xml`
  - Persistência de registros relacionados a devolução no Salesforce

- **Contratação de Serviço (Nova Jornada)**
  - Catálogo e dados: Objeto custom `objects/Service__c`
  - Disponibilidade: `classes/ServiceScheduleAvailability.cls`
  - Flows: `flows/GetAllServicesAndProducts.flow-meta.xml`, `flows/ScheduleServiceRequestEvent.flow-meta.xml`

- **Roteamento / Decisão**
  - Bot e outbound default: `bots/Agibank_bot/Agibank_bot.bot-meta.xml`, `flows/RouteToBotQueue.flow-meta.xml`, `flows/Route_to_Agibank_bot.flow-meta.xml`

- **Interface de Chat (Embedded Messaging)**
  - Página Visualforce para testes: `pages/chatbot.page` → acessar via `/apex/chatbot`

### Requisitos Técnicos do Desafio (atendidos)
- **Salesforce (Apex + Flow)**: Lógica de negócio em Apex e múltiplos Flows declarativos.
- **Consulta e escrita**: Uso de objetos padrão (`Account`, `Order`, `Case`) e custom (`Service__c`).
- **Integração com API Externa**: `OrdersApiClient` com Named Credential (mock).
- **Registro e Rastreamento**: Casos e sessões de mensageria servem como trilha; seção abaixo descreve opção de log custom.
- **Boas práticas**: Camadas (Controller → Service → Repository/Factory), testes de unidade e design orientado a padrões.

---

## 🧩 Arquitetura e Padrões
- **Camadas**
  - Controller: `OrderTrackingController`
  - Service: `OrderTrackingService`, `ServiceScheduleAvailability`
  - Repository: `AccountRepository`, `OrderRepository`, `ContractRepository`
  - Factory: `AccountFactory`, `OrderFactory`, `ContractFactory`
- **Padrões**
  - Factory: criação de registros padronizada
  - Repository: acesso a dados desacoplado
  - Strategy (conceito aplicado): serviços especializados para jornadas distintas (ex.: disponibilidade/agenda)
- **Bots/Flows**: Decisão e orquestração de jornadas via Einstein Bot + Flows

---

## 🔌 Integrações (Mock/API Externa)

### API Externa de Pedidos (Mock)
- O cliente HTTP usa Named Credential `OrdersAPI` (ver seção de Setup).
- Endpoint exemplo esperado (no Named Credential): `https://mocki.io/v1/8c76ff9b-3136-47ba-a939-ce4c4fca41be`
- Resposta JSON esperada (exemplo encontrado no endpoint):
```json
[
  {
    "orderNumber": "12345",
    "status": "Pedido enviado",
    "deliveryDate": "15/08/2025",
    "customerId": "1345abcd-1234-5678-90abcdef1234",
    "customerName": "João Silva"
  },
  {
    "orderNumber": "56789",
    "status": "Pedido entregue",
    "deliveryDate": "08/08/2025",
    "customerId": "5678abcd-1234-5678-90abcdef5678",
    "customerName": "Maria Silva"
  },
  {
    "orderNumber": "09876",
    "status": "Em rota de entrega",
    "deliveryDate": "16/08/2025",
    "customerId": "0987abcd-1234-5678-90abcdef0987",
    "customerName": "José Sousa"
  }
]
```
- Outras ferramentas de mock sugeridas: `json-server`, `Mockoon`, `Beeceptor`, `mockapi.io`.


---

## 📝 Registro e Rastreamento
- Por padrão, a solução utiliza registros do Salesforce como trilha:
  - `Case` (para suporte técnico)
  - `Order` e relações (para rastreamento de pedidos)
  - `MessagingSession` (contexto de sessão do bot)

---

## ⚙️ Instalação e Configuração

### Pré-requisitos
- Salesforce CLI instalado
- Org de desenvolvimento, Scratch Org ou Playground
- Permissões para criar Named Credentials

### Deploy do código
```bash
# Clone o repositório
git clone <URL_DO_REPOSITORIO>
cd dev-edition-bot

# Deploy (source)
sfdx force:source:deploy -p force-app/main/default
```

### Named Credential para a API de Pedidos
1. Setup → Security → Named Credentials → New
2. Name: `OrdersAPI`
3. URL: `https://SEU_ENDPOINT` (host do mock)
4. Tipo: HTTP – sem autenticação (para mock)
5. Salvar
6. Garanta que o caminho `/v1/8c76ff9b-3136-47ba-a939-ce4c4fca41be` devolva o JSON de exemplo acima

### Ativar o Bot e a Interface de Chat
- Einstein Bot: publique o bot `Agibank bot` se necessário
- Embedded Messaging: ajuste IDs/URLs em `pages/chatbot.page` conforme sua org/site
- Acesse `/apex/chatbot` para abrir a interface de chat

### Permissões
- Se existir Permission Set específico, atribua-o ao usuário de testes
```bash
sfdx force:user:permset:assign -n <NOME_DO_PERMISSION_SET>
```

---

## 🧪 Testes e Cobertura
- Testes incluídos:
  - `OrderTrackingControllerTest`
  - `ServiceScheduleAvailabilityTest`
- Executar testes:
```bash
sfdx force:apex:test:run -n OrderTrackingControllerTest,ServiceScheduleAvailabilityTest -r human -w 10
```
- Dica: use `sfdx force:apex:test:report -i <TEST_RUN_ID>` para relatório detalhado. A meta do desafio é **≥ 85%** de cobertura agregada.

---

## 🧭 Como Exercitar as Jornadas
- **Rastreamento de Pedido**: No chat, solicite “Rastrear pedido”, informe um número existente no mock (ex.: `12345`).
- **Suporte Técnico**: “Tenho um problema” → bot coleta detalhes → `Case` criado com protocolo.
- **Política de Devolução**: “Quero devolver” → bot explica critérios → Flow cria registro se aplicável.
- **Contratar Serviço**: “Quero contratar um serviço” → bot lista opções (`Service__c`) → verifica disponibilidade/custos → agenda/gera orçamento.

---

# (Opcional) carregar dados de exemplo em Service__c via Data Import Wizard ou sfdx data
```
- Compartilhar usuário de teste: criar usuário padrão e enviar credenciais temporárias (ou habilitar Guest no site do Embedded Messaging, se aplicável).

---

## 📚 Documentação (Diferencial)
- **Arquitetura**: camadas, bot + flows, Named Credential e integrações
- **Padrões aplicados**: Repository, Factory e services especializados por jornada
- **Pontos de melhoria**:
  - Feature flags para ativar/desativar integrações

---

## 👥 Equipe e Contatos
- Desenvolvedor: Daniel Tavares Souza
- Organização: Agibank (projeto demonstrativo)
- Plataforma: Salesforce

---

