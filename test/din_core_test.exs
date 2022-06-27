defmodule DIN.CoreTest do
  use ExUnit.Case

  doctest DIN

  test "test types" do
    schema = %{
      a: [DIN.string()],
      b: [DIN.number()],
      c: [DIN.map()],
      d: [DIN.list()]
    }

    input = %{
      "a" => "a",
      "b" => 1,
      "c" => %{"a" => 1},
      "d" => [1, 2, 3]
    }

    assert {:ok, %{a: "a", b: 1, c: %{"a" => 1}, d: [1, 2, 3]}} = DIN.normalize(input, schema)
  end
end
