defmodule DIN.TypeTest do
  use ExUnit.Case
  doctest DIN

  test "should return a functions that returns :ok if string otherwise {:type_error, message} " do
    fun = DIN.string()
    assert :ok = fun.("some_string")
    assert {:type_error, "must be a string"} = fun.(123)
    assert {:type_error, "must be a string"} = fun.(%{a: 1})
    assert {:type_error, "must be a string"} = fun.('123')
    assert {:type_error, "must be a string"} = fun.(true)
    assert {:type_error, "must be a string"} = fun.([1, 2, 3])
  end

  test "should return a functions that returns :ok if number otherwise {:type_error, message} " do
    fun = DIN.number()
    assert :ok = fun.(123)
    assert {:type_error, "must be a number"} = fun.("123")
    assert {:type_error, "must be a number"} = fun.(%{a: 1})
    assert {:type_error, "must be a number"} = fun.('123')
    assert {:type_error, "must be a number"} = fun.(true)
    assert {:type_error, "must be a number"} = fun.([1, 2, 3])
  end

  test "should return a functions that returns {:ok, normalized_map} if map otherwise {:type_error, message} " do
    fun = DIN.map(%{a: [DIN.number()]})
    assert {:ok, %{a: 1}} = fun.(%{"a" => 1})
    assert {:type_error, "must be an object"} = fun.("%{a: 1}")
    assert {:type_error, "must be an object"} = fun.(123)
    assert {:type_error, "must be an object"} = fun.('123')
    assert {:type_error, "must be an object"} = fun.(true)
    assert {:type_error, "must be an object"} = fun.([1, 2, 3])
  end
end
