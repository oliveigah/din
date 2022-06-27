defmodule DIN.TypeTest do
  use ExUnit.Case

  doctest DIN

  test "should return {priority, function} that returns :ok if string otherwise {:validation_error, message} " do
    {0, fun} = DIN.string()
    assert :ok = fun.("some_string")
    assert {{:validation_error, "must be a string"}, :halt} = fun.(123)
    assert {{:validation_error, "must be a string"}, :halt} = fun.(%{a: 1})
    assert {{:validation_error, "must be a string"}, :halt} = fun.('123')
    assert {{:validation_error, "must be a string"}, :halt} = fun.(true)
    assert {{:validation_error, "must be a string"}, :halt} = fun.([1, 2, 3])
  end

  test "should return {priority, function} that returns :ok if number otherwise {:validation_error, message}" do
    {0, fun} = DIN.number()
    assert :ok = fun.(123)
    assert {{:validation_error, "must be a number"}, :halt} = fun.("123")
    assert {{:validation_error, "must be a number"}, :halt} = fun.(%{a: 1})
    assert {{:validation_error, "must be a number"}, :halt} = fun.('123')
    assert {{:validation_error, "must be a number"}, :halt} = fun.(true)
    assert {{:validation_error, "must be a number"}, :halt} = fun.([1, 2, 3])
  end

  test "should return {priority, function} that returns :ok if map otherwise {:validation_error, message}" do
    {0, fun} = DIN.map()
    assert :ok = fun.(%{"a" => 1})
    assert {{:validation_error, "must be an object"}, :halt} = fun.(123)
    assert {{:validation_error, "must be an object"}, :halt} = fun.("123")
    assert {{:validation_error, "must be an object"}, :halt} = fun.('123')
    assert {{:validation_error, "must be an object"}, :halt} = fun.(true)
    assert {{:validation_error, "must be an object"}, :halt} = fun.([1, 2, 3])
  end

  test "should return {priority, function} that returns :ok if list otherwise {:validation_error, message}" do
    {0, fun} = DIN.list()
    assert :ok = fun.([1, 2, 3])
    assert :ok = fun.('123')
    assert {{:validation_error, "must be a list"}, :halt} = fun.(123)
    assert {{:validation_error, "must be a list"}, :halt} = fun.("123")
    assert {{:validation_error, "must be a list"}, :halt} = fun.(true)
    assert {{:validation_error, "must be a list"}, :halt} = fun.(%{"a" => 1})
  end
end
