# Skill: Gestão de Tarefas

**Descrição**: Define o comportamento do OpenCode ao gerenciar demandas, backlog e processar tickets.

## Fluxo de Trabalho (Pipeline)
Sempre que uma ação exigir a criação de uma nova tarefa, execute os seguintes passos:

1. **Consulta à Fonte da Verdade**: Leia **obrigatoriamente** o template de tarefas em `Z02 - Templates/Tasks/Tasks.md`. (Lembrete: leitura apenas, não alterar).
2. **Criação do Arquivo**: Gere um novo arquivo `.md` para a tarefa com o cabeçalho YAML *frontmatter* perfeitamente preenchido com as chaves exigidas (como `status`, `priority`, `scheduled`, `task`, `tags`), garantindo a rastreabilidade via Dataview.
3. **Estruturação do Corpo**: Mantenha rigorosamente a estrutura interna do template original (seções como Contexto, Análise, Sub-tarefas, Timeline, Checklist).
4. **Contextualização e Backlinks**: Insira backlinks (`[[Nome da Pagina]]`) vinculando a tarefa ao documento ou conceito específico do diretório `/Wiki` que gerou a demanda.
5. **Verificação de Fronteiras**: Se for solicitado salvar a tarefa em uma pasta *fora* de `Z01 - AI Obsidian/`, **PARE** e solicite a aprovação do usuário antes de prosseguir com qualquer gravação.