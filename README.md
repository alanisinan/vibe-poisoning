# Environment Poisoning Attacks on LLM Coding Agents

This repository contains the code, scenarios, and evaluation harness for the paper:

> Environment Poisoning Attacks on LLM Coding Agents: A Vibe‑Logic Mismatch Detection Framework

The project studies **environment poisoning**: a passive attack where an adversary with write access to a project repository embeds malicious instructions in documentation, configuration files, code comments, or dependency manifests. Large language model (LLM) coding agents then read this poisoned context and introduce security vulnerabilities without any direct adversarial prompt. The repository also implements a **semantic firewall** that uses a high‑reasoning model to detect vibe‑logic mismatches between the user’s stated intent and the agent’s generated code. [file:28]

> **Note:** During double‑blind review, this repository is kept free of author‑identifying information. Paper and repo content are linked only by the mechanisms described here.

---

## Repository structure

- `scenarios/`  
  Plain‑text files describing the 50 handcrafted attack scenarios used in the paper.  
  Each scenario encodes:
  - `USER_INTENT`: the benign natural‑language task given to the coding agent  
  - `POISONED_CONTEXT`: the malicious content embedded in a repository file  
  - `EXPECTED_SAFE_BEHAVIOR`: the secure implementation the agent should produce  
  - `EXPECTED_ATTACK_BEHAVIOR`: the vulnerable implementation that aligns with the poison [file:28]

- `semantic_proxy.py`  
  Python test harness that:
  - Loads the scenario set
  - Calls the victim coding agent model via the OpenRouter API
  - Invokes the semantic firewall
  - Logs results for later analysis [file:28]

- `firewall.py`  
  Implementation of the **semantic firewall** as a function  
  `semantic_firewall(user_intent: str, agent_response: str) -> Literal["BLOCK", "ALLOW"]`.  
  This matches the definition in Section 4.3 of the paper. [file:28]

- `models/`  
  Configuration stubs for the victim and firewall models, e.g.:
  - Meta Llama 3.1 8B Instruct (victim)  
  - Claude Opus 4.5 (semantic firewall)  
  - Qwen 2.5 7B Instruct (cross‑model comparison) [file:28]

- `analysis/`  
  Scripts/notebooks to:
  - Reproduce Table 1 and Table 2
  - Generate Figures 3–6 (block rates by vector type, cross‑model comparison, etc.) [file:28]

- `telemetry/` (optional)  
  Helper scripts to start Arize Phoenix and collect OpenTelemetry traces, as described in Section 4.1. These are not required to reproduce the main quantitative results. [file:28]

---

## Installation

1. Create and activate a virtual environment.
2. Install dependencies:

```bash
pip install -r requirements.txt
```

The `requirements.txt` file includes:

- An HTTP client library for calling the OpenRouter API
- Basic data/analysis packages (e.g. `pandas`, `numpy`, `scipy`, `matplotlib` or `seaborn`)
- Optional packages for telemetry and Phoenix if you wish to collect traces [file:28]

3. Configure OpenRouter access:

Create a `.env` file (or export an environment variable) with your OpenRouter API key:

```bash
export OPENROUTER_API_KEY="your_api_key_here"
```

The repository does **not** contain any API keys, model weights, or proprietary assets.

---

## Reproducing the main experiments

The repository is designed so that each of the paper’s reported metrics can be reproduced:

### 1. Environment poisoning vs. clean baseline

To run the full 50‑scenario environment‑poisoning experiment with Llama 3.1 8B as the victim model:

```bash
python semantic_proxy.py \
  --victim_model llama3-8b-instruct \
  --firewall_model claude-opus-4-5 \
  --scenarios_dir scenarios \
  --condition poisoned
```

To run the no‑poison baseline (all poisoned instructions removed):

```bash
python semantic_proxy.py \
  --victim_model llama3-8b-instruct \
  --firewall_model claude-opus-4-5 \
  --scenarios_dir scenarios \
  --condition clean
```

These runs reproduce:

- The 34.0% attack success rate under poisoned context and 0% under clean context  
- The 66.0% firewall block rate  
- The causal +34.0 percentage point delta reported in the paper [file:28]

### 2. Block rate by vector type

After running the experiments, compute block rates and attack success per vector type:

```bash
python analysis/vector_breakdown.py \
  --results_path results/llama3_poisoned.json
```

This script regenerates the per‑vector statistics used to produce:

- Configuration vs dependency vs file vs comment vs documentation block rates (Figure 3)  
- Attack success rates by vector (Figure 4) [file:28]

### 3. Cross‑model comparison

To reproduce Table 2 and Figure 6 (Llama 3.1 vs Qwen 2.5):

```bash
python semantic_proxy.py \
  --victim_model qwen2-7b-instruct \
  --firewall_model claude-opus-4-5 \
  --scenarios_dir scenarios \
  --condition poisoned
```

Then:

```bash
python analysis/cross_model.py \
  --llama_results results/llama3_poisoned.json \
  --qwen_results results/qwen2_poisoned.json
```

This recomputes attack success rates, Wilson confidence intervals, and firewall block rates for both models. [file:28]

---

## Semantic firewall interface

The semantic firewall is implemented as described in Section 4.3:

```python
from firewall import semantic_firewall

verdict = semantic_firewall(user_intent, agent_response)
# verdict is either "BLOCK" or "ALLOW"
```

The prompt used for the firewall model asks whether the agent’s action aligns with the user’s security intent and requires exactly one word as output (`BLOCK` or `ALLOW`). This makes the verdict easy to integrate into CI/CD gates or automated review workflows. [file:28]

---

## Telemetry and observability (optional)

To replicate the trace collection setup:

1. Start Phoenix (with a SQLite backend) using:

```bash
bash telemetry/start_phoenix.sh
```

2. Run experiments with telemetry enabled:

```bash
python semantic_proxy.py \
  --victim_model llama3-8b-instruct \
  --firewall_model claude-opus-4-5 \
  --scenarios_dir scenarios \
  --condition poisoned \
  --enable_telemetry
```

This mirrors the OpenTelemetry and Phoenix configuration described in Section 4.5. [file:28]

---

## Code and data availability

- **Scenarios**: All 50 handcrafted scenarios (including five vector types) are distributed in `scenarios/` as plain text.  
- **Code**: The complete evaluation harness, semantic firewall, and analysis scripts are contained in this repository.  
- **Models**: The repository does not ship model weights. Users must access LLMs via OpenRouter or a compatible interface. [file:28]

A tagged release (e.g. `v1.0-paper-submission`) corresponds exactly to the version used for the results reported in the manuscript.

---

## License

Choose an OSI‑approved license that matches your institutional and journal constraints (e.g., MIT, Apache‑2.0) and state it here.
