defmodule Tiktokenex.Ranks do
  @moduledoc """
  Loads and caches tiktoken rank files from priv/ranks/.

  Rank files contain base64-encoded token bytes mapped to integer ranks.
  Loaded ranks are cached in `:persistent_term` for fast repeated access.
  """

  @supported_encodings [:cl100k_base, :o200k_base]

  @doc """
  Returns the rank map for the given encoding.

  The rank map is `%{binary() => non_neg_integer()}` where keys are raw
  token bytes and values are their BPE merge ranks.

  Results are cached in `:persistent_term` after first load.
  """
  @spec load(atom()) :: %{binary() => non_neg_integer()}
  def load(encoding) when encoding in @supported_encodings do
    key = {:tiktokenex_ranks, encoding}

    case safe_get(key) do
      :not_found ->
        ranks = parse_file(encoding)
        :persistent_term.put(key, ranks)
        ranks

      ranks ->
        ranks
    end
  end

  @doc """
  Returns the inverse rank map (rank -> token bytes) for decoding.
  """
  @spec inverse(atom()) :: %{non_neg_integer() => binary()}
  def inverse(encoding) when encoding in @supported_encodings do
    key = {:tiktokenex_ranks_inverse, encoding}

    case safe_get(key) do
      :not_found ->
        ranks = load(encoding)
        inv = Map.new(ranks, fn {bytes, rank} -> {rank, bytes} end)
        :persistent_term.put(key, inv)
        inv

      inv ->
        inv
    end
  end

  @doc """
  Returns the list of supported encodings.
  """
  @spec supported_encodings() :: [atom()]
  def supported_encodings, do: @supported_encodings

  defp safe_get(key) do
    :persistent_term.get(key, :not_found)
  end

  defp parse_file(encoding) do
    path = rank_file_path(encoding)

    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Map.new(&parse_line/1)
  end

  defp parse_line(line) do
    [b64_token, rank_str] = String.split(line, " ", parts: 2)
    {Base.decode64!(b64_token), String.to_integer(rank_str)}
  end

  defp rank_file_path(encoding) do
    filename = "#{encoding}.tiktoken"
    Path.join(ranks_dir(), filename)
  end

  defp ranks_dir do
    :tiktokenex
    |> :code.priv_dir()
    |> Path.join("ranks")
  end
end
