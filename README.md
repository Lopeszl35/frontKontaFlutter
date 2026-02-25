<div align="center">

# ✦ KONTA ✦
### by Nexor

**O seu Cérebro Financeiro Pessoal.** <br>
*Da anotação reativa à inteligência proativa.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](#)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](#)
[![AI-Ready](https://img.shields.io/badge/AI_Ready-8B5CF6?style=for-the-badge&logo=openai&logoColor=white)](#)
[![Proprietary](https://img.shields.io/badge/License-Proprietary-EF4444?style=for-the-badge&logo=law&logoColor=white)](#)

</div>

---

## 📱 Sobre o Projeto

O **Konta** é um agregador e gestor financeiro pessoal de padrão executivo. Projetado para fugir do estigma de planilhas complexas ou aplicativos infantis, o Konta entrega uma experiência *Fintech Premium*. 

**O que o Konta é:** Um hub centralizador de informações. Um Cérebro Financeiro projetado para otimizar o patrimônio do usuário e prever cenários, levando-o de um estado *reativo* (apenas registrar o que já foi gasto) para um estado *proativo* (tomar decisões baseadas em dados).

**O que o Konta não é:** Não somos uma instituição bancária transacional. O aplicativo não guarda o dinheiro, ele **gerencia a inteligência** por trás do dinheiro.

---

## 🧠 A Visão de IA: O Cérebro Financeiro

O verdadeiro núcleo do Konta (em desenvolvimento) é sua **Inteligência Artificial Preditiva e Prescritiva**. O aplicativo está sendo estruturado desde o dia zero para alimentar um motor de IA que atuará como um *Wealth Manager* (Gestor de Patrimônio) de bolso.

* **Análise Comportamental (Passado):** A IA entende os padrões de consumo, identifica gargalos invisíveis e sugere otimizações automáticas de orçamento.
* **Simulação de Impacto (Futuro):** O usuário poderá consultar a IA antes de tomar decisões financeiras. 
  * *Exemplo Prático:* O usuário pergunta: *"Quero comprar um tênis de R$ 1.200 parcelado em 6x. Como isso afeta meu bolso?"*. A IA analisa o fluxo de caixa futuro, os gastos fixos projetados e as faturas abertas, respondendo instantaneamente se a compra manterá a saúde financeira ou se deixará o usuário no vermelho nos próximos meses.

---

## ⚡ Features Principais

O ecossistema do Konta é composto por módulos altamente especializados:

* 📈 **Dashboard Premium:** Visão panorâmica do fluxo de caixa, cards de saldo de alto contraste (Superávit/Déficit), gráficos de distribuição de gastos e física de rolagem nativa (*SliverAppBars*) com **Privacy Mode** (ocultação de valores com um toque).
* 🏠 **Gestão de Financiamentos:** Acompanhamento de contratos de longo prazo (imóveis, veículos), simulação de amortizações e impacto de redução de juros.
* 📅 **Gastos Fixos:** Central de controle de contas recorrentes e assinaturas, categorizadas semanticamente por cores e integradas ao calendário de vencimentos.
* 🤝 **Lembretes de Pagamento:** Gestão inteligente de contas a prazo, fiados e acordos interpessoais (pagamentos via PIX ou dinheiro).
* 💳 **Cartões de Crédito:** Controle granular das faturas, limites e despesas rotativas do dia a dia.

---

## 🏛️ Arquitetura e Padrões (The Nexor Standard)

A robustez da engenharia do Konta não é um capricho, é uma necessidade. Para que a IA preditiva funcione com precisão, evitamos a todo custo o conceito de *"Garbage in, Garbage out"* (Lixo entra, lixo sai). 

Adotamos o **Nexor Standard**:
* **Clean Architecture & SOLID:** Separação estrita de responsabilidades.
* **Tipagem Forte e DTOs:** Nada de variáveis dinâmicas. Os contratos de dados entre Frontend e Backend são blindados, garantindo que a base de dados seja limpa e perfeita para o treinamento e consumo da IA.
* **UI Passiva ("Burra"):** A camada de interface apenas reage. Toda a lógica de negócios, cálculos de fluxo de caixa e formatações habitam os `Controllers` e `Services`.
* **Defensive Programming:** Tratamento extensivo de *Unhappy Paths*, Null Safety rigoroso e uso do `ApiErrorHandler` para feedbacks precisos ao usuário.

---

## 🛠️ Tecnologias Utilizadas

| Camada | Tecnologia / Padrão |
| :--- | :--- |
| **Mobile (Frontend)** | Flutter, Dart |
| **State Management** | Provider |
| **Backend (API)** | Node.js, Express |
| **Segurança & Validação** | Express-Validator, JWT |
| **Design System** | Material 3 / iOS Design (Glassmorphism, Squircles, Neon Accents, Haptic Feedback) |

---

## 🖼️ Previews da Interface

<p align="center">
  <i>O design adota o estilo "Dark Tech", focado em usabilidade noturna, alto contraste e elementos neon.</i>
</p>

<table align="center">
  <tr>
    <td align="center"><b>Dashboard (Privacy Mode)</b></td>
    <td align="center"><b>Gastos Fixos</b></td>
    <td align="center"><b>Financiamentos</b></td>
  </tr>
  <tr>
    <td><img src="https://via.placeholder.com/250x500/1A1D27/6C63FF?text=Dashboard+Preview" alt="Dashboard" width="250"/></td>
    <td><img src="https://via.placeholder.com/250x500/1A1D27/10B981?text=Gastos+Fixos+Preview" alt="Gastos Fixos" width="250"/></td>
    <td><img src="https://via.placeholder.com/250x500/1A1D27/F59E0B?text=Financiamentos+Preview" alt="Financiamentos" width="250"/></td>
  </tr>
</table>

*(Nota: Substituir as imagens de placeholder pelos screenshots reais do aplicativo).*

---

## 🔒 Licença e Propriedade

**Copyright © 2026 Nexor. Todos os direitos reservados.**

Este é um software **PROPRIETÁRIO** e de código fechado (*Closed Source*). 
O código-fonte, design, arquitetura e lógicas de negócios aqui presentes pertencem exclusivamente à **Nexor** e de seu proprietário Rafael Amaro Lopes. É estritamente proibida a cópia, modificação, distribuição, licenciamento ou uso comercial de qualquer parte deste repositório sem a autorização prévia e expressa por escrito.
