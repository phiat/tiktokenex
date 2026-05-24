defmodule Tiktokenex do
  @moduledoc """
  Pure Elixir BPE tokenizer compatible with OpenAI's tiktoken.

  Supports `:cl100k_base` and `:o200k_base` encodings.

  ## Examples

      iex> tokens = Tiktokenex.encode("hello world")
      iex> is_list(tokens) and Enum.all?(tokens, &is_integer/1)
      true

      iex> Tiktokenex.decode(Tiktokenex.encode("hello world"))
      "hello world"

      iex> Tiktokenex.count("hello world")
      2
  """

  alias Tiktokenex.{BPE, Pretokenizer, Ranks}

  @default_encoding :cl100k_base

  @doc """
  Encodes text into a list of token IDs.

  ## Examples

      iex> tokens = Tiktokenex.encode("hello")
      iex> is_list(tokens)
      true
  """
  @spec encode(binary(), atom()) :: [non_neg_integer()]
  def encode(text, encoding \\ @default_encoding) when is_binary(text) do
    ranks = Ranks.load(encoding)

    text
    |> Pretokenizer.split(encoding)
    |> Enum.flat_map(&BPE.encode(&1, ranks))
  end

  @doc """
  Decodes a list of token IDs back into a binary string.

  The encoding must match the one used to produce the token IDs.
  Raises `ArgumentError` if a token ID is not found in the encoding's vocabulary.

  ## Examples

      iex> Tiktokenex.decode([15339, 1917])
      "hello world"
  """
  @spec decode([non_neg_integer()], atom()) :: binary()
  def decode(token_ids, encoding \\ @default_encoding) when is_list(token_ids) do
    inverse = Ranks.inverse(encoding)

    token_ids
    |> Enum.map_join(fn id ->
      case Map.fetch(inverse, id) do
        {:ok, bytes} -> bytes
        :error -> raise ArgumentError, "unknown token ID #{id} for encoding #{encoding}"
      end
    end)
  end

  @doc """
  Encodes text and returns the token byte-string chunks.

  Each chunk corresponds to one BPE token. Useful for visualizing
  how text is tokenized.

  ## Examples

      iex> chunks = Tiktokenex.encode_to_chunks("hello world")
      iex> is_list(chunks) and Enum.all?(chunks, &is_binary/1)
      true
  """
  @spec encode_to_chunks(binary(), atom()) :: [binary()]
  def encode_to_chunks(text, encoding \\ @default_encoding) when is_binary(text) do
    ranks = Ranks.load(encoding)
    inverse = Ranks.inverse(encoding)

    text
    |> Pretokenizer.split(encoding)
    |> Enum.flat_map(fn chunk ->
      chunk
      |> BPE.encode(ranks)
      |> Enum.map(fn id -> Map.fetch!(inverse, id) end)
    end)
  end

  @doc """
  Returns the number of tokens in the text.

  More efficient than `encode/2 |> length/1` as it avoids building
  the full token ID list.

  ## Examples

      iex> Tiktokenex.count("hello world")
      2
  """
  @spec count(binary(), atom()) :: non_neg_integer()
  def count(text, encoding \\ @default_encoding) when is_binary(text) do
    ranks = Ranks.load(encoding)

    text
    |> Pretokenizer.split(encoding)
    |> Enum.reduce(0, fn chunk, acc ->
      acc + length(BPE.encode(chunk, ranks))
    end)
  end

  @doc """
  Returns the vocabulary size for the given encoding.

  ## Examples

      iex> Tiktokenex.vocab_size() > 100_000
      true
  """
  @spec vocab_size(atom()) :: non_neg_integer()
  def vocab_size(encoding \\ @default_encoding) do
    encoding |> Ranks.load() |> map_size()
  end
end
