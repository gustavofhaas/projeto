# Fluxo de Tarefas do Aplicativo WaterTrack

Este documento descreve o fluxo de usuário e as principais funcionalidades do aplicativo WaterTrack.

## 1. Inicialização do Aplicativo

- **Tela de Splash:** Ao iniciar o aplicativo, uma tela de splash é exibida por 2 segundos.
- **Verificação de Primeiro Uso:** O aplicativo verifica se é a primeira vez que o usuário o está abrindo.
  - **Novo Usuário:** Se for o primeiro uso, o usuário é redirecionado para a tela de Onboarding.
  - **Usuário Recorrente:** Se não for o primeiro uso, o usuário é levado diretamente para a tela Principal (Home).

## 2. Onboarding (Configuração Inicial)

Esta tela é exibida apenas para novos usuários. O objetivo é configurar as preferências iniciais.

- **Formulário de Configuração:** O usuário preenche um formulário para definir:
  - **Meta Diária de Água:** A quantidade de água que o usuário pretende beber por dia (em litros).
  - **Horário dos Lembretes:** O período do dia em que os lembretes de notificação devem ser enviados (horário de início e fim).
  - **Intervalo dos Lembretes:** A frequência com que as notificações de lembrete serão enviadas.
- **Salvar Preferências:** Ao salvar, as configurações são armazenadas no dispositivo e o usuário é redirecionado para a tela Principal.

## 3. Tela Principal (Home)

Esta é a tela principal de interação do aplicativo.

- **Visualização do Progresso:** Um indicador circular mostra o progresso atual do consumo de água em relação à meta diária.
- **Registro de Consumo:** O usuário pode registrar o consumo de água de duas maneiras:
  - **Botões de Acesso Rápido:** Adicionar quantidades pré-definidas (ex: 0.2L, 0.3L, 0.5L).
  - **Gesto de Arrastar:** Ajustar a quantidade de água arrastando o indicador circular.
- **Navegação:**
  - Um botão na barra de aplicativos permite navegar para a tela de **Estatísticas**.
- **Notificações:** O sistema de notificações é ativado para enviar lembretes periódicos com base nas configurações do onboarding.

## 4. Tela de Estatísticas

Esta tela exibe o histórico de consumo de água do usuário.

- **Resumo do Dia:** Mostra o total de água consumida no dia atual e uma lista com os horários e quantidades de cada registro.
- **Gráficos Históricos:**
  - **Gráfico Semanal:** Um gráfico de barras exibe o consumo total de cada dia nos últimos 7 dias.
  - **Gráfico Mensal:** Um gráfico de barras exibe o consumo total de cada dia no último mês.
- **Atualização:** Um botão permite recarregar os dados das estatísticas.

## 5. Serviços em Segundo Plano

- **`PrefsService`:** Gerencia o armazenamento local de todas as preferências do usuário (meta, horários, etc.).
- **`HistoryService`:** Armazena e recupera o histórico de consumo de água para a tela de estatísticas.
- **`NotificationService`:** Gerencia o agendamento e o envio de notificações locais para lembrar o usuário de beber água.
