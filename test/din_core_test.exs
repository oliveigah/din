defmodule DIN.CoreTest do
  use ExUnit.Case
  doctest DIN

  test "should return a tuple {:ok, normalized_map}" do
    schema = %{
      username: [DIN.string(), DIN.min(4)],
      age: [DIN.number(), DIN.min(5)],
      metadata: [
        DIN.map(%{
          name: [DIN.string(), DIN.min(10)],
          some_number: [DIN.number(), DIN.max(12)],
          address: [
            DIN.map(%{
              street: [DIN.string(), DIN.min(10)],
              number: [DIN.number(), DIN.min(80)]
            })
          ]
        })
      ]
    }

    input = %{
      "username" => "teste",
      "age" => 8,
      "metadata" => %{
        "name" => "testeasdasdasdasdasdas",
        "some_number" => 10.2,
        "address" => %{
          "street" => "dasuh12312313123asdfa",
          "number" => 220
        }
      }
    }

    assert {:ok,
            %{
              age: 8,
              metadata: %{
                address: %{number: 220, street: "dasuh12312313123asdfa"},
                name: "testeasdasdasdasdasdas",
                some_number: 10.2
              },
              username: "teste"
            }} = DIN.normalize(input, schema)
  end
end
