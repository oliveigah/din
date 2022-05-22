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
          some_number: [DIN.number(), DIN.min(8)],
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
        "some_number" => 10,
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
                some_number: 10
              },
              username: "teste"
            }} = DIN.normalize(input, schema)
  end

  test "test" do
    schema = %{
      username: [DIN.string(), DIN.min(4)],
      age: [DIN.number(), DIN.min(5)],
      metadata: [
        DIN.map(%{
          name: [DIN.string(), DIN.min(10)],
          some_number: [DIN.number(), DIN.min(8)],
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
      "username" => "24",
      "age" => 2,
      "metadata" => %{
        "name" => "432",
        "some_number" => 2,
        "address" => %{
          "street" => "13",
          "number" => "22"
        }
      }
    }

    DIN.normalize(input, schema) |> IO.inspect()
  end
end
