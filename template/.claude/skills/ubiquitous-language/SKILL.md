---
name: ubiquitous-language
description: Extract domain terminology from conversations into a structured glossary at docs/UBIQUITOUS_LANGUAGE.md. Flags ambiguities, proposes canonical terms, groups by subdomain. Use when discussing domain terms, onboarding, or when terminology is ambiguous.
---

# Ubiquitous Language

Extract a DDD-style glossary from the current conversation, flagging ambiguities and proposing canonical terms.

## Process

1. **Scan** the conversation for domain nouns and verbs
2. **Identify problems**:
   - **Ambiguity**: same word used for different concepts
   - **Synonymy**: different words for the same concept
   - **Vagueness**: imprecise or overloaded terms
3. **Generate or update** `docs/UBIQUITOUS_LANGUAGE.md`

## Output Format

### Tables by Subdomain

Group terms into subdomains that match your project's domain (define your own — examples: Player, World, UI, Combat, Economy, Multiplayer, etc.).

| Term | Definition | Aliases to Avoid |
|---|---|---|
| **example term** | One-sentence definition. | synonym to avoid |

### Relationships

Show cardinality between key concepts:

- **Entity A** has one/many **Entity B** containing zero or more **Entity C**

### Flagged Ambiguities

Call out terms with conflicting usage explicitly.

## Rules

- Definitions: one sentence max
- Focus on project domain concepts, not generic programming terms
- Be opinionated when choosing canonical terms over synonyms
- Bold term names in relationship descriptions
- Add new subdomains that match your project's actual domain — don't use this project's built-in subdomains as a starting point

## Re-invocation

On subsequent calls: read existing `docs/UBIQUITOUS_LANGUAGE.md`, incorporate new terms, update definitions as understanding evolves, add new subdomains if needed.
