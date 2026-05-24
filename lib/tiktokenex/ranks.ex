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

  Raises `ArgumentError` for unsupported encodings.
  """
  @spec load(atom()) :: %{binary() => non_neg_integer()}
  def load(encoding) when encoding in @supported_encodings do
    key = {:tiktokenex_ranks, encoding}

    case safe_get(key) do
      :not_found -> load_with_lock(key, fn -> parse_file(encoding) end)
      ranks -> ranks
    end
  end

  def load(encoding) do
    raise ArgumentError,
          "unsupported encoding #{inspect(encoding)}, expected one of #{inspect(@supported_encodings)}"
  end

  @doc """
  Returns the inverse rank map (rank -> token bytes) for decoding.

  Raises `ArgumentError` for unsupported encodings.
  """
  @spec inverse(atom()) :: %{non_neg_integer() => binary()}
  def inverse(encoding) when encoding in @supported_encodings do
    key = {:tiktokenex_ranks_inverse, encoding}

    case safe_get(key) do
      :not_found -> load_with_lock(key, fn -> build_inverse(encoding) end)
      inv -> inv
    end
  end

  def inverse(encoding) do
    raise ArgumentError,
          "unsupported encoding #{inspect(encoding)}, expected one of #{inspect(@supported_encodings)}"
  end

  defp build_inverse(encoding) do
    encoding |> load() |> Map.new(fn {bytes, rank} -> {rank, bytes} end)
  end

  @doc """
  Pre-loads rank maps for all supported encodings into persistent_term.

  Call this at application startup to avoid first-call latency and
  concurrent parsing races.
  """
  @spec warmup() :: :ok
  def warmup do
    Enum.each(@supported_encodings, fn encoding ->
      load(encoding)
      inverse(encoding)
    end)
  end

  @doc """
  Returns the list of supported encodings.
  """
  @spec supported_encodings() :: [atom()]
  def supported_encodings, do: @supported_encodings

  defp safe_get(key) do
    :persistent_term.get(key, :not_found)
  end

  # Double-checked locking around persistent_term:put. Without this, the
  # async warmup task can race with the first encode/decode call — both
  # parse the same file and both put, triggering a redundant global GC.
  defp load_with_lock(key, build_fun) do
    :global.trans({key, self()}, fn ->
      case safe_get(key) do
        :not_found ->
          value = build_fun.()
          :persistent_term.put(key, value)
          value

        value ->
          value
      end
    end)
  end

  defp parse_file(encoding) do
    path = rank_file_path(encoding)

    unless File.exists?(path) do
      raise RuntimeError,
            "rank file not found at #{path}. Run `just download-ranks` to fetch rank files."
    end

    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Map.new(fn line -> parse_line(line, encoding, path) end)
  end

  defp parse_line(line, encoding, path) do
    with [b64_token, rank_str] <- String.split(line, " ", parts: 2),
         {:ok, bytes} <- Base.decode64(b64_token),
         {rank, ""} <- Integer.parse(rank_str) do
      {bytes, rank}
    else
      _ -> raise RuntimeError, "malformed line in #{encoding} file #{path}: #{inspect(line)}"
    end
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
