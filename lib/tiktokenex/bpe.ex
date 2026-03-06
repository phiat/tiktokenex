defmodule Tiktokenex.BPE do
  @moduledoc """
  Core Byte-Pair Encoding merge algorithm.

  Given a sequence of bytes and a rank map, repeatedly merges the
  lowest-ranked adjacent pair until no more merges are possible.
  """

  @doc """
  Encodes a binary chunk into a list of token rank integers using BPE.

  The input should be a pre-tokenized chunk (output of `Pretokenizer.split/2`).
  Returns a list of integer token IDs (ranks).
  """
  @spec encode(binary(), %{binary() => non_neg_integer()}) :: [non_neg_integer()]
  def encode(chunk, ranks) when is_binary(chunk) and byte_size(chunk) > 0 do
    # Check if the whole chunk is a single token
    case Map.get(ranks, chunk) do
      nil ->
        # Start with individual bytes as pieces
        pieces = for <<byte <- chunk>>, do: <<byte>>
        merge_loop(pieces, ranks)

      rank ->
        [rank]
    end
  end

  def encode(<<>>, _ranks), do: []

  defp merge_loop(pieces, ranks) when length(pieces) <= 1 do
    Enum.map(pieces, fn piece -> Map.fetch!(ranks, piece) end)
  end

  defp merge_loop(pieces, ranks) do
    # Find the pair with the lowest rank
    case find_min_pair(pieces, ranks) do
      nil ->
        # No more mergeable pairs; return ranks for remaining pieces
        Enum.map(pieces, fn piece -> Map.fetch!(ranks, piece) end)

      {min_index, _min_rank} ->
        # Merge the pair at min_index and min_index+1
        pieces = merge_at(pieces, min_index)
        merge_loop(pieces, ranks)
    end
  end

  defp find_min_pair(pieces, ranks) do
    pieces
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Enum.reduce(nil, fn {[a, b], index}, acc ->
      merged = a <> b

      case Map.get(ranks, merged) do
        nil -> acc
        rank -> pick_lower(acc, index, rank)
      end
    end)
  end

  defp pick_lower(nil, index, rank), do: {index, rank}

  defp pick_lower({_idx, current_min} = _acc, index, rank) when rank < current_min,
    do: {index, rank}

  defp pick_lower(acc, _index, _rank), do: acc

  defp merge_at(pieces, index) do
    {before, [a, b | rest]} = Enum.split(pieces, index)
    before ++ [a <> b | rest]
  end
end
