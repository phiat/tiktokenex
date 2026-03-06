defmodule TiktokenexTest do
  use ExUnit.Case, async: true

  describe "encode/2 and decode/2 round-trip" do
    test "simple ASCII text" do
      text = "hello world"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "empty string" do
      assert Tiktokenex.encode("") == []
      assert Tiktokenex.decode([]) == ""
    end

    test "single character" do
      text = "a"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "single space" do
      text = " "
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "unicode text" do
      text = "こんにちは世界"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "emoji" do
      text = "Hello 🌍🚀"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "newlines" do
      text = "line1\nline2\nline3"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "carriage return and newline" do
      text = "line1\r\nline2"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "mixed content" do
      text = "The quick brown fox jumps over the lazy dog. 123 !@#"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "long text" do
      text = String.duplicate("abcdefghij ", 100)
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "code snippet" do
      text = "def hello do\n  IO.puts(\"world\")\nend"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "contractions" do
      text = "I'm can't won't she's they're we've I'll he'd"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "numbers" do
      text = "12345 67890 3.14159"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end

    test "tabs and mixed whitespace" do
      text = "col1\tcol2\tcol3"
      assert Tiktokenex.decode(Tiktokenex.encode(text)) == text
    end
  end

  describe "encode/2 reference vectors" do
    # These reference values are verified against tiktoken Python:
    # import tiktoken; enc = tiktoken.get_encoding("cl100k_base")
    # enc.encode("hello world") -> [15339, 1917]
    test "hello world encodes to known tokens" do
      assert Tiktokenex.encode("hello world") == [15_339, 1917]
    end

    test "tiktoken encodes to known tokens" do
      assert Tiktokenex.encode("tiktoken") == [83, 1609, 5963]
    end

    test "single letter a" do
      assert Tiktokenex.encode("a") == [64]
    end

    test "space character" do
      assert Tiktokenex.encode(" ") == [220]
    end
  end

  describe "count/2" do
    test "counts tokens for hello world" do
      assert Tiktokenex.count("hello world") == 2
    end

    test "counts tokens for empty string" do
      assert Tiktokenex.count("") == 0
    end

    test "counts tokens for longer text" do
      count = Tiktokenex.count("The quick brown fox jumps over the lazy dog.")
      assert is_integer(count) and count > 0
    end
  end

  describe "encode_to_chunks/2" do
    test "returns list of binaries" do
      chunks = Tiktokenex.encode_to_chunks("hello world")
      assert is_list(chunks)
      assert Enum.all?(chunks, &is_binary/1)
    end

    test "chunks concatenate to original text" do
      text = "hello world"
      chunks = Tiktokenex.encode_to_chunks(text)
      assert IO.iodata_to_binary(chunks) == text
    end

    test "empty string returns empty list" do
      assert Tiktokenex.encode_to_chunks("") == []
    end
  end

  describe "o200k_base encoding" do
    test "round-trip with o200k_base" do
      text = "hello world"
      encoded = Tiktokenex.encode(text, :o200k_base)
      assert is_list(encoded)
      assert Tiktokenex.decode(encoded, :o200k_base) == text
    end

    test "count with o200k_base" do
      count = Tiktokenex.count("hello world", :o200k_base)
      assert is_integer(count) and count > 0
    end
  end
end
