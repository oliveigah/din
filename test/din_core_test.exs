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
      ],
      contacts: [
        DIN.list([
          DIN.map(%{
            full_name: [DIN.string(), DIN.min(5)],
            phone: [DIN.number(), DIN.max(10)]
          })
        ]),
        DIN.max(3)
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
      },
      "contacts" => [
        %{"full_name" => "abcdef", phone: 1},
        %{"full_name" => "abcdefg", phone: 2},
        %{"full_name" => "abcdefgh", phone: 3}
      ]
    }

    assert {:ok,
            %{
              age: 8,
              metadata: %{
                address: %{number: 220, street: "dasuh12312313123asdfa"},
                name: "testeasdasdasdasdasdas",
                some_number: 10.2
              },
              username: "teste",
              contacts: contacts
            }} = DIN.normalize(input, schema)

    assert %{full_name: "abcdef", phone: 1} in contacts
    assert %{full_name: "abcdefg", phone: 2} in contacts
    assert %{full_name: "abcdefgh", phone: 3} in contacts
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
      ],
      contacts: [
        DIN.list([
          DIN.map(%{
            full_name: [DIN.string(), DIN.min(5)],
            phone: [DIN.number(), DIN.max(10)]
          })
        ]),
        DIN.max(3)
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
      },
      "contacts" => [
        %{"full_name" => "abc", phone: 1},
        %{"full_name" => "abcdefg", phone: 20},
        %{"full_name" => "abcdefgh", phone: "abc"},
        %{"full_name" => "abcdefgh", phone: 4}
      ]
    }

    assert {:error, error_list} = DIN.normalize(input, schema)

    assert %{name: :username, reason: "must have at least 4 characters"} in error_list
    assert %{name: :age, reason: "must be greater than or equal to 5"} in error_list
    assert %{name: :contacts, reason: "must contain a maximum of 3 items"} in error_list

    assert %{name: :some_number, reason: "must be less than or equal to 12"} in find_error(
             error_list,
             [:metadata, :some_number]
           )

    assert %{name: :name, reason: "must have at least 10 characters"} in find_error(
             error_list,
             [:metadata, :name]
           )

    assert %{name: :street, reason: "must have at least 10 characters"} in find_error(
             error_list,
             [:metadata, :address, :street]
           )

    assert %{name: :number, reason: "must be greater than or equal to 80"} in find_error(
             error_list,
             [:metadata, :address, :number]
           )

    assert %{name: :full_name, reason: "must have at least 5 characters"} in find_error(
             error_list,
             [:contacts, "index_1", :full_name]
           )

    assert %{name: :phone, reason: "must be less than or equal to 10"} in find_error(
             error_list,
             [:contacts, "index_2", :phone]
           )

    assert %{name: :phone, reason: "must be a number"} in find_error(
             error_list,
             [:contacts, "index_3", :phone]
           )
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
      ],
      contacts: [
        DIN.list([
          DIN.map(%{
            full_name: [DIN.string(), DIN.min(5)],
            phone: [DIN.number(), DIN.max(10)]
          })
        ]),
        DIN.max(3)
      ]
    }

    input = %{
      "username" => 3,
      "age" => "some_age",
      "metadata" => 123,
      "contacts" => "abc"
    }

    assert {:error, error_list} = DIN.normalize(input, schema)

    assert %{name: :username, reason: "must be a string"} in error_list
    assert %{name: :metadata, reason: "must be an object"} in error_list
    assert %{name: :age, reason: "must be a number"} in error_list
    assert %{name: :contacts, reason: "must be a list"} in error_list
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
      ],
      contacts: [
        DIN.list([
          DIN.number(),
          DIN.max(3)
        ])
      ]
    }

    input = %{
      "username" => "tes",
      "age" => "invalid_data",
      "metadata" => %{
        "name" => "teste",
        "some_number" => 101.2,
        "address" => "invalid_data"
      },
      "contacts" => [1, "a", 2, 10]
    }

    assert {:error, error_list} = DIN.normalize(input, schema)

    assert %{name: :username, reason: "must have at least 4 characters"} in error_list
    assert %{name: :age, reason: "must be a number"} in error_list

    assert %{name: :some_number, reason: "must be less than or equal to 12"} in find_error(
             error_list,
             [:metadata, :some_number]
           )

    assert %{name: :name, reason: "must have at least 10 characters"} in find_error(
             error_list,
             [:metadata, :name]
           )

    assert %{name: :address, reason: "must be an object"} in find_error(
             error_list,
             [:metadata, :address]
           )

    assert %{name: "index_2", reason: "must be a number"} in find_error(
             error_list,
             [:contacts, "index_2"]
           )

    assert %{name: "index_4", reason: "must be less than or equal to 3"} in find_error(
             error_list,
             [:contacts, "index_4"]
           )
  end
end
