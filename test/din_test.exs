defmodule DINTest do
  use ExUnit.Case
  doctest DIN


  # TODO: HOW TO WORK WITH ARBITRARY NESTED DATA??
  test "test" do
    schema = %{
      username: [DIN.string(), DIN.min(4)],
      age: [DIN.number(), DIN.min(5)],
      metadata: [
        DIN.map(%{
          name: [DIN.string(), DIN.min(10)]
          some_number: [DIN.number(), DIN.min(8)]
          address: DIN.map(%{
            street:  [DIN.string(), DIN.min(10)],
            number: [DIN.number(), DIN.min(8)]
          })
        })
      ]
    }

    %{
      "username" => "test",
      "age" => 8
    }
    |> DIN.normalize(schema)
    |> IO.inspect()
  end
end
