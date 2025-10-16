# PRD — WaterTrack: Monitoramento de Hidratação

> **Objetivo**: Documentar os requisitos de produto para o **WaterTrack**, um aplicativo de monitoramento de hidratação com foco em simplicidade, configuração inicial e feedback visual de progresso.

---

## 0) Metadados do Projeto
- **Nome do Produto/Projeto**: WaterTrack — Monitoramento de Hidratação
- **Responsável**: {{Gustavo Finkler Haas}}
- **Curso/Disciplina**: Desenvolvimento de Aplicativos Moveis
- **Versão do PRD**: v1.0
- **Data**: 2025-10-16

---

## 1) Visão Geral
**Resumo**: O WaterTrack ajuda usuários a monitorar e melhorar seus hábitos de hidratação. Na primeira execução, o app guia o usuário por uma configuração rápida de metas e lembretes. A tela principal oferece uma forma simples de registrar o consumo de água, com uma página dedicada a estatísticas para visualizar o histórico de progresso.

**Problemas que ataca**: Desidratação por esquecimento, falta de consciência sobre o consumo diário de água e dificuldade em criar um hábito de hidratação consistente.

**Resultado desejado**: Uma experiência de usuário simples e engajadora que incentiva a hidratação regular através de registro fácil, lembretes e visualização clara do progresso.

---

## 2) Personas & Cenários de Uso
- **Persona principal**: Indivíduo consciente sobre a saúde, que deseja melhorar sua hidratação, mas frequentemente se esquece de beber água durante um dia de trabalho ou estudo corrido.
- **Cenário (happy path)**: Abrir o app → Tela de splash → Onboarding (definir meta e lembretes) → Tela Home → Registrar consumo de água → Checar a página de estatísticas para ver o progresso.
- **Cenários alternativos**:
  - **Usuário recorrente**: Abre o app e é levado diretamente para a tela Home.
  - **Consulta de progresso**: Navega para a tela de estatísticas para visualizar o histórico semanal e mensal.

---

## 3) Identidade do Tema (Design)
### 3.1 Paleta e Direção Visual
- **Primária**: Azul (`#0EA5E9`)
- **Secundária/Sucesso**: Verde (`#10B981`)
- **Fundo**: Azul Escuro (`#0F172A`)
- **Texto**: Branco/Cores claras para contraste com o fundo escuro.
- **Direção**: Tema escuro por padrão (`darkTheme`), com design limpo, alto contraste e foco em elementos visuais como o progresso circular. `useMaterial3` implícito pelo Flutter atual.

### 3.2 Tipografia
- **Títulos**: `headlineMedium` / `titleLarge`
- **Corpo**: `bodyLarge` / `titleMedium`
- **Escalabilidade**: A interface deve suportar o dimensionamento de texto do sistema operacional sem quebrar o layout.

### 3.3 Iconografia
- **Ícones**: `Icons.water_drop`, `Icons.show_chart`, `Icons.refresh`, `Icons.notifications`, `Icons.add`, `Icons.remove`. Estilo Material Design, consistente e de fácil reconhecimento.

### 3.4 Prompts (imagens/ícone)
- **Ícone do app**: “Ícone vetorial de uma gota d'água, estilo flat, fundo transparente. Dentro da gota, um padrão sutil de onda. Paleta de azuis e branco. Bordas limpas, alto contraste, sem texto, 1024×1024.”
- **Ilustração (Hero/Empty State)**: “Ilustração flat minimalista de uma pessoa bebendo um copo de água, com um gráfico de progresso ao fundo. Atmosfera calma, usando a paleta de cores do app, sem texto.”

---

## 4) Jornada de Primeira Execução (Fluxo Base)
### 4.1 Splash
- Exibe a logomarca e o nome do app.
- Decide a rota com base na flag `isFirstRun` do `PrefsService`.

### 4.2 Onboarding (1 tela)
1. **Bem-vindo e Configuração**: Uma única tela para o usuário definir:
    - Meta diária de consumo de água.
    - Horário de início e fim para os lembretes.
    - Intervalo de tempo entre os lembretes.
2. **Ação Principal**: Botão “Começar” que salva as preferências via `PrefsService` e navega para a tela Home.

### 4.3 Tela Home
- Exibe um indicador de progresso circular com a meta diária.
- Permite o registro de consumo via botões com valores pré-definidos (0.2L, 0.3L, 0.5L).
- Permite o registro de consumo via gesto de arrastar no indicador de progresso.
- Botão de atalho para a tela de Estatísticas.

---

## 5) Requisitos Funcionais (RF)
- **RF-1**: A tela de Splash deve decidir a rota (Onboarding ou Home) com base na flag `isFirstRun`.
- **RF-2**: A tela de Onboarding deve salvar a meta diária e as configurações de lembrete no `PrefsService`.
- **RF-3**: A tela Home deve exibir o progresso de consumo com base nos dados do `PrefsService`.
- **RF-4**: A tela Home deve permitir o registro de consumo de água, atualizando os dados no `PrefsService` e `HistoryService`.
- **RF-5**: A tela de Estatísticas deve exibir os registros de hoje e os gráficos semanais/mensais com dados do `HistoryService`.
- **RF-6**: O `NotificationService` deve agendar lembretes locais com base nas preferências do usuário.

---

## 6) Requisitos Não Funcionais (RNF)
- **Acessibilidade (A11Y)**: Áreas de toque com no mínimo 48dp, contraste de cores adequado, uso de `Semantics` para leitores de tela.
- **Arquitetura**: Separação de responsabilidades em **UI → Serviço → Armazenamento**. A UI não deve acessar `SharedPreferences` diretamente, apenas através dos serviços (`PrefsService`, `HistoryService`).
- **Performance**: Animações fluidas (~300ms), especialmente no indicador de progresso, evitando reconstruções de widget desnecessárias.
- **Testabilidade**: Os serviços (`PrefsService`, `HistoryService`, `NotificationService`) devem ser mockáveis para facilitar testes unitários e de widget.

---

## 7) Dados & Persistência (chaves)
- `isFirstRun`: `bool` (Controla a exibição do Onboarding)
- `dailyGoal`: `double` (Meta diária em litros)
- `dailyProgress`: `double` (Progresso atual em litros)
- `firstReminderTime`: `String` (HH:mm)
- `lastReminderTime`: `String` (HH:mm)
- `reminderInterval`: `int` (Intervalo em minutos)
- **HistoryService**: Armazena `WaterRecord` (quantidade e timestamp) de forma persistente (detalhes de implementação abstraídos do UI).

**Serviços**: `PrefsService`, `HistoryService`.

---

## 8) Roteamento
- `/splash` → `SplashPage` (ponto de entrada que decide a rota)
- `/onboarding` → `OnboardingPage`
- `/home` → `HomePage`
- `/stats` → `StatsPage`

---

## 9) Critérios de Aceite
1. A tela de Splash redireciona corretamente para o Onboarding (novo usuário) ou Home (usuário recorrente).
2. As configurações do Onboarding são salvas e refletidas corretamente na Home e nas notificações.
3. O registro de água na Home atualiza o progresso visual e os dados persistidos.
4. A tela de Estatísticas exibe dados históricos precisos.
5. A UI não utiliza `SharedPreferences` diretamente; toda a persistência é feita via serviços.
6. As notificações são agendadas e (potencialmente) recebidas conforme configurado.

---

## 10) Protocolo de QA (testes manuais)
- **Execução limpa**: Instalar o app, completar o onboarding, definir metas e verificar se chega à Home.
- **Registro de consumo**: Na Home, adicionar água e verificar se o progresso atualiza. Ir para Estatísticas e confirmar se o registro aparece.
- **Reabertura do app**: Fechar e abrir o app, confirmar que vai direto para a Home.
- **Verificar estatísticas**: Usar o app por alguns dias e verificar se os gráficos semanal e mensal são preenchidos corretamente.

---

## 11) Riscos & Decisões
- **Risco**: Problemas de fuso horário (timezone) afetando a precisão dos lembretes.
  - **Mitigação**: O código já utiliza os pacotes `timezone` e `flutter_native_timezone` para obter e configurar o fuso horário local, o que é a abordagem correta.
- **Risco**: A interface do usuário ficar acoplada ao armazenamento de dados.
  - **Mitigação**: A arquitetura já utiliza `PrefsService` e `HistoryService`, abstraindo a lógica de persistência da UI.
- **Decisão**: Utilizar um tema escuro (`darkTheme`) por padrão para conforto visual e consistência estética.

---

## 12) Entregáveis
1. Este PRD preenchido.
2. Implementação funcional do fluxo base (Splash, Onboarding, Home, Stats).
3. Evidências (screenshots) das telas principais do aplicativo.

---

## 13) Backlog de Evolução (opcional)
- Criar uma tela de **Configurações** para permitir que o usuário altere a meta e os lembretes após a configuração inicial.
- Adicionar um fluxo de consentimento e política de privacidade (como no exemplo do EduCare).
- Permitir o registro de recipientes com quantidades customizadas (ex: "Minha garrafa de 750ml").
- Implementar backup e sincronização de dados na nuvem.
- Adicionar estatísticas mais avançadas (ex: visão anual, médias de consumo).
