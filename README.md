## CATBench — Catalan Linguistic Benchmarks

A compact benchmark to evaluate LLMs on Catalan grammar, morphology, and usage. It includes:

- A backend runner (Elixir) that queries models via OpenRouter, scores answers, and estimates cost/latency.
- A lightweight frontend (Nuxt + Tailwind + DaisyUI + ApexCharts) to visualize accuracy, speed, and cost per model.


## Repository layout

- `catbench/` — Elixir backend (runner, scoring, providers)
  - `lib/catbench/` — main modules (`cli.ex`, `runner.ex`, `scorer.ex`, `prompt.ex`, `providers/…`, `io.ex`)
  - `data/` — YAML datasets (`ca_items_v*.yaml`)
- `frontend/` — Nuxt app for interactive dashboards
  - `app/pages/index.vue` — main page (imports `app/static/results.json`)
  - `app/components/` — charts and cards
  - `app/assets/css/main.css` — Tailwind + DaisyUI
- `results.json` — example backend output (root-level)


## Prerequisites

- Elixir ~> 1.18 (and Erlang/OTP compatible with your Elixir)
- Node.js 18+ (or Bun). The frontend uses Nuxt 4, Tailwind 4, and DaisyUI.
- OpenRouter API key for running models: set `OPENROUTER_API_KEY`.


## Quick start

### 1) Run the backend benchmark

```bash
# From repo root
export OPENROUTER_API_KEY=YOUR_KEY
cd catbench
mix deps.get

# Run with the default model set and dataset (see CLI options below)
mix run -e 'Catbench.CLI.main([])'

# Or specify dataset and output path explicitly
mix run -e 'Catbench.CLI.main(["--input","data/ca_items_v1.yaml","--out","../results.json"])'
```

Results are written to the specified JSON path (default: `results.json` at project root if you pass that path).

### 2) View results in the dashboard

```bash
# From repo root
cd frontend
npm install   # or: bun install
npm run dev   # or: bun run dev
```

The dashboard reads `frontend/app/static/results.json`. To visualize your fresh run, copy/symlink the generated file there:

```bash
# Example: copy root results into the frontend app static folder
cp ../results.json app/static/results.json
```

Open the local URL printed by Nuxt (typically `http://localhost:3000`).


## Backend usage

### Command

```bash
mix run -e 'Catbench.CLI.main(["--input","data/ca_items_v1.yaml","--out","results.json","--models","openai/gpt-4o-mini,anthropic/claude-3.5-haiku","--concurrency","8"])'
```

### Options

- `--input` (string): Path to YAML dataset. Defaults to `data/ca_items.yaml`.
- `--out` (string): Output JSON path. Defaults to `results.json`.
- `--models` (comma-separated): Override default model list. Example: `openai/gpt-4o-mini,anthropic/claude-3.5-haiku`.
- `--concurrency` (integer): Parallel requests per model (default: 8 from CLI, 6 in runner fallback).

The runner calls OpenRouter’s chat completions endpoint for each item and computes:

- Per-item: correctness, tokens (prompt/completion/total), latency, estimated price
- Per-model summary: total items, correct count, accuracy %, token sums, avg latency

Environment variable required:

- `OPENROUTER_API_KEY`: your key (see `https://openrouter.ai`).


## Data format (YAML)

Datasets live in `catbench/data/`. Each file has top-level `items:` with entries of either cloze or multiple-choice (MCQ).

### Cloze example

```yaml
- id: subj_present_001
  task: cloze
  instruction: "Omple el buit amb una sola paraula. Respon només amb la paraula."
  text: "Volem que ell **[CREURE]** que és possible."
  expect:
    type: regex
    pattern: "^(cregui)$"
```

### MCQ example

```yaml
- id: pronoms_001
  task: mcq
  instruction: "Tria l'opció A/B/C/D correcta. Respon només amb la lletra."
  text: "No ___ vaig explicar ahir."
  options: ["li ho","l'hi","ho li","li'l"]
  correct: "B"
```

Scoring rules (`lib/catbench/scorer.ex`):

- `expect.type: exact` — Normalize and compare exact strings (case-insensitive, trims trailing dot).
- `expect.type: regex` — Case-insensitive regex match against output.
- `task: mcq` — Compare first letter of the model’s answer with the `correct` letter (A/B/C/D).


## Output format (JSON)

Top-level shape:

```json
{
  "generated_at": "2025-01-01T00:00:00Z",
  "models": [
    {
      "model": "openai/gpt-4o-mini",
      "summary": {
        "total": 42,
        "corrects": 33,
        "accuracy_percentage": 78.57,
        "tokens": { "prompt": 12345, "completion": 6789, "total": 19134 },
        "avg_latency_ms": 512.4
      },
      "results": [
        {
          "id": "subj_present_001",
          "ok": true,
          "output": "cregui",
          "meta": { "expected": "cregui" },
          "tokens": { "prompt": 120, "completion": 5, "total": 125 },
          "latency_ms": 430,
          "price": 0.00003
        }
      ]
    }
  ]
}
```

Notes:

- Cost is estimated per request using ppm rates defined in `lib/catbench/runner.ex` (`@default_pricing_per_million`). You can override pricing via `run(pricing: …)` when calling `Catbench.Runner` directly.
- The frontend computes total per-model cost by summing `result.price` values if a summary cost is not present.


## Frontend (Dashboard)

- Stack: Nuxt 4, Tailwind 4, DaisyUI, Vue ApexCharts
- Theme: DaisyUI `dracula` (see `app/assets/css/main.css`)
- Data source: static import from `app/static/results.json` (overwrite with fresh output)

Common commands:

```bash
cd frontend
npm install         # or: bun install
npm run dev         # start local dev server
npm run build       # production build
npm run preview     # preview the production build
```


## Default model set

If `--models` is not provided, the CLI uses:

```
openai/gpt-4o-mini,
anthropic/claude-3.5-haiku,
google/gemini-2.5-flash,
x-ai/grok-3-mini,
qwen/qwq-32b,
mistralai/mistral-medium-3.1,
nousresearch/hermes-4-70b
```


## Troubleshooting

- Missing API key: ensure `OPENROUTER_API_KEY` is exported in the environment running `mix run`.
- Timeouts: increase `--concurrency` prudently and/or the internal `@timeout` in `runner.ex` via options; network hiccups or provider backpressure can cause exits.
- Frontend shows old data: verify `frontend/app/static/results.json` was updated and refresh the page (Nuxt caches static imports until reload).
- Token counts missing: some providers/models may omit `usage`; the runner falls back to 0 when absent.


## Roadmap

- Add additional providers and model adapters
- Expand datasets and fine-grained categories
- Publish hosted dashboard with automated runs


## Acknowledgements

- Data loading: `yaml_elixir`
- HTTP: `req`
- Charts: `vue3-apexcharts`
- UI: Tailwind CSS + DaisyUI