# CV Translator (qt_plus)

A high-performance, rule-based **Chinese-to-Vietnamese Translation Engine** written in [Crystal](https://crystal-lang.org/).

This engine uses a **Dynamic Programming** algorithm to optimally segment and translate Chinese sentences based on configurable grammar rules, effectively handling word reordering (Head-Initial vs Head-Final) and context-specific meaning adjustments.

## Features

- **Rule-Based Engine**: Fully configurable via YAML. No hardcoded grammar logic.
- **Dynamic Programming Strategy**: Selects the optimal set of non-overlapping rules by maximizing a score function based on Rule Rank, Length, and Specificity.
- **Pattern Matching**: Supports matching by POS Tags (LTP format) and specific Token words.
- **Transformation Actions**:
    - **Reordering**: Swaps word positions (e.g., Adj+Noun -> Noun+Adj).
    - **Overriding**: Updates meanings for specific particles or structures (e.g., "de" -> "của").
- **Prompts included**: Includes AI system prompts to automatically generate rules from samples.

## Configuration (`grammar.yaml`)

Rules are defined in `grammar.yaml`. High-ranking rules take precedence.

```yaml
- desc: "Adj + Noun -> Noun + Adj"
  alias: "common_adj_noun"
  rank: 2                  # 0-4 priority
  match_pos: ["a", "n"]    # Pattern: Adjective, Noun
  match_tok: ["", ""]      # Match any word ("")
  reordering: [1, 0]       # VI: Output index 1 then index 0
```

## Installation

1.  **Install Crystal**: Follow instructions at [crystal-lang.org](https://crystal-lang.org/install/).
2.  Clone the repository:
    ```bash
    git clone https://github.com/chi-vi/qt_plus.git
    cd qt_plus/cv_translator
    ```
3.  Install dependencies:
    ```bash
    shards install
    ```

## Usage

### Run the Demo
A sample script `demo.cr` is provided to demonstrate various grammatical structures (Passive voice, Location, Possessive, etc.).

```bash
crystal run demo.cr
```

**Output Example:**
```text
Original: 美丽(a):đẹp 花(n):hoa
Translated: 花(n):hoa 美丽(a):đẹp (Hoa Đẹp)
```

### Run Tests
```bash
crystal spec
```

### Automatic Rule Generation
We provide a System Prompt to help you generate rules using LLMs (like Gemini/GPT).

1.  Open `src/prompts/rule_generator.md`.
2.  Paste the prompt into your LLM chat.
3.  Provide Chinese Token/POS data as input to get valid YAML rules.

## Development

- `src/cv_translator/engine.cr`: Main DP translation logic.
- `src/cv_translator/rule.cr`: Rule definition and scoring.
- `grammar.yaml`: The database of translation rules.

## Contributing

1.  Fork it (<https://github.com/chi-vi/qt_plus/fork>)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new Pull Request
