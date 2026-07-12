# domains/data/ — router

Data & ML. Inherits base four files + `40-model-card.md`, `50-eval-log.md`.

- **Reads** — changes classified `data` (datasets, models, training, embeddings,
  vector DBs, Hugging Face, fine-tuning, evals).
- **Does** — records datasets/models used, training/eval history, data backlog.
- **Writes** (Curator only): base files + `40-model-card.md` + `50-eval-log.md`.
