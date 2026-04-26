# AGENTS.md — Obsidian LLM Wiki

## Identidade
Agente autônomo que mantém uma wiki Obsidian como **base de conhecimento pré-compilado** (não RAG). A wiki é artefato compilado, não chatbot.

## Estrutura do Vault
```
Z01 - AI Obsidian/
├── index.md          # Catálogo mestre (atualizar após cada escrita)
├── log.md            # Log cronológico de operações
├── hot.md            # Cache semântico da sessão (~500 palavras)
├── .manifest.json    # Fontes ingeridas: caminhos, hashes, páginas geradas
├── _meta/taxonomy.md # Vocabulário controlado de tags
├── /Raw/             # Área de staging — fontes brutas/imutáveis
├── /Scripts/         # Scripts CLI (TypeScript/Bun)
└── /Wiki/            # Conhecimento mantido pelo agente
    ├── concepts/     # Padrões, modelos mentais
    ├── entities/     # Pessoas, ferramentas, projetos
    ├── skills/       # Tutoriais, técnicas
    ├── references/   # Specs, APIs, configs
    ├── synthesis/    # Análises cruzadas
    ├── journal/      # Logs de sessão
    └── projects/     # Uma página por projeto sincronizado
```

## Regras de Autonomia
- **100% dentro de `Z01 - AI Obsidian/`**: ler, criar, editar, mover, deletar
- **0% fora**: consultar o usuário antes de qualquer escrita
- **Exceção**: pode gerenciar `AGENTS.md`, `.agents/`, `.skills/`

## Skills (roteamento)
| Intenção do usuário | Skill |
|---|---|
| "ingira/processe dados" | `wiki-ingest` |
| "crie uma tarefa" | `task` (template: `Z02 - Templates\Tasks\Tasks.md`) |
| "status/ingested/delta" | `wiki-status` |
| "o que sei sobre X" | `wiki-query` |
| "audit/lint/links quebrados" | `wiki-lint` |
| "criar links/cruzar referências" | `cross-linker` |
| "arrumar tags" | `tag-taxonomy` |
| "sincronizar projeto" | `wiki-rebuild` |
| "dashboard/dataview" | `wiki-dashboard` |

Skills vivem em `.skills/<nome>/SKILL.md`.

## Frontmatter Obrigatório (Wiki)
```yaml
---
title: Título
category: concepts|entities|skills|references|synthesis|journal|projects
tags: [tag1, tag2]
sources: [caminho/da/fonte.md]
created: 2026-04-26
updated: 2026-04-26
summary: 1-2 frases, ≤200 caracteres
provenience: { extracted: 0.8, inferred: 0.2, ambiguous: 0.0 }
---
```

## Convenções Críticas
- **`[[wikilinks]]`**: toda página linka para ≥2 páginas relacionadas
- **Marcadores de proveniência**: `^[inferred]` para afirmações sintetizadas, `^[ambiguous]` para divergências — afirmações extraídas não precisam de marcador
- **`_meta/taxonomy.md`**: tags de sistema `visibility/` **NÃO** vão aqui
- **Nomenclatura de projetos**: `<nome-do-projeto>.md` (não `_projeto.md`) — obsidian graph usa o nome do arquivo como rótulo
- **`index.md`**: formato ` - [[pagina]] — descrição ( #tag)` com espaço após `(` — sintaxe incorreta quebra a análise de tags

## Template de Tarefas (Templater)
Sintaxe de entrada: `FRPHP-1234 - Título @2026-05-01@ !High! $Open$ #api#`
- `@data` → scheduled
- `!prioridade` → priority (High/Medium/Low)
- `$status` → status (Open/In-progress/Done)
- `#tags` → tags customizadas

## Scripts Disponíveis
- `Z01 - AI Obsidian/Scripts/lint.ts`: detecta links quebrados e páginas órfãs

## Cross-Project
1. **`wiki-update`**: ler projeto externo → escrever em `Wiki/projects/<nome>.md` → atualizar `.manifest.json`
2. **`wiki-query`**: ler `index.md` primeiro, depois `summary:` do YAML — evitar abrir página inteira desnecessariamente

## Visibility Tags (opcional)
- Sem tag ou `visibility/public`: público
- `visibility/internal`: contexto de equipe/arquitetura
- `visibility/pii`: dados pessoais/sensíveis
