defmodule DIN do
  @typedoc """
  A map where all the keys match with the expected input keys and all values are lists cotaining DIN functions.

  ## Examples

      %{
        username: [DIN.string(), DIN.min(10)],
        age: [DIN.number(), DIN.min(18)],
        address: [
          DIN.map(%{
            street: [DIN.string(), DIN.min(10)],
            number: [DIN.number()]
          })
        ]
      }
  """
  @type schema :: map()

  @typedoc """
  A map where all the keys are atoms and values matches a given schema
  """
  @type normalized_map :: map()

  @typedoc """
  A map containing relevant data about validation errors on a given key

    - name: The reference to the attribute that fails in the validation
    - reason (string): The reason why the validation failed
    - reason (list): Used in case of map validations, contain validation error for child attributes

  ## Examples

        %{name: :username, reason: "must have at least 4 characters"}

        %{
         name: :address,
         reason: [
           %{name: :street, reason: "must have at least 10 characters"},
           %{name: :number, reason: "must be a number"}
         ]
        }
  """
  @type validation_error :: %{name: String.t(), reason: String.t() | list(validation_error)}

  @typedoc """
  A list containing all the schema validation errors for the given input
  """
  @type errors_list :: list(validation_error)

  # NORMALIZATION CORE

  @spec normalize(map, schema) :: {:error, errors_list()} | {:ok, normalized_map()}
  @doc """
  Normalize the input using the given schema

  ## Examples
      iex> schema = %{
      ...> username: [DIN.string(), DIN.min(5)],
      ...> age: [DIN.number(), DIN.min(18)],
      ...> address: [DIN.map(%{street: [DIN.string(), DIN.min(10)]})] }
      iex> input = %{
      ...> "username" => "oliveigah",
      ...> "age" => 26,
      ...> "address" => %{"street" => "Baker Street"} }
      iex> DIN.normalize(input, schema)
      {:ok, %{username: "oliveigah", age: 26, address: %{street: "Baker Street"}}}
  """
  def normalize(input, schema) do
    case do_normalize(input, Map.to_list(schema), %{}, []) do
      {normalized_input, []} ->
        {:ok, normalized_input}

      {_normalized_input, errors_list} ->
        {:error, errors_list}
    end
  end

  defp do_normalize(_input, [], acc_input, acc_errors), do: {acc_input, acc_errors}

  defp do_normalize(input, [{key, validation_fun_list} | schema_rest], acc_input, acc_errors) do
    value = get_value_from_input(key, input)
    {normalized_value, errors_list} = execute_functions(validation_fun_list, value)

    case filter_errors_by_type(:type_error, errors_list) do
      [] ->
        case filter_errors_by_type(:validation_error, errors_list) do
          [] ->
            new_normalized_input = Map.put(acc_input, key, normalized_value)
            do_normalize(input, schema_rest, new_normalized_input, acc_errors)

          validation_errors ->
            new_errors = parse_errors(key, validation_errors) ++ acc_errors
            do_normalize(input, schema_rest, acc_input, new_errors)
        end

      type_errors ->
        new_errors = parse_errors(key, type_errors) ++ acc_errors
        do_normalize(input, schema_rest, acc_input, new_errors)
    end
  end

  defp execute_functions(func_list, val), do: do_execute_functions(func_list, val, [])

  defp do_execute_functions([], val, errors), do: {val, errors}

  defp do_execute_functions([fun | fun_rest], val, errors) do
    case fun.(val) do
      :ok ->
        do_execute_functions(fun_rest, val, errors)

      {:ok, new_val} ->
        do_execute_functions(fun_rest, new_val, errors)

      error ->
        do_execute_functions(fun_rest, val, [error | errors])
    end
  end

  defp get_value_from_input(key, input),
    do: Map.get(input, Atom.to_string(key)) || Map.get(input, key) || :din_val_not_found

  defp parse_errors(key, errors_list),
    do: Enum.map(errors_list, fn {_, msg} -> %{name: key, reason: msg} end)

  defp filter_errors_by_type(type, errrors_list),
    do: Enum.filter(errrors_list, fn result -> match?({^type, _}, result) end)

  # TYPES
  @doc scope: :type
  @doc """
  Validates that the input value is a string.

  ## Examples
      iex> schema = %{username: [DIN.string()]}
      iex> input = %{ "username" => "oliveigah"}
      iex> DIN.normalize(input, schema)
      {:ok, %{username: "oliveigah"}}

      iex> schema = %{username: [DIN.string()]}
      iex> input = %{ "username" => 123}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :username, reason: "must be a string"}]}
  """
  defdelegate string(), to: DIN.Types
  @doc scope: :type
  @doc """
  Validates that the input value is a number.

  ## Examples
      iex> schema = %{age: [DIN.number()]}
      iex> input = %{"age" => 26}
      iex> DIN.normalize(input, schema)
      {:ok, %{age: 26}}

      iex> schema = %{money: [DIN.number()]}
      iex> input = %{"money" => 12.95}
      iex> DIN.normalize(input, schema)
      {:ok, %{money: 12.95}}

      iex> schema = %{age: [DIN.number()]}
      iex> input = %{ "age" => "123"}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :age, reason: "must be a number"}]}
  """
  defdelegate number(), to: DIN.Types
  @doc scope: :type
  @doc """
  Validates that the input value is a map and its value matches the given schema.

  ## Examples
      iex> schema = %{address: [DIN.map(%{street: [DIN.string()]})]}
      iex> input = %{ "address" => %{"street" => "Baker street"}}
      iex> DIN.normalize(input, schema)
      {:ok, %{address: %{street: "Baker street"}}}

      iex> schema = %{address: [DIN.map(%{street: [DIN.string()]})]}
      iex> input = %{ "address" => "baker street"}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :address, reason: "must be an object"}]}

      iex> schema = %{address: [DIN.map(%{street: [DIN.string()]})]}
      iex> input = %{ "address" => %{"street" => 12}}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :address, reason: [%{name: :street, reason: "must be a string"}]}]}
  """
  defdelegate map(schema), to: DIN.Types

  # TRANSFORMATIONS

  # VALIDATIONS
  @doc scope: :validation
  @doc """
  Validates that the input has at least the given value.

  The behavior of this functions varies accordingly to input types.

  - String: Validates input length
  - Number: Validates input value

  ## Examples
      iex> schema = %{username: [DIN.min(5)]}
      iex> input = %{ "username" => "abcde"}
      iex> DIN.normalize(input, schema)
      {:ok, %{username: "abcde"}}

      iex> schema = %{username: [DIN.min(5)]}
      iex> input = %{ "username" => "abcd"}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :username, reason: "must have at least 5 characters"}]}

      iex> schema = %{age: [DIN.min(8)]}
      iex> input = %{ "age" => 9}
      iex> DIN.normalize(input, schema)
      {:ok, %{age: 9}}

      iex> schema = %{age: [DIN.min(8)]}
      iex> input = %{ "age" => 7}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :age, reason: "must be greater than or equal to 8"}]}

      iex> schema = %{age: [DIN.min(8)]}
      iex> input = %{ "age" => :not_valid_type}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :age, reason: "validation function not applicable for the input type"}]}
  """
  defdelegate min(min_val), to: DIN.Validations.Min, as: :execute
  @doc scope: :validation
  @doc """
  Validates that the input has at maximum the given value.

  The behavior of this functions varies accordingly to input types.

  - String: Validates input length
  - Number: Validates input value

  ## Examples
      iex> schema = %{username: [DIN.max(5)]}
      iex> input = %{ "username" => "abcde"}
      iex> DIN.normalize(input, schema)
      {:ok, %{username: "abcde"}}

      iex> schema = %{username: [DIN.max(5)]}
      iex> input = %{ "username" => "abcdef"}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :username, reason: "must have at maximum 5 characters"}]}

      iex> schema = %{age: [DIN.max(7)]}
      iex> input = %{ "age" => 7}
      iex> DIN.normalize(input, schema)
      {:ok, %{age: 7}}

      iex> schema = %{age: [DIN.max(7)]}
      iex> input = %{ "age" => 8}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :age, reason: "must be lesser than or equal to 7"}]}

      iex> schema = %{age: [DIN.max(8)]}
      iex> input = %{ "age" => :not_valid_type}
      iex> DIN.normalize(input, schema)
      {:error, [%{name: :age, reason: "validation function not applicable for the input type"}]}
  """
  defdelegate max(max_val), to: DIN.Validations.Max, as: :execute
end
