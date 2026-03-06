defmodule Tiktokenex.BPETest do
  use ExUnit.Case, async: true

  alias Tiktokenex.BPE

  describe "encode/2" do
    test "empty binary returns empty list" do
      ranks = %{}
      assert BPE.encode(<<>>, ranks) == []
    end

    test "single byte returns its rank" do
      ranks = %{<<104>> => 71}
      assert BPE.encode(<<104>>, ranks) == [71]
    end

    test "merges adjacent pair with lowest rank" do
      # Simulate: bytes "ab" where a=0, b=1, ab=2
      ranks = %{
        "a" => 10,
        "b" => 11,
        "ab" => 5
      }

      assert BPE.encode("ab", ranks) == [5]
    end

    test "multi-step merge" do
      # a=10, b=11, c=12, ab=3, abc=2
      ranks = %{
        "a" => 10,
        "b" => 11,
        "c" => 12,
        "ab" => 3,
        "abc" => 2
      }

      assert BPE.encode("abc", ranks) == [2]
    end

    test "partial merge when not all pairs merge" do
      # a=10, b=11, c=12, ab=5 (no "bc" or "abc")
      ranks = %{
        "a" => 10,
        "b" => 11,
        "c" => 12,
        "ab" => 5
      }

      assert BPE.encode("abc", ranks) == [5, 12]
    end

    test "whole chunk is a single token" do
      ranks = %{"hello" => 42}
      assert BPE.encode("hello", ranks) == [42]
    end

    test "works with real ranks for known tokens" do
      ranks = Tiktokenex.Ranks.load(:cl100k_base)
      # "hello" as pre-tokenized chunk
      result = BPE.encode("hello", ranks)
      assert is_list(result)
      assert Enum.all?(result, &is_integer/1)
    end
  end
end
