defmodule DIN.TypeTest do
  use ExUnit.Case
  import DIN.TestHelpers
  doctest DIN

  test "should return a function that returns :ok if string otherwise {:type_error, message} " do
    fun = DIN.string()
    assert :ok = fun.("some_string")
    assert {:type_error, "must be a string"} = fun.(123)
    assert {:type_error, "must be a string"} = fun.(%{a: 1})
    assert {:type_error, "must be a string"} = fun.('123')
    assert {:type_error, "must be a string"} = fun.(true)
    assert {:type_error, "must be a string"} = fun.([1, 2, 3])
  end

  test "should return a function that returns :ok if number otherwise {:type_error, message} " do
    fun = DIN.number()
    assert :ok = fun.(123)
    assert {:type_error, "must be a number"} = fun.("123")
    assert {:type_error, "must be a number"} = fun.(%{a: 1})
    assert {:type_error, "must be a number"} = fun.('123')
    assert {:type_error, "must be a number"} = fun.(true)
    assert {:type_error, "must be a number"} = fun.([1, 2, 3])
  end

  describe "map" do
    test "DIN.map/1 should return a function that returns {:ok, normalized_map} if map otherwise {:type_error, message} or {:validation_error, message} " do
      fun = DIN.map(%{a: [DIN.number()]})
      assert {:ok, %{a: 1}} = fun.(%{"a" => 1})
      assert {:type_error, "must be an object"} = fun.("%{a: 1}")
      assert {:type_error, "must be an object"} = fun.(123)
      assert {:type_error, "must be an object"} = fun.('123')
      assert {:type_error, "must be an object"} = fun.(true)
      assert {:type_error, "must be an object"} = fun.([1, 2, 3])

      assert {:validation_error, error_list} = fun.(%{"a" => "b"})
      assert %{name: :a, reason: "must be a number"} in error_list
    end

    test "DIN.map/0 should return a function that returns {:ok, map} if map otherwise {:type_error, message} or {:validation_error, message} " do
      fun = DIN.map()
      assert {:ok, %{"a" => 1}} = fun.(%{"a" => 1})
      assert {:type_error, "must be an object"} = fun.(123)
    end
  end

  describe "list" do
    test "DIN.list/1 should return a function that returns {:ok, normalized_values} if list otherwise {:" do
      fun = DIN.list([DIN.number(), DIN.max(5)])

      assert {:ok, [1, 2, 3]} = fun.([1, 2, 3])

      assert {:validation_error, error_list} = fun.([5, 6, 7])
      assert %{name: "index_2", reason: "must be lesser than or equal to 5"} in error_list
      assert %{name: "index_3", reason: "must be lesser than or equal to 5"} in error_list

      assert {:validation_error, error_list} = fun.(["1", 2, 3])
      assert %{name: "index_1", reason: "must be a number"} in error_list

      fun = DIN.list([DIN.map(%{a: [DIN.number(), DIN.min(5)]})])

      assert {:ok, [%{a: 5}, %{a: 6}, %{a: 7}]} = fun.([%{"a" => 5}, %{"a" => 6}, %{"a" => 7}])

      assert {:validation_error, error_list} = fun.([%{"a" => "3"}, %{"a" => 4}, %{"a" => 5}])

      assert [%{name: :a, reason: "must be a number"}] = find_error(error_list, ["index_1", :a])

      item_2_error = find_error(error_list, ["index_2", :a])
      assert [%{name: :a, reason: "must be greater than or equal to 5"}] = item_2_error
    end
  end
end
