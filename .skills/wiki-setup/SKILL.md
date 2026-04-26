---
name: wiki-setup
description: >
  Initialize a new Obsidian wiki vault with the correct structure, special files, and configuration.
  Use this skill when the user wants to set up a new wiki from scratch, initialize the vault structure,
  create the .env file, or says things like "set up my wiki", "initialize obsidian", "create a new vault",
  "get started with the wiki". Also use when the user needs to reconfigure their existing vault or
  fix a broken setup.
---

# Obsidian Setup — Vault Initialization

You are setting up a new Z01 - AI Obsidian vault (or repairing an existing one).

## Step 1: Create .env

If `.env` doesn't exist, create it from `.env.example`. Ask the user for:

1. **Where should the vault live?** → `OBSIDIAN_WIKI_PATH`
   - Default: `~/Documents/Z01 - AI Obsidian-vault`
   - Must be an absolute path (after expansion)

2. **Where are your source documents?** → `OBSIDIAN_SOURCES_DIR`
   - Can be multiple paths, comma-separated
   - Default: `~/Documents`


4. **Have QMD installed?** → `QMD_WIKI_COLLECTION` / `QMD_PAPERS_COLLECTION`
   - Optional. Enables semantic search in `wiki-query` and source discovery in `wiki-ingest`.
   - If unsure, skip for now — both skills fall back to `Grep` automatically.
   - Install instructions: see `.env.example` (QMD section).

## Step 2: Create Vault Directory Structure

```bash
mkdir -p "$OBSIDIAN_VAULT_PATH"/.obsidian
mkdir -p "$OBSIDIAN_WIKI_PATH"
mkdir -p "$OBSIDIAN_WIKI_PATH"/Raw
mkdir -p "$OBSIDIAN_WIKI_PATH"/Archives
mkdir -p "$OBSIDIAN_WIKI_PATH"/Wiki/{concepts,entities,skills,references,synthesis,journal,projects}
```

- `.obsidian/` — Obsidian's own config. Creates vault recognition.
- `$OBSIDIAN_WIKI_PATH/Wiki/projects/` — Per-project knowledge (populated during ingest).
- `$OBSIDIAN_WIKI_PATH/Archives/` — Stores wiki snapshots for rebuild/restore operations.
- `$OBSIDIAN_WIKI_PATH/Raw/` — Staging area for unprocessed drafts. Drop rough notes here; `wiki-ingest` will promote them to proper wiki pages and delete the originals.

## Step 3: Create Special Files

### index.md

```markdown
---
title: Wiki Index
---

# Wiki Index

*This index is automatically maintained. Last updated: TIMESTAMP*

## Concepts

*No pages yet. Use `wiki-ingest` to add your first source.*

## Entities

## Skills

## References

## Synthesis

## Journal
```

### log.md

```markdown
---
title: Wiki Log
---

# Wiki Log

- [TIMESTAMP] INIT vault_path="OBSIDIAN_WIKI_PATH" categories=Wiki/concepts,Wiki/entities,Wiki/skills,Wiki/references,Wiki/synthesis,Wiki/journal

```

### hot.md

```markdown
---
title: Hot Cache
updated: TIMESTAMP
---

# Hot Cache

*A ~500-word semantic snapshot of recent activity. Updated after every major write operation.*

## Recent Activity

- [TIMESTAMP] INIT — vault created at OBSIDIAN_WIKI_PATH

## Active Threads

*None yet — start ingesting sources to populate.*

## Key Takeaways

*None yet.*

## Flagged Contradictions

*None yet.*
```

## Step 4: Create .obsidian Configuration

Create minimal Obsidian config for a good out-of-box experience:

### .obsidian/app.json
```json
{
  "strictLineBreaks": false,
  "showFrontmatter": false,
  "defaultViewMode": "preview",
  "livePreview": true
}
```

### .obsidian/appearance.json
```json
{
  "baseFontSize": 16
}
```

## Step 5: Recommend Obsidian Plugins

Tell the user about these recommended community plugins (they install manually):

1. **Dataview** — Query page metadata, create dynamic tables. Essential for a wiki.
2. **Graph Analysis** — Enhanced graph view for exploring connections.
3. **Templater** — If they want to create pages manually using templates.
4. **Obsidian Git** — Auto-backup the vault to a git repo.

## Step 6: Verify Setup

Run a quick sanity check:
- [ ] Vault directory exists with: `Wiki/concepts/`, `Wiki/entities/`, `Wiki/skills/`, `Wiki/references/`, `Wiki/synthesis/`, `Wiki/journal/`, `Wiki/projects/`, `Archives/`, `Raw/`
- [ ] `Wiki/index.md` exists at vault root
- [ ] `Wiki/log.md` exists at vault root
- [ ] `Wiki/hot.md` exists at vault root
- [ ] `.env` has `OBSIDIAN_WIKI_PATH` set
- [ ] `.env` has `OBSIDIAN_VAULT_PATH` set
- [ ] `.obsidian/` directory exists
- [ ] Source directories (if configured) exist and are readable

Report the results and tell the user they can now:
1. Open the vault in Obsidian (File → Open Vault → select the directory)
2. Run `wiki-status` to see what's available to ingest
3. Run `wiki-ingest` to add their first sources
4. Run to mine their OpenCode conversations
5. Run to mine their Kiro sessions (if they use Kiro)
6. Run `wiki-status` again anytime to check the delta
