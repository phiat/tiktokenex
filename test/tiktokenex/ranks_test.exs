defmodule Tiktokenex.RanksTest do
  use ExUnit.Case, async: true

  alias Tiktokenex.Ranks

  describe "load/1" do
    test "loads cl100k_base ranks" do
      ranks = Ranks.load(:cl100k_base)
      assert is_map(ranks)
      assert map_size(ranks) > 100_000
    end

    test "loads o200k_base ranks" do
      ranks = Ranks.load(:o200k_base)
      assert is_map(ranks)
      assert map_size(ranks) > 100_000
    end

    test "ranks contain expected byte sequences" do
      ranks = Ranks.load(:cl100k_base)
      # Single bytes should be present
      assert Map.has_key?(ranks, <<0>>)
      assert Map.has_key?(ranks, "a")
    end

    test "returns same map on repeated calls (cached)" do
      ranks1 = Ranks.load(:cl100k_base)
      ranks2 = Ranks.load(:cl100k_base)
      assert ranks1 === ranks2
    end
  end

  describe "inverse/1" do
    test "inverse maps rank to bytes" do
      inv = Ranks.inverse(:cl100k_base)
      assert is_map(inv)
      assert is_binary(Map.get(inv, 0))
    end

    test "inverse is consistent with load" do
      ranks = Ranks.load(:cl100k_base)
      inv = Ranks.inverse(:cl100k_base)

      Enum.take(ranks, 10)
      |> Enum.each(fn {bytes, rank} ->
        assert Map.get(inv, rank) == bytes
      end)
    end
  end

  describe "supported_encodings/0" do
    test "returns list of atoms" do
      encodings = Ranks.supported_encodings()
      assert :cl100k_base in encodings
      assert :o200k_base in encodings
    end
  end
end
