# MTG AI Expert — Development Bible

**Project status:** Pre-MVP  
**Document purpose:** Source of truth for architecture, engineering decisions, scope, and development conventions.  
**Primary stack:** TypeScript, Next.js, PostgreSQL, Prisma, OpenAI Responses API, Scryfall, MTGJSON  
**Last updated:** 2026-09-12

---

## 1. Project Vision

Build an AI-powered Magic: The Gathering expert that uses an LLM for reasoning and orchestration while relying on external, current data sources for factual MTG knowledge.

The application should behave less like a generic chatbot with MTG knowledge baked into the model and more like a **tool-using MTG knowledge agent**.

### Core principle

> **The model reasons. External sources provide facts.**

The model must not be treated as the authoritative source for:

- Oracle card text
- Card rulings
- Comprehensive Rules
- Format legality
- Banned/restricted lists
- Current set information
- Release-note changes
- Current prices

When authoritative or current data can be retrieved, retrieve it.

---

# 2. Product Goals

## MVP goals

The first version should be able to:

1. Answer questions about individual cards.
2. Search for cards.
3. Answer rules questions using the current Comprehensive Rules.
4. Retrieve card-specific rulings.
5. Use official release notes when relevant.
6. Check format legality.
7. Explain the reasoning behind rules answers.
8. Provide source/provenance information.
9. Distinguish facts from strategy/opinion.
10. Fail safely when available evidence is insufficient.

## Non-goals for the MVP

Do **not** initially build:

- A complete deterministic MTG rules engine.
- A vector database.
- Fine-tuning.
- Multi-agent architecture.
- Kubernetes.
- Microservices.
- Kafka.
- Complex AWS infrastructure.
- Real-time multiplayer game simulation.
- Automated deck construction.
- Tournament/meta analysis.
- A massive community knowledge crawler.

These can be considered later if the product demonstrates a need for them.

---

# 3. Engineering Philosophy

## 3.1 Evidence over memory

The LLM has general MTG knowledge, but its internal knowledge is never the preferred source for mutable MTG facts.

Prefer:

1. Current official Wizards information.
2. Current Oracle/card data.
3. Official rulings and release notes.
4. High-quality structured MTG databases.
5. Community information.
6. LLM knowledge/inference.

## 3.2 Deterministic data should remain deterministic

Do not ask the LLM to calculate things that can be reliably determined by code.

Examples:

- Mana value.
- Color identity.
- Card legality.
- Deck size.
- Singleton violations.
- Number of copies.
- Card name resolution.
- Exact Oracle text.
- Rule lookup.
- Set metadata.

The LLM should orchestrate these operations and explain their results.

## 3.3 Keep the architecture boring until complexity is justified

Prefer:

- PostgreSQL over a separate database for every feature.
- PostgreSQL full-text/trigram search before a vector database.
- Next.js backend routes before a separate API service.
- A single worker before a distributed queue.
- Typed functions before an agent framework.
- Direct API clients before a large abstraction framework.

Introduce infrastructure only when an actual requirement exists.

---

# 4. System Architecture

Initial architecture:

```text
                         ┌─────────────────────┐
                         │       User          │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │      Next.js        │
                         │      Frontend       │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │     /api/chat       │
                         │    Agent Server     │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ OpenAI Responses    │
                         │       API           │
                         └──────────┬──────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
          Card Tools           Rules Tools        Legality Tools
                │                   │                   │
                ▼                   ▼                   ▼
           PostgreSQL          PostgreSQL          PostgreSQL
                │                   │                   │
                └───────────────────┼───────────────────┘
                                    │
                         ┌──────────┴──────────┐
                         │                    │
                         ▼                    ▼
                     Scryfall              Wizards
                     MTGJSON               Rules
                                           Release Notes
```

---

# 5. Technology Stack

## Frontend

- Next.js
- React
- TypeScript
- Tailwind CSS

## Backend

- Next.js Route Handlers
- TypeScript
- OpenAI Node SDK
- Zod
- Prisma

## Database

- PostgreSQL

## External MTG sources

### Primary card source

**Scryfall**

Use for:

- Current card information.
- Oracle text.
- Card search.
- Card identifiers.
- Card rulings.
- Set information.
- Legality.
- Prices where appropriate.
- Bulk card data.

### Secondary structured source

**MTGJSON**

Use for:

- Bulk structured MTG data.
- Supplemental card information.
- Historical/printing information.
- Legality information.
- Sets.
- Additional structured datasets.

### Authoritative rules source

**Wizards of the Coast**

Use for:

- Comprehensive Rules.
- Release Notes.
- Update Bulletins.
- Official rules changes.
- Official Oracle/rules announcements.

---

# 6. Source Authority

The application must establish an explicit source hierarchy.

## Tier 1 — Official / authoritative

- Wizards Comprehensive Rules.
- Official Wizards rules announcements.
- Official Wizards release notes.
- Official Oracle/rules information.
- Official banned/restricted announcements.

## Tier 2 — Structured MTG databases

- Scryfall.
- MTGJSON.

## Tier 3 — Community sources

Examples:

- Judge resources.
- MTG Wiki.
- Community discussions.
- Articles.
- Forums.

Community information may be useful for strategy and interpretation but must not override authoritative rules.

## Tier 4 — LLM knowledge

Use only when appropriate for:

- General strategy.
- Explanations.
- Historical context.
- Opinions.
- General gameplay advice.

Never use model memory as the sole authority for mutable factual MTG data when a tool can retrieve that data.

---

# 7. Database Model

Initial Prisma models:

```text
Card
Printing
Ruling
ComprehensiveRule
ReleaseNote
CardLegality
```

## Card

Represents an Oracle-level card.

Important fields:

- id
- oracleId
- name
- manaCost
- manaValue
- typeLine
- oracleText
- colors
- colorIdentity
- keywords
- power
- toughness
- loyalty
- layout
- timestamps

## Printing

Represents an individual printing.

Important fields:

- id
- scryfallId
- cardId
- setCode
- collectorNumber
- rarity
- language
- finishes
- releasedAt
- imageUri
- scryfallUri

## Ruling

Represents a ruling associated with a card.

Important fields:

- id
- cardId
- rulingDate
- text
- source
- timestamps

## ComprehensiveRule

Represents a structured rule or subsection.

Important fields:

- id
- ruleNumber
- section
- subsection
- title
- text
- parentRule
- version
- effectiveAt
- searchText

Preserve exact rule numbers.

Do not reduce rules to anonymous chunks.

## ReleaseNote

Represents official Wizards release-note material.

Important fields:

- id
- setCode
- setName
- title
- text
- cardName
- sourceUrl
- publishedAt
- version

## CardLegality

Represents legality for a format.

Important fields:

- id
- cardId
- format
- status

---

# 8. Search Strategy

Do not start with embeddings.

Use a hybrid relational/search strategy first.

## Exact card lookup

Use normalized case-insensitive name matching.

## Fuzzy card lookup

Use PostgreSQL `pg_trgm`.

Useful for:

- Misspellings.
- Partial names.
- User input errors.

## Rules search

Use PostgreSQL full-text search.

Rules should be indexed with metadata including:

- Rule number.
- Section.
- Parent rule.
- Version.
- Effective date.

## Release-note search

Use PostgreSQL full-text search initially.

## Retrieval hierarchy

For a rules question:

```text
User question
     ↓
Identify cards/concepts
     ↓
Retrieve Oracle text
     ↓
Retrieve card rulings
     ↓
Retrieve relevant Comprehensive Rules
     ↓
Retrieve relevant Release Notes when applicable
     ↓
LLM reasoning
     ↓
Answer + sources
```

Do not retrieve the entire Comprehensive Rules document for every question.

---

# 9. OpenAI Tool Architecture

The LLM should interact with the application through narrowly scoped tools.

Initial tools:

```text
get_card
search_cards
get_card_rulings
search_rules
search_release_notes
check_legality
```

Potential future tools:

```text
get_set
check_deck_legality
analyze_deck
search_decks
search_tournament_results
get_price
analyze_game_state
```

## Tool design rules

Each tool must:

1. Have a narrow responsibility.
2. Have a strict JSON schema.
3. Validate inputs.
4. Return structured data.
5. Include provenance where appropriate.
6. Never expose raw database access to the LLM.

Architecture:

```text
OpenAI
   ↓
Tool call
   ↓
Application tool handler
   ↓
Domain service
   ↓
Database/API
   ↓
Validated structured result
   ↓
OpenAI
```

---

# 10. Initial Tool Definitions

## get_card

Purpose:

Retrieve current Oracle-level card information.

Input:

```text
name: string
```

Behavior:

1. Search local database.
2. If unavailable or stale, query Scryfall.
3. Validate response.
4. Cache/update local data.
5. Return structured card data.

---

## search_cards

Purpose:

Search the card database.

Input:

```text
query: string
limit: integer
```

Behavior:

- Support Scryfall-style search initially.
- Return a limited number of results.
- Never dump the entire card database into the model context.

---

## get_card_rulings

Purpose:

Retrieve rulings for a specific card.

Input:

```text
card_name: string
```

Behavior:

1. Resolve card.
2. Retrieve cached rulings.
3. Refresh from Scryfall when appropriate.
4. Return rulings with dates and provenance.

---

## search_rules

Purpose:

Retrieve relevant Comprehensive Rules.

Input:

```text
query: string
rule_numbers: string[]
limit: integer
```

The model may provide rule-number hints when it recognizes relevant areas.

Return:

```text
rule number
section
title
text
version
effective date
source
```

---

## search_release_notes

Purpose:

Search official Wizards release notes and update bulletins.

Input:

```text
query: string
card_names: string[]
limit: integer
```

Return relevant documents/sections with provenance.

---

## check_legality

Purpose:

Determine whether cards are legal in a format.

Input:

```text
cards: string[]
format: enum
```

Initially support:

- standard
- pioneer
- modern
- legacy
- vintage
- pauper
- commander
- historic
- timeless
- brawl

Expand as needed.

---

# 11. Rules Answering Policy

For rules questions, the agent should follow this procedure:

```text
1. Identify all relevant cards.
2. Retrieve current Oracle text.
3. Identify important rules terminology.
4. Retrieve relevant card rulings.
5. Retrieve relevant Comprehensive Rules.
6. Retrieve relevant release notes if applicable.
7. Resolve the interaction.
8. Explain the reasoning.
9. Cite relevant sources.
```

The agent should explicitly distinguish:

- What the card says.
- What the Comprehensive Rules say.
- What the resulting interaction is.
- Any assumptions being made.

If evidence is insufficient:

> Do not invent an answer. State what information is missing.

---

# 12. Casual Mode vs Judge Mode

The application should eventually support two response modes.

## Casual mode

Optimized for:

- Conciseness.
- Accessibility.
- Beginner-friendly explanations.

Example:

```text
No. The creature doesn't "die" if it is exiled.

In Magic, a creature dies when it is put into a graveyard
from the battlefield, so Blood Artist won't trigger.
```

## Judge mode

Optimized for:

- Exact terminology.
- Rule numbers.
- Interaction sequence.
- Detailed reasoning.
- Source citations.

Example structure:

```text
Answer: No.

Reasoning:
1. ...
2. ...
3. ...

Relevant rules:
- CR 700.x
- CR 603.x
```

---

# 13. Provenance

Every retrieved factual result should retain provenance.

Example:

```json
{
  "source": "scryfall",
  "sourceId": "...",
  "retrievedAt": "...",
  "dataVersion": "..."
}
```

Rules:

```json
{
  "source": "wizards",
  "document": "Comprehensive Rules",
  "rule": "603.3",
  "version": "..."
}
```

The frontend should eventually expose sources to the user.

Provenance is also essential for debugging incorrect answers.

---

# 14. Data Freshness

MTG data changes.

The ingestion architecture must support updates without requiring application redeployment.

Initial strategy:

```text
External source
      ↓
Ingestion script
      ↓
Validation
      ↓
PostgreSQL upsert
      ↓
Search index update
```

Future strategy:

```text
Scheduled job
      ↓
Detect changed source
      ↓
Download
      ↓
Parse
      ↓
Validate
      ↓
Upsert
      ↓
Update search
```

Never silently overwrite historical information when versioning is important.

---

# 15. Scryfall Strategy

Use Scryfall bulk data for large imports.

Do not issue individual API requests for every card during initial ingestion.

Use individual Scryfall requests for:

- Missing cards.
- Refreshing stale records.
- Specific rulings.
- On-demand lookups.

Cache useful responses in PostgreSQL.

Respect Scryfall's API usage guidelines and rate limits.

---

# 16. MTGJSON Strategy

MTGJSON is a supplemental source, not necessarily the primary authority for rules interpretation.

Use it for:

- Bulk data.
- Printing information.
- Supplemental structured datasets.
- Historical information.
- Cross-checking.

When Scryfall and MTGJSON disagree on mutable card data, investigate the discrepancy rather than blindly choosing one.

For actual rules interpretation, prefer official Wizards sources.

---

# 17. Project Structure

Initial project:

```text
mtg-ai/
│
├── app/
│   ├── api/
│   │   └── chat/
│   │       └── route.ts
│   │
│   ├── chat/
│   │   └── page.tsx
│   │
│   ├── cards/
│   │   └── [name]/
│   │       └── page.tsx
│   │
│   └── page.tsx
│
├── components/
│   ├── chat/
│   │   ├── Chat.tsx
│   │   ├── Message.tsx
│   │   ├── ToolCall.tsx
│   │   └── SourceCitation.tsx
│   │
│   └── cards/
│       └── CardPreview.tsx
│
├── lib/
│   ├── ai/
│   │   ├── client.ts
│   │   ├── agent.ts
│   │   ├── prompt.ts
│   │   └── tools.ts
│   │
│   ├── mtg/
│   │   ├── cards.ts
│   │   ├── rulings.ts
│   │   ├── rules.ts
│   │   ├── legality.ts
│   │   └── release-notes.ts
│   │
│   ├── scryfall/
│   │   ├── client.ts
│   │   ├── cards.ts
│   │   ├── rulings.ts
│   │   └── bulk.ts
│   │
│   ├── retrieval/
│   │   ├── cards.ts
│   │   ├── rules.ts
│   │   ├── release-notes.ts
│   │   └── ranking.ts
│   │
│   └── db/
│       ├── client.ts
│       └── queries.ts
│
├── prisma/
│   └── schema.prisma
│
├── scripts/
│   ├── ingest-scryfall.ts
│   ├── ingest-mtgjson.ts
│   ├── ingest-rules.ts
│   └── ingest-release-notes.ts
│
├── tests/
│   ├── ai/
│   ├── rules/
│   ├── retrieval/
│   └── tools/
│
├── .env
├── package.json
├── tsconfig.json
└── README.md
```

---

# 18. TypeScript First

The MVP should be TypeScript-first.

Reasons:

- Existing project experience is primarily frontend/TypeScript-oriented.
- Next.js, API routes, database code, and OpenAI integration can share one language.
- Shared types reduce friction.
- It keeps the initial architecture simple.

Python should be introduced later for:

- Evaluation experiments.
- Data analysis.
- ML experimentation.
- Rules-engine experimentation.
- Recommendation models.

Do not create a Python service just because the project is AI-related.

---

# 19. Environment Variables

Initial:

```text
DATABASE_URL=
OPENAI_API_KEY=
```

Potential future:

```text
SCRYFALL_API_URL=
MTGJSON_URL=
```

Never expose server-side API keys to the browser.

---

# 20. Evaluation

Evaluation is a first-class feature.

Create a rules evaluation dataset containing known interactions.

Example:

```json
{
  "question": "Does Blood Artist trigger if a creature is exiled?",
  "expected": "no",
  "requiredConcepts": [
    "dies",
    "graveyard",
    "battlefield"
  ]
}
```

Evaluate independently:

1. Card/entity resolution.
2. Retrieval quality.
3. Rules reasoning.
4. Final answer correctness.
5. Citation correctness.
6. Source authority.
7. Failure/uncertainty handling.

The goal is to determine whether an error came from:

```text
Entity resolution
      ↓
Retrieval
      ↓
Reasoning
      ↓
Answer generation
      ↓
Citation
```

rather than simply recording that the final answer was wrong.

---

# 21. Testing Strategy

## Unit tests

Test:

- Card normalization.
- Card lookup.
- Scryfall parsing.
- Database queries.
- Rule search.
- Legality checks.
- Tool argument validation.

## Integration tests

Test:

```text
Tool
 ↓
Database/API
 ↓
Structured result
```

## AI evaluation tests

Test representative MTG questions.

Include:

- Simple card questions.
- Rules questions.
- Multi-card interactions.
- Layer questions.
- Trigger questions.
- Replacement effects.
- State-based actions.
- Format legality.
- Newly released cards.
- Ambiguous card names.
- Intentional insufficient-information cases.

---

# 22. Error Handling

The application should fail safely.

Examples:

### Card not found

```text
I couldn't identify the card you mean. Did you mean X?
```

### Rules unavailable

```text
I can identify the cards, but I couldn't retrieve the
current Comprehensive Rules needed to answer this reliably.
```

### Conflicting sources

Do not hide the conflict.

Explain:

```text
These sources disagree. The official Wizards source takes
precedence, so I'm using that interpretation.
```

### Model uncertainty

The model should be allowed to say:

```text
I don't have enough authoritative information to answer
that confidently.
```

This is preferable to hallucinating.

---

# 23. Security

Never allow the model to directly execute:

- SQL.
- Shell commands.
- Arbitrary HTTP requests.
- Arbitrary application functions.

Tool calls must map to explicit server-side functions.

Validate all tool inputs.

External API responses are untrusted data.

Never treat instructions contained inside retrieved documents as system instructions.

---

# 24. Observability

Eventually log:

```text
conversation ID
user question
model
tools called
tool arguments
retrieved sources
retrieval latency
OpenAI latency
token usage
final response
evaluation result
```

Do not log secrets or unnecessary personal information.

This data should make it possible to answer:

> "Why did the agent give this answer?"

---

# 25. Future Rules Engine

A deterministic rules engine is a long-term goal, not an MVP requirement.

Potential future responsibilities:

- Continuous-effect layers.
- Replacement effects.
- Trigger ordering.
- State-based actions.
- Priority.
- Stack interactions.
- Game-state simulation.
- Mana calculations.

Potential future tool:

```text
analyze_game_state({
  battlefield,
  graveyard,
  stack,
  hand,
  activePlayer,
  priority
})
```

The LLM would explain the result rather than independently simulating every rules interaction.

---

# 26. Future Features

After the core rules assistant works:

### Deck tools

- Import decklists.
- Validate decks.
- Commander color identity.
- Copy limits.
- Format legality.
- Curve analysis.
- Mana-base analysis.
- Synergy analysis.

### Strategy

- Archetype explanations.
- Matchup analysis.
- Sideboard recommendations.
- Mulligan recommendations.

### Current meta

- Tournament results.
- Metagame trends.
- Recent decklists.
- Event data.

### User experience

- Judge mode.
- Beginner mode.
- Card hover previews.
- Clickable rule citations.
- Conversation history.
- Deck workspace.
- Game-state analyzer.

---

# 27. Development Phases

## Phase 0 — Foundation

- Create Next.js project.
- Configure TypeScript.
- Configure PostgreSQL.
- Configure Prisma.
- Establish environment variables.
- Establish linting/testing.
- Create initial project structure.

## Phase 1 — Card Knowledge

Implement:

- Scryfall client.
- Card schema.
- Bulk ingestion.
- Card lookup.
- Card search.
- Card UI.

## Phase 2 — OpenAI Agent

Implement:

- OpenAI client.
- Responses API.
- System instructions.
- `get_card`.
- `search_cards`.
- Tool execution loop.
- Chat UI.

## Phase 3 — Rules Retrieval

Implement:

- Comprehensive Rules ingestion.
- Rule parser.
- PostgreSQL full-text search.
- `search_rules`.

## Phase 4 — Rulings

Implement:

- Ruling ingestion.
- `get_card_rulings`.

## Phase 5 — Release Notes

Implement:

- Wizards release-note ingestion.
- Release-note search.
- `search_release_notes`.

## Phase 6 — Legality

Implement:

- Legality storage.
- `check_legality`.
- Format-aware responses.

## Phase 7 — Evaluation

Implement:

- Evaluation dataset.
- Automated evaluation runner.
- Retrieval evaluation.
- Citation evaluation.
- Regression tests.

---

# 28. Definition of Done for MVP

The MVP is complete when a user can ask:

> "Does this interaction work?"

and the application can:

```text
Identify relevant cards
        ↓
Retrieve current Oracle text
        ↓
Retrieve relevant rulings
        ↓
Retrieve relevant Comprehensive Rules
        ↓
Retrieve release notes when relevant
        ↓
Reason over the evidence
        ↓
Explain the answer
        ↓
Provide source information
```

The system should demonstrate that it is **using current external knowledge rather than pretending the LLM itself is the MTG database**.

---

# 29. Architectural Rules That Must Not Be Violated

1. **Do not bake mutable MTG facts into prompts.**
2. **Do not use the LLM's memory as the authoritative rules source.**
3. **Do not expose arbitrary database access to the model.**
4. **Do not introduce a vector database without demonstrating a retrieval need.**
5. **Do not introduce microservices without a concrete scaling/ownership reason.**
6. **Do not sacrifice source provenance for convenience.**
7. **Do not silently resolve conflicting authoritative sources.**
8. **Do not invent citations or rule numbers.**
9. **Do not claim current legality without current legality data.**
10. **Prefer deterministic code for deterministic MTG calculations.**
11. **Keep ingestion separate from request-time reasoning.**
12. **Every new external data source must have a defined authority level and purpose.**
13. **Every major AI behavior should eventually have an evaluation case.**
14. **When evidence is insufficient, the system must be allowed to say so.**

---

# 30. North Star Architecture

The long-term system should evolve toward:

```text
                         USER
                           │
                           ▼
                    ┌──────────────┐
                    │   Next.js    │
                    │      UI      │
                    └──────┬───────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │   Agent Layer   │
                  │                 │
                  │ OpenAI          │
                  │ Orchestration   │
                  └────────┬────────┘
                           │
          ┌────────────────┼─────────────────┐
          │                │                 │
          ▼                ▼                 ▼
     Card Tools       Rules Tools       Game Tools
          │                │                 │
          ▼                ▼                 ▼
     Card Database    Rules Database    Rules Engine
          │                │                 │
          └────────────────┼─────────────────┘
                           │
                     Evidence Layer
                           │
          ┌────────────────┼────────────────┐
          │                │                │
       Scryfall         Wizards          MTGJSON
          │                │                │
          └────────────────┼────────────────┘
                           │
                     Evaluation Layer
                           │
                     ┌─────┴─────┐
                     │           │
                 Retrieval    Reasoning
                  Evals         Evals
```

The defining characteristic of the project is:

> **An LLM-powered MTG reasoning system grounded in current, structured, authoritative Magic data.**

That principle should guide every future architectural decision.
