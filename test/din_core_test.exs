defmodule DIN.CoreTest do
  use ExUnit.Case

  import DIN.TestHelpers

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

  test "should return all validation errors {:error, error_list}" do
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
      "username" => "tes",
      "age" => 4,
      "metadata" => %{
        "name" => "teste",
        "some_number" => 101.2,
        "address" => %{
          "street" => "da",
          "number" => 20
        }
      }
    }

    assert {:error, error_list} = DIN.normalize(input, schema)

    assert %{name: :username, reason: "must have at least 4 characters"} in error_list
    assert %{name: :age, reason: "must be greater than or equal to 5"} in error_list
    assert %{name: :metadata, reason: metadata_errors} = find_error(error_list, :metadata)

    assert %{name: :some_number, reason: "must be lesser than or equal to 12"} in metadata_errors
    assert %{name: :name, reason: "must have at least 10 characters"} in metadata_errors
    assert %{name: :address, reason: address_errors} = find_error(metadata_errors, :address)

    assert %{name: :street, reason: "must have at least 10 characters"} in address_errors
    assert %{name: :number, reason: "must be greater than or equal to 80"} in address_errors
  end

  test "should return only type errors {:error, error_list}" do
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
      "username" => 3,
      "age" => "some_age",
      "metadata" => 123
    }

    assert {:error, error_list} = DIN.normalize(input, schema)

    assert %{name: :username, reason: "must be a string"} in error_list
    assert %{name: :metadata, reason: "must be an object"} in error_list
    assert %{name: :age, reason: "must be a number"} in error_list
  end

  test "should return mixed errors {:error, error_list}" do
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
      "username" => "tes",
      "age" => "invalid_data",
      "metadata" => %{
        "name" => "teste",
        "some_number" => 101.2,
        "address" => "invalid_data"
      }
    }

    assert {:error, error_list} = DIN.normalize(input, schema)

    assert %{name: :username, reason: "must have at least 4 characters"} in error_list
    assert %{name: :age, reason: "must be a number"} in error_list
    assert %{name: :metadata, reason: metadata_errors} = find_error(error_list, :metadata)

    assert %{name: :some_number, reason: "must be lesser than or equal to 12"} in metadata_errors
    assert %{name: :name, reason: "must have at least 10 characters"} in metadata_errors
    assert %{name: :address, reason: "must be an object"} in metadata_errors
  end
end
