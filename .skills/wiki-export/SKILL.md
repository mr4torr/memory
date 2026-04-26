---
name: wiki-export
description: >
  Export the Obsidian wiki's knowledge graph to structured formats for use in external tools.
  Use this skill when the user says "export wiki", "export graph", "export to JSON", "export to Gephi",
  "export to Neo4j", "graphml", "visualize wiki", "knowledge graph export", or wants to use their
  wiki data in another tool. Outputs graph.json, graph.graphml, cypher.txt (Neo4j), and graph.html
  (interactive browser visualization) into a wiki-export/ directory at the vault root.
---

# Wiki Export — Knowledge Graph Export

You are exporting the wiki's wikilink graph to structured formats so it can be used in external tools (Gephi, Neo4j, custom scripts, browser visualization).

## Before You Start

1. Read `.env` to get `OBSIDIAN_WIKI_PATH`
2. Confirm the vault has pages to export — if fewer than 5 pages exist, warn the user and stop

## Visibility Filter (optional)

By default, **all pages are exported** regardless of visibility tags. This preserves existing behavior.

If the user requests a filtered export — phrases like **"public export"**, **"user-facing export"**, **"exclude internal"**, **"no internal pages"** — activate **filtered mode**:

- Build a **blocked tag set**: `{visibility/internal, visibility/pii}`
- Skip any page whose frontmatter tags contain a blocked tag when building the node list
- Skip any edge where either endpoint was excluded
- Note the filter in the summary: `(filtered: visibility/internal, visibility/pii excluded)`

Pages with no `visibility/` tag, or tagged `visibility/public`, are always included.

## Step 1: Build the Node and Edge Lists

Glob all `.md` files in the vault (excluding `$OBSIDIAN_WIKI_PATH/Archives/`, `$OBSIDIAN_WIKI_PATH/Raw/`, `$OBSIDIAN_WIKI_PATH/_meta/`, `.obsidian/`, `index.md`, `log.md`, `_insights.md`). In filtered mode, also skip pages whose tags contain `visibility/internal` or `visibility/pii`.

For each page, extract from frontmatter:
- `id` — relative path from vault root, without `.md` extension (e.g. `$OBSIDIAN_WIKI_PATH/Wiki/concepts/transformers`)
- `label` — `title` field from frontmatter, or filename if missing
- `category` — directory prefix (`concepts`, `entities`, `skills`, `references`, `synthesis`, `projects`, or `journal`)
- `tags` — array from frontmatter tags field
- `summary` — frontmatter `summary` field if present

This is your **node list**.

For each page, Grep the body for `\[\[.*?\]\]` to extract all wikilinks:
- Parse each `[[target]]` or `[[target|display]]` — use the target part only
- Resolve the target to a node id (normalize: lowercase, spaces→hyphens, strip `.md`)
- Skip links that point outside the node list (broken links)
- Each resolved link becomes an edge: `{source: page_id, target: linked_id, relation: "wikilink", confidence: "EXTRACTED"}`
- If the linking sentence ends with `^[inferred]` or `^[ambiguous]`, override `confidence` accordingly

This is your **edge list**.

## Step 2: Assign Community IDs

Group pages into communities by tag clustering:
- Pages sharing the same dominant tag belong to the same community
- Dominant tag = the first tag in the page's frontmatter tags array
- Pages with no tags get community id `null`
- Number communities starting from 0, ordered by size descending (largest community = 0)

This enables community-based coloring in the HTML visualization and tools like Gephi.

## Step 3: Write the Output Files

Create `wiki-export/` at the vault root if it doesn't exist. Write all four files:

---

### 3a. `graph.json`

NetworkX node_link format — standard for graph tools and scripts:

```json
{
  "directed": false,
  "multigraph": false,
  "graph": {
    "exported_at": "<ISO timestamp>",
    "vault": "<OBSIDIAN_WIKI_PATH>",
    "total_nodes": N,
    "total_edges": M
  },
  "nodes": [
    {
      "id": "<OBSIDIAN_WIKI_PATH>/Wiki/concepts/transformers",
      "label": "Transformer Architecture",
      "category": "concepts",
      "tags": ["ml", "architecture"],
      "summary": "The attention-based architecture introduced in Attention Is All You Need.",
      "community": 0
    }
  ],
  "links": [
    {
      "source": "<OBSIDIAN_WIKI_PATH>/Wiki/concepts/transformers",
      "target": "<OBSIDIAN_WIKI_PATH>/Wiki/entities/vaswani",
      "relation": "wikilink",
      "confidence": "EXTRACTED"
    }
  ]
}
```

---

### 3b. `graph.graphml`

GraphML XML format — loadable in Gephi, yEd, and Cytoscape:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/graphml">
  <key id="label" for="node" attr.name="label" attr.type="string"/>
  <key id="category" for="node" attr.name="category" attr.type="string"/>
  <key id="tags" for="node" attr.name="tags" attr.type="string"/>
  <key id="community" for="node" attr.name="community" attr.type="int"/>
  <key id="relation" for="edge" attr.name="relation" attr.type="string"/>
  <key id="confidence" for="edge" attr.name="confidence" attr.type="string"/>
  <graph id="wiki" edgedefault="undirected">
    <node id="<OBSIDIAN_WIKI_PATH>/Wiki/concepts/transformers">
      <data key="label">Transformer Architecture</data>
      <data key="category">concepts</data>
      <data key="tags">ml, architecture</data>
      <data key="community">0</data>
    </node>
    <edge source="<OBSIDIAN_WIKI_PATH>/Wiki/concepts/transformers" target="<OBSIDIAN_WIKI_PATH>/Wiki/entities/vaswani">
      <data key="relation">wikilink</data>
      <data key="confidence">EXTRACTED</data>
    </edge>
  </graph>
</graphml>
```

Write one `<node>` per page and one `<edge>` per wikilink.

---

### 3c. `cypher.txt`

Neo4j Cypher `MERGE` statements — paste into Neo4j Browser or run with `cypher-shell`:

```cypher
// Wiki knowledge graph export — <TIMESTAMP>
// Load with: cypher-shell -u neo4j -p password < cypher.txt

// Nodes
MERGE (n:Page {id: "Z01 - AI Obsidian/Wiki/concepts/transformers"}) SET n.label = "Transformer Architecture", n.category = "concepts", n.tags = ["ml","architecture"], n.community = 0;
MERGE (n:Page {id: "Z01 - AI Obsidian/Wiki/entities/vaswani"}) SET n.label = "Ashish Vaswani", n.category = "entities", n.tags = ["person","ml"], n.community = 0;

// Relationships
MATCH (a:Page {id: "Z01 - AI Obsidian/Wiki/concepts/transformers"}), (b:Page {id: "Z01 - AI Obsidian/Wiki/entities/vaswani"}) MERGE (a)-[:WIKILINK {relation: "wikilink", confidence: "EXTRACTED"}]->(b);
```

Write one `MERGE` node statement per page, then one `MATCH`/`MERGE` relationship statement per edge.

---

### 3d. `graph.html`

A self-contained interactive visualization using the vis.js CDN (no local dependencies). The user opens this file in any browser — no server needed.

Build the HTML file by:

1. Generating a JSON array of node objects for vis.js:
```js
{id: "Z01 - AI Obsidian/Wiki/concepts/transformers", label: "Transformer Architecture", color: {background: "#4E79A7"}, size: <degree * 3 + 8>, title: "concepts | #ml #architecture", community: 0}
```
- Color by community (cycle through: `#4E79A7`, `#F28E2B`, `#E15759`, `#76B7B2`, `#59A14F`, `#EDC948`, `#B07AA1`, `#FF9DA7`, `#9C755F`, `#BAB0AC`)
- Size by degree (incoming + outgoing link count): `size = degree * 3 + 8`, capped at 60
- `title` = tooltip text shown on hover: category, tags, summary (if available)

2. Generating a JSON array of edge objects for vis.js:
```js
{from: "Z01 - AI Obsidian/Wiki/concepts/transformers", to: "Z01 - AI Obsidian/Wiki/entities/vaswani", dashes: false, width: 1, color: {color: "#666", opacity: 0.6}}
```
- `dashes: true` for INFERRED edges
- `dashes: [4,8]` for AMBIGUOUS edges

3. Writing the full HTML file:

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Wiki Knowledge Graph</title>
<script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: #0f0f1a; color: #e0e0e0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; display: flex; height: 100vh; }
  #graph { flex: 1; }
  #sidebar { width: 260px; background: #1a1a2e; border-left: 1px solid #2a2a4e; padding: 14px; overflow-y: auto; font-size: 13px; }
  #sidebar h3 { color: #aaa; font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; margin: 0 0 10px; }
  #info { margin-bottom: 16px; line-height: 1.6; color: #ccc; }
  .legend-item { display: flex; align-items: center; gap: 8px; padding: 3px 0; font-size: 12px; }
  .dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
  #stats { margin-top: 16px; color: #555; font-size: 11px; }
</style>
</head>
<body>
<div id="graph"></div>
<div id="sidebar">
  <h3>Wiki Knowledge Graph</h3>
  <div id="info">Click a node to see details.</div>
  <h3 style="margin-top:12px">Communities</h3>
  <div id="legend"><!-- populated by JS --></div>
  <div id="stats"><!-- populated by JS --></div>
</div>
<script>
const NODES_DATA = /* NODES_JSON */;
const EDGES_DATA = /* EDGES_JSON */;
const COMMUNITY_COLORS = ["#4E79A7","#F28E2B","#E15759","#76B7B2","#59A14F","#EDC948","#B07AA1","#FF9DA7","#9C755F","#BAB0AC"];

const nodes = new vis.DataSet(NODES_DATA);
const edges = new vis.DataSet(EDGES_DATA);
const network = new vis.Network(document.getElementById('graph'), {nodes, edges}, {
  physics: { solver: 'forceAtlas2Based', forceAtlas2Based: { gravitationalConstant: -60, springLength: 120 }, stabilization: { iterations: 200 } },
  interaction: { hover: true, tooltipDelay: 100 },
  nodes: { shape: 'dot', borderWidth: 1.5 },
  edges: { smooth: { type: 'continuous' }, arrows: { to: { enabled: true, scaleFactor: 0.4 } } }
});
network.once('stabilizationIterationsDone', () => network.setOptions({ physics: { enabled: false } }));

network.on('click', ({nodes: sel}) => {
  if (!sel.length) return;
  const n = NODES_DATA.find(x => x.id === sel[0]);
  if (!n) return;
  document.getElementById('info').innerHTML = `<b>${n.label}</b><br>Category: ${n.category||'—'}<br>Tags: ${n.tags||'—'}<br>${n.summary ? '<br>'+n.summary : ''}`;
});

// Build legend
const communities = {};
NODES_DATA.forEach(n => { if (n.community != null) communities[n.community] = (communities[n.community]||0)+1; });
const leg = document.getElementById('legend');
Object.entries(communities).sort((a,b)=>b[1]-a[1]).forEach(([cid, count]) => {
  const color = COMMUNITY_COLORS[cid % COMMUNITY_COLORS.length];
  leg.innerHTML += `<div class="legend-item"><div class="dot" style="background:${color}"></div>Community ${cid} (${count})</div>`;
});
document.getElementById('stats').textContent = `${NODES_DATA.length} pages · ${EDGES_DATA.length} links`;
</script>
</body>
</html>
```

Replace `/* NODES_JSON */` and `/* EDGES_JSON */` with the actual JSON arrays you generated in step 1.

---

## Step 4: Print Summary

```
Wiki export complete → wiki-export/
  graph.json    — N nodes, M edges (NetworkX node_link format)
  graph.graphml — N nodes, M edges (Gephi / yEd / Cytoscape)
  cypher.txt    — N MERGE nodes + M MERGE relationships (Neo4j)
  graph.html    — interactive browser visualization (open in any browser)
```

In filtered mode, append a line showing what was excluded:
```
  (filtered: X of Y pages excluded — visibility/internal, visibility/pii)
```

## Notes

- **Re-running is safe** — all output files are overwritten on each run
- **Broken wikilinks are skipped** — only edges to pages that exist in the vault are exported
- **The `wiki-export/` directory should be gitignored** if the vault is version-controlled — these are derived artifacts
- **`graph.json` is the primary format** — the others are derived from it. If a future tool supports graph queries natively, point it at `graph.json`
