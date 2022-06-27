defmodule DIN.CoreTest do
  use ExUnit.Case
  import DIN.TestHelpers

  doctest DIN

  test "should properly validate types" do
    schema_func = %{
      a: [DIN.string()],
      b: [DIN.number()],
      c: [DIN.map()],
      d: [DIN.list()]
    }

    schema_list = %{
      a: [type: :string],
      b: [type: :number],
      c: [type: :map],
      d: [type: :list]
    }

    input = %{
      "a" => "a",
      "b" => 1,
      "c" => %{"a" => 1},
      "d" => [1, 2, 3]
    }

    wrong_input = %{
      "a" => 1,
      "b" => "a",
      "c" => [1, 2, 3],
      "d" => %{"a" => 1}
    }

    assert {:ok, %{a: "a", b: 1, c: %{"a" => 1}, d: [1, 2, 3]}} =
             DIN.normalize(input, schema_func)

    assert {:ok, %{a: "a", b: 1, c: %{"a" => 1}, d: [1, 2, 3]}} =
             DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input, schema_func)
    assert %{name: :a, reason: "must be a string"} in error_list
    assert %{name: :d, reason: "must be a list"} in error_list
    assert %{name: :c, reason: "must be an object"} in error_list
    assert %{name: :b, reason: "must be a number"} in error_list
    assert length(error_list) === 4

    assert {:error, error_list} = DIN.normalize(wrong_input, schema_list)
    assert %{name: :a, reason: "must be a string"} in error_list
    assert %{name: :d, reason: "must be a list"} in error_list
    assert %{name: :c, reason: "must be an object"} in error_list
    assert %{name: :b, reason: "must be a number"} in error_list
    assert length(error_list) === 4
  end

  test "should properly validate min values" do
    schema_func = %{
      a: [DIN.string(), DIN.min(3)],
      b: [DIN.number(), DIN.min(3)],
      c: [DIN.list(), DIN.min(3)]
    }

    schema_list = %{
      a: [type: :string, min: 3],
      b: [type: :number, min: 3],
      c: [type: :list, min: 3]
    }

    input = %{
      "a" => "abc",
      "b" => 3,
      "c" => [1, 2, 3]
    }

    wrong_input = %{
      "a" => "a",
      "b" => 2,
      "c" => [1]
    }

    assert {:ok, %{a: "abc", b: 3, c: [1, 2, 3]}} = DIN.normalize(input, schema_func)
    assert {:ok, %{a: "abc", b: 3, c: [1, 2, 3]}} = DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input, schema_func)
    assert %{name: :a, reason: "must have at least 3 characters"} in error_list
    assert %{name: :b, reason: "must be greater than or equal to 3"} in error_list
    assert %{name: :c, reason: "must contain at least 3 items"} in error_list
    assert length(error_list) === 3

    assert {:error, error_list} = DIN.normalize(wrong_input, schema_list)
    assert %{name: :a, reason: "must have at least 3 characters"} in error_list
    assert %{name: :b, reason: "must be greater than or equal to 3"} in error_list
    assert %{name: :c, reason: "must contain at least 3 items"} in error_list
    assert length(error_list) === 3
  end

  test "should properly validate max values" do
    schema_func = %{
      a: [DIN.string(), DIN.max(3)],
      b: [DIN.number(), DIN.max(3)],
      c: [DIN.list(), DIN.max(3)]
    }

    schema_list = %{
      a: [type: :string, max: 3],
      b: [type: :number, max: 3],
      c: [type: :list, max: 3]
    }

    input = %{
      "a" => "abc",
      "b" => 3,
      "c" => [1, 2, 3]
    }

    wrong_input = %{
      "a" => "abcd",
      "b" => 4,
      "c" => [1, 2, 3, 4, 5]
    }

    assert {:ok, %{a: "abc", b: 3, c: [1, 2, 3]}} = DIN.normalize(input, schema_func)
    assert {:ok, %{a: "abc", b: 3, c: [1, 2, 3]}} = DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input, schema_func)
    assert %{name: :a, reason: "must have at maximum 3 characters"} in error_list
    assert %{name: :b, reason: "must be less than or equal to 3"} in error_list
    assert %{name: :c, reason: "must contain a maximum of 3 items"} in error_list
    assert length(error_list) === 3

    assert {:error, error_list} = DIN.normalize(wrong_input, schema_list)
    assert %{name: :a, reason: "must have at maximum 3 characters"} in error_list
    assert %{name: :b, reason: "must be less than or equal to 3"} in error_list
    assert %{name: :c, reason: "must contain a maximum of 3 items"} in error_list
    assert length(error_list) === 3
  end

  test "should validate arbitrary nested data" do
    schema_func = %{
      a: [
        DIN.map(),
        DIN.schema(%{
          b: [DIN.string(), DIN.min(3)]
        })
      ]
    }

    schema_list = %{
      a: [type: :map, schema: %{b: [type: :string, min: 3]}]
    }

    input = %{"a" => %{"b" => "abc"}}

    wrong_input_1 = %{"a" => %{"b" => "ab"}}
    wrong_input_2 = %{"a" => %{"c" => "abc"}}
    wrong_input_3 = %{"a" => 123}

    assert {:ok, %{a: %{b: "abc"}}} = DIN.normalize(input, schema_func)
    assert {:ok, %{a: %{b: "abc"}}} = DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input_1, schema_list)

    assert [%{name: :b, reason: "must have at least 3 characters"}] =
             find_error(error_list, [:a, :b])

    assert {:error, error_list} = DIN.normalize(wrong_input_2, schema_list)

    assert [%{name: :b, reason: "must be a string"}] = find_error(error_list, [:a, :b])

    assert {:error, error_list} = DIN.normalize(wrong_input_3, schema_list)

    assert [%{name: :a, reason: "must be an object"}] = find_error(error_list, [:a])
  end

  test "should validate arbitrary nested data 2" do
    schema_func = %{
      a: [
        DIN.map(),
        DIN.schema(%{
          b: [
            DIN.map(),
            DIN.schema(%{
              c: [DIN.string(), DIN.min(3)]
            })
          ]
        })
      ]
    }

    schema_list = %{
      a: [
        type: :map,
        schema: %{
          b: [
            type: :map,
            schema: %{
              c: [type: :string, min: 3]
            }
          ]
        }
      ]
    }

    input = %{"a" => %{"b" => %{"c" => "abc"}}}

    wrong_input_1 = %{"a" => %{"b" => %{"c" => "ab"}}}
    wrong_input_2 = %{"a" => %{"b" => %{"d" => "abc"}}}
    wrong_input_3 = %{"a" => %{"b" => 123}}

    assert {:ok, %{a: %{b: %{c: "abc"}}}} = DIN.normalize(input, schema_func)
    assert {:ok, %{a: %{b: %{c: "abc"}}}} = DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input_1, schema_list)

    assert [%{name: :c, reason: "must have at least 3 characters"}] =
             find_error(error_list, [:a, :b, :c])

    assert {:error, error_list} = DIN.normalize(wrong_input_2, schema_list)

    assert [%{name: :c, reason: "must be a string"}] = find_error(error_list, [:a, :b, :c])

    assert {:error, error_list} = DIN.normalize(wrong_input_3, schema_list)

    assert [%{name: :b, reason: "must be an object"}] = find_error(error_list, [:a, :b])
  end

  test "should validate items on a list" do
    schema_func = %{
      a: [DIN.list(), DIN.schema([DIN.number(), DIN.min(2)])]
    }

    schema_list = %{
      a: [type: :list, schema: [type: :number, min: 2]]
    }

    input = %{"a" => [2, 3, 4, 5]}

    wrong_input_1 = %{"a" => [1, 2, 0]}

    assert {:ok, %{a: [2, 3, 4, 5]}} = DIN.normalize(input, schema_func)
    assert {:ok, %{a: [2, 3, 4, 5]}} = DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input_1, schema_list)

    assert [%{name: "index_1", reason: "must be greater than or equal to 2"}] =
             find_error(error_list, [:a, "index_1"])

    assert [%{name: "index_3", reason: "must be greater than or equal to 2"}] =
             find_error(error_list, [:a, "index_3"])

    assert length(error_list) === 1

    [%{name: :a, reason: error_list}] = error_list

    assert length(error_list) === 2
  end

  test "should validate items on a list 2" do
    schema_func = %{
      a: [
        DIN.list(),
        DIN.schema([
          DIN.map(),
          DIN.schema(%{
            b: [DIN.number(), DIN.min(2)]
          })
        ])
      ]
    }

    schema_list = %{
      a: [
        type: :list,
        schema: [
          type: :map,
          schema: %{b: [type: :number, min: 2]}
        ]
      ]
    }

    input = %{"a" => [%{"b" => 2}, %{"b" => 3}, %{"b" => 4}, %{"b" => 5}]}

    wrong_input_1 = %{"a" => [%{"b" => 1}, %{"b" => 2}, %{"b" => 0}]}

    assert {:ok, %{a: [%{b: 2}, %{b: 3}, %{b: 4}, %{b: 5}]}} = DIN.normalize(input, schema_func)
    assert {:ok, %{a: [%{b: 2}, %{b: 3}, %{b: 4}, %{b: 5}]}} = DIN.normalize(input, schema_list)

    assert {:error, error_list} = DIN.normalize(wrong_input_1, schema_list)

    assert [%{name: :b, reason: "must be greater than or equal to 2"}] =
             find_error(error_list, [:a, "index_1", :b])

    assert [%{name: :b, reason: "must be greater than or equal to 2"}] =
             find_error(error_list, [:a, "index_3", :b])

    assert length(error_list) === 1

    [%{name: :a, reason: error_list}] = error_list

    assert length(error_list) === 2
  end
end
