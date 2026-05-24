# Tiktokenex

Pure Elixir BPE tokenizer compatible with OpenAI's [tiktoken](https://github.com/openai/tiktoken). No NIFs, no Python, no external dependencies.

Supports `cl100k_base` (GPT-4, GPT-3.5) and `o200k_base` (GPT-4o) encodings.

## Usage

```elixir
# Encode text to token IDs
Tiktokenex.encode("Hello, world!")
#=> [9906, 11, 1917, 0]

# Decode back to text
Tiktokenex.decode([9906, 11, 1917, 0])
#=> "Hello, world!"

# Count tokens
Tiktokenex.count("Hello, world!")
#=> 4

# See the BPE chunks
Tiktokenex.encode_to_chunks("Hello, world!")
#=> ["Hello", ",", " world", "!"]

# Use o200k_base encoding
Tiktokenex.encode("Hello", :o200k_base)
```

## Installation

Add to your `mix.exs` as a git or path dependency:

```elixir
def deps do
  [
    # git
    {:tiktokenex, git: "https://github.com/phiat/tiktokenex.git"},
    # …or a sibling working copy for development
    {:tiktokenex, path: "../tiktokenex"}
  ]
end
```

BPE rank files are not tracked in git — fetch them once with the bundled justfile recipe:

```bash
git clone https://github.com/phiat/tiktokenex.git
cd tiktokenex
just setup        # mix deps.get + downloads cl100k_base + o200k_base into priv/ranks/
```

Or download manually:

```bash
mkdir -p priv/ranks
curl -o priv/ranks/cl100k_base.tiktoken \
  https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken
curl -o priv/ranks/o200k_base.tiktoken \
  https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken
```

## How It Works

1. **Pre-tokenization** (`Pretokenizer`) — splits text using tiktoken's regex patterns into coarse chunks
2. **BPE encoding** (`BPE`) — applies byte-pair encoding merges using rank tables
3. **Rank loading** (`Ranks`) — parses `.tiktoken` rank files, caches in `persistent_term`

The algorithm matches tiktoken's output exactly. See `test/` for reference vectors.

## API

| Function | Description |
|----------|-------------|
| `encode(text, encoding)` | Text to token ID list |
| `decode(ids, encoding)` | Token IDs back to text |
| `encode_to_chunks(text, encoding)` | Text to BPE chunk strings |
| `count(text, encoding)` | Token count |

Default encoding is `:cl100k_base`. Pass `:o200k_base` as the second argument for GPT-4o tokenization.

## Tests

```bash
just check    # mix test + credo + compile-with-warnings-as-errors
just test     # tests only
```

## License

MIT — see [LICENSE](LICENSE).
