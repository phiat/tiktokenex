defmodule Tiktokenex.PretokenizerTest do
  use ExUnit.Case, async: true

  alias Tiktokenex.Pretokenizer

  describe "split/2" do
    test "empty string returns empty list" do
      assert Pretokenizer.split("") == []
    end

    test "splits simple words" do
      chunks = Pretokenizer.split("hello world")
      assert is_list(chunks)
      assert chunks != []
    end

    test "handles contractions" do
      chunks = Pretokenizer.split("I'm happy")
      assert chunks != []
    end

    test "handles numbers" do
      chunks = Pretokenizer.split("12345")
      assert chunks != []
    end

    test "handles newlines" do
      chunks = Pretokenizer.split("hello\nworld")
      assert chunks != []
    end

    test "handles unicode" do
      chunks = Pretokenizer.split("café résumé")
      assert is_list(chunks)
      assert chunks != []
    end

    test "all chunks concatenate to original" do
      text = "Hello, world! I'm testing 123."
      chunks = Pretokenizer.split(text)
      assert IO.iodata_to_binary(chunks) == text
    end
  end
end
