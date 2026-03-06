# Tiktokenex - Pure Elixir BPE Tokenizer
# Run `just` to see all available commands

default:
    @just --list

# --- Development ---

setup:
    mix deps.get

build:
    mix compile

console:
    iex -S mix

# --- Quality ---

check: test lint compile-check

test *args='':
    mix test {{ args }}

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
    @echo "Downloading cl100k_base..."
    curl -sL "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken" -o priv/ranks/cl100k_base.tiktoken
    @echo "Downloading o200k_base..."
    curl -sL "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken" -o priv/ranks/o200k_base.tiktoken
    @echo "Done. Files in priv/ranks/"

# --- Beads ---

issues:
    bd list

ready:
    bd ready

stats:
    bd stats
