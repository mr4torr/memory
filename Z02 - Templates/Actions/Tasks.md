<%*
// 1. CONFIGURAÇÕES
const folder = "A01 - Tasks/02 - InProgress";
const datePrefix = tp.date.now("YYYY-MM-DD");
const currentMonth = tp.date.now("YYYY-MM");
const dailyFolder = `B01 - Daily Notes/${currentMonth}`;
const dailyFilePath = `${dailyFolder}/${datePrefix}`;
const dailyTemplatePath = "Z02 - Templates/Calendars/Daily Notes.md";

// 2. PROMPT E EXTRAÇÃO
let rawInput = await tp.system.prompt("Tarefa (Ex: Titulo da tarefa FRPHP-1234 @01/12/2026 !High $Open #api FRPHP-9999)", "");
if (!rawInput) rawInput = "nova-tarefa";

let scheduledDate = tp.date.now("YYYY-MM-DD");
let taskPriority = "normal";
let taskStatus = "in-progress";
let customTags = [];

// Extrai a data ISO
rawInput = rawInput.replace(/@(\d{4}-\d{2}-\d{2})(?=\s|$)/g, (match, p1) => {
    scheduledDate = p1;
    return "";
});

const now = new Date();
const currentYear = now.getFullYear().toString();
const fallbackMonth = String(now.getMonth() + 1).padStart(2, '0');

// Extrai a data BR flexível
rawInput = rawInput.replace(/@(\d{2})(?:\/(\d{2}))?(?:\/(\d{4}))?(?=\s|$)/g, (match, day, month, year) => {
    let finalYear = year || currentYear;
    let finalMonth = month || fallbackMonth;
    let finalDay = day;
    scheduledDate = `${finalYear}-${finalMonth}-${finalDay}`;
    return "";
});

// Extrai a prioridade
rawInput = rawInput.replace(/!([A-Za-z]+)(?=\s|$)/g, (match, p1) => {
    taskPriority = p1;
    return "";
});

// Extrai as tags nativas
rawInput = rawInput.replace(/#([\w-]+)(?=\s|$)/g, (match, p1) => {
    customTags.push(p1);
    return "";
});

// Extrai o Status
rawInput = rawInput.replace(/\$([A-Za-z]+)(?=\s|$)/g, (match, p1) => {
    taskStatus = p1;
    return "";
});

// --- NOVA LÓGICA DE TAREFAS (Independente de posição e múltiplas ocorrências) ---
let taskNumber = '';
let contexts = [];

// Padrão abrangente: Pega Letras Maiúsculas, hífen, e números (Ex: PROJ-12)
rawInput = rawInput.replace(/[a-zA-Z]+-\d+/g, (match) => {
	let matchMaiusculo = match.toUpperCase();
	if (taskNumber === '') {
        taskNumber = matchMaiusculo; // O primeiro que encontrar vira a tarefa principal
        customTags.push(matchMaiusculo)
        contexts.push(matchMaiusculo)
    } else {
        // Verifica se a tag já não existe para evitar duplicatas
        if (!customTags.includes(matchMaiusculo)) {
            customTags.push(matchMaiusculo); // Os seguintes viram tags
            contexts.push(matchMaiusculo)
        }
    }
    return ""; // Remove o código da tarefa da string
});

// 5. FORMATAÇÃO DE TAGS YML
const tagsYaml = customTags.map(tag => `  - ${tag}`).join("\n");
const contextsYaml = contexts.map(tag => `  - ${tag}`).join("\n");

// Limpa múltiplos espaços e remove hifens soltos que possam ter sobrado no começo ou no fim do texto
rawInput = rawInput.replace(/\s+/g, " ").replace(/^[-\s]+|[-\s]+$/g, '').trim();

let taskTitle = rawInput || "Sem Título";
const finalFileName = taskNumber !== '' ? `${taskNumber} - ${taskTitle}` : taskTitle;

// 3. VERIFICAÇÃO DE PASTA E MOVE O ARQUIVO
if (!app.vault.getAbstractFileByPath(folder)) {
    await app.vault.createFolder(folder);
}

// 4. LÓGICA DA DAILY NOTE
const dailyFile = app.vault.getAbstractFileByPath(`${dailyFilePath}.md`);
if (!dailyFile) {
    const dailyTemplateFile = app.vault.getAbstractFileByPath(dailyTemplatePath);
	if (dailyTemplateFile) {
		const dailyContent = await tp.file.include(dailyTemplateFile);
     //     if (!app.vault.getAbstractFileByPath(dailyFolder)) {
     //        await app.vault.createFolder(dailyFolder);
     //    }
		await app.vault.create(dailyFilePath, dailyContent);
    }
}
await tp.file.move(`${folder}/${finalFileName}`);

-%>
---
title: "<% taskTitle %>"
status: <% taskStatus %>
category: task
priority: <% taskPriority %>
scheduled: <% scheduledDate %>
task: "<% taskNumber %>"
involved:
  - "My"
tags:
<% tagsYaml %>
contexts:
- <% contexts %>
aliases:
  - "<% taskNumber %>"
dateCreated: <% tp.date.now("YYYY-MM-DD HH:mm:ss") %>
dateModified: <% tp.date.now("YYYY-MM-DD HH:mm:ss") %>

---

# <% finalFileName %>

🎯 **Objetivo:**

> [!info] Contexto
> Qual é o problema real que estou tentando resolver?
> Qual o estado atual do sistema?
> 

<% tp.file.cursor(1) %>

---

### 🔍 1. Análise
**O que sabemos:**

**Incertezas/Riscos:**

**Hipótese de Solução:**

---

### 🛠️ 2. Sub-tarefas

- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Análise inicial|🏗️ Análise inicial]]
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Daily|📅 Daily]]
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Implementação|🚧 Implementação]]
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Verificação & Testes|🧪 Verificação & Testes]]
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Conclusão|🏁 Conclusão]]

---

### 📝 3. Timeline de execução
- **<% tp.date.now("DD/MM HH:mm") %>**: Iniciando a análise técnica.

---

### 🚀 4. Próximos passos
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/1 Passo|1 Passo]]
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/2 Passo|2 Passo]]

---

### ✅ 5. Checklist final
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Código revisado|Código revisado?]]
- [ ] [[A01 - Tasks/02 - InProgress/<% finalFileName %>/Testes executados|Testes executados?]]

---
🔗 **Relacionados:**
- [[Tarefas]]
- [[B01 - Daily Notes/<% currentMonth %>/<% datePrefix %>]]
