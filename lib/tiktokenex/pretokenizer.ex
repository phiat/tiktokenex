defmodule Tiktokenex.Pretokenizer do
  @moduledoc """
  Regex-based pre-tokenization that splits text into chunks before BPE.

  Each encoding uses a specific regex pattern defined by OpenAI's tiktoken.
  The regex is compiled once at module load time.
  """

  # cl100k_base pattern from tiktoken (GPT-4, GPT-3.5-turbo)
  @cl100k_pattern ~r/(?i:'s|'t|'re|'ve|'m|'ll|'d)|[^\r\n\p{L}\p{N}]?\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]+[\r\n]*|\s*[\r\n]+|\s+(?!\S)|\s+/u

  # o200k_base pattern from tiktoken (GPT-4o). Uses Unicode subcategories
  # for script-aware word splitting (Lu/Lt/Lm/Lo/Ll/M), attaches contractions
  # as optional suffixes to word matches, and includes "/" in punctuation trails.
  @o200k_pattern ~r/[^\r\n\p{L}\p{N}]?[\p{Lu}\p{Lt}\p{Lm}\p{Lo}\p{M}]*[\p{Ll}\p{Lm}\p{Lo}\p{M}]+(?i:'s|'t|'re|'ve|'m|'ll|'d)?|[^\r\n\p{L}\p{N}]?[\p{Lu}\p{Lt}\p{Lm}\p{Lo}\p{M}]+[\p{Ll}\p{Lm}\p{Lo}\p{M}]*(?i:'s|'t|'re|'ve|'m|'ll|'d)?|\p{N}{1,3}| ?[^\s\p{L}\p{N}]+[\r\n\/]*|\s*[\r\n]+|\s+(?!\S)|\s+/u

  @doc """
  Splits text into pre-tokenized chunks using the encoding's regex pattern.

  Returns a list of binary strings, each of which will be independently
  BPE-encoded.
  """
  @spec split(binary(), atom()) :: [binary()]
  def split(text, encoding \\ :cl100k_base)

  def split("", _encoding), do: []

  def split(text, :cl100k_base) do
    Regex.scan(@cl100k_pattern, text)
    |> List.flatten()
  end

  def split(text, :o200k_base) do
    Regex.scan(@o200k_pattern, text)
    |> List.flatten()
  end
end
