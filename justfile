# Tiktokenex - Pure Elixir BPE Tokenizer
# Run `just` to see all available commands

default:
    @just --list

# --- Development ---

# Install deps and download BPE rank files
setup:
    mix deps.get
    just download-ranks

build:
    mix compile

console:
    iex -S mix

# Encode text and show token IDs
encode text encoding='cl100k_base':
    mix run -e 'IO.inspect(Tiktokenex.encode("{{text}}", :{{encoding}}))'

# Encode text and show chunks
chunks text encoding='cl100k_base':
    mix run -e 'IO.inspect(Tiktokenex.encode_to_chunks("{{text}}", :{{encoding}}))'

# Count tokens in text
count text encoding='cl100k_base':
    mix run -e 'IO.puts(Tiktokenex.count("{{text}}", :{{encoding}}))'

# Show vocab size for an encoding
vocab encoding='cl100k_base':
    mix run -e 'IO.puts(Tiktokenex.vocab_size(:{{encoding}}))'

# --- Quality ---

check: test lint compile-check

test *args='':
    mix test {{ args }}

# Run a specific test file
t file:
    mix test {{ file }}

cover:
    mix test --cover

lint:
    mix credo --strict

compile-check:
    mix compile --warnings-as-errors

fmt:
    mix format

fmt-check:
    mix format --check-formatted

# --- Ranks ---

# Download tiktoken rank files to priv/ranks/
download-ranks:
    @mkdir -p priv/ranks
    @echo "Downloading cl100k_base..."
    curl -sL "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken" -o priv/ranks/cl100k_base.tiktoken
    @echo "Downloading o200k_base..."
    curl -sL "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken" -o priv/ranks/o200k_base.tiktoken
    @echo "Done. Files in priv/ranks/"

# Verify rank file integrity
verify-ranks:
    @echo "cl100k_base: $(wc -l < priv/ranks/cl100k_base.tiktoken) lines"
    @echo "o200k_base: $(wc -l < priv/ranks/o200k_base.tiktoken) lines"
