defmodule DIN do
  @typedoc """
  A map where all the keys match with the expected input keys and all values are lists cotaining DIN functions.
  """
  @type schema :: map()

  @typedoc """
  A map where all the keys are atoms and values matches a given schema
  """
  @type normalized_input :: map()

  @typedoc """
  A map containing relevant data about validation errors on a given key

    - name: The reference to the attribute that fails in the validation
    - reason (string): The reason why the validation failed
    - reason (list): Used in case of map or list validations, contain validation error for child attributes

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

  @spec normalize(map, schema) :: {:error, errors_list()} | {:ok, normalized_input()}
  @doc """
  Normalize the input using the given schema
  """
  def normalize(input, schema) do
    case do_normalize(input, parse_schema(schema), %{}, []) do
      {normalized_input, []} ->
        {:ok, normalized_input}

      {_, errors_list} ->
        {:error, errors_list}
    end
  end

  defp do_normalize(_input, [], acc_input, acc_errors), do: {acc_input, List.flatten(acc_errors)}

  defp do_normalize(input, [{key, validation_fun_list} | schema_rest], acc_input, acc_errors) do
    value = get_value_from_input(key, input)
    {normalized_value, errors_list} = execute_functions(validation_fun_list, value)

    case errors_list do
      [] ->
        new_normalized_input = Map.put(acc_input, key, normalized_value)
        do_normalize(input, schema_rest, new_normalized_input, acc_errors)

      errors ->
        # TODO: REMOVE ++ OPERATOR, USE LIST.FLATTEN INSTEAD
        new_errors = [parse_errors(key, errors), acc_errors]
        do_normalize(input, schema_rest, acc_input, new_errors)
    end
  end

  defp execute_functions(func_list, val) do
    func_list
    |> Enum.map(fn
      {priority, func} when is_function(priority) -> {priority.(val), func}
      other -> other
    end)
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    |> Enum.map(&elem(&1, 1))
    |> do_execute_functions(val, [])
  end

  defp do_execute_functions([], val, errors), do: {val, errors}

  defp do_execute_functions([fun | fun_rest], val, errors) do
    case fun.(val) do
      :ok ->
        do_execute_functions(fun_rest, val, errors)

      {:ok, new_val} ->
        do_execute_functions(fun_rest, new_val, errors)

      {error, :continue} ->
        do_execute_functions(fun_rest, val, [error | errors])

      {error, :halt} ->
        do_execute_functions([], val, [error | errors])
    end
  end

  defp get_value_from_input(key, input) when is_atom(key),
    do: Map.get(input, Atom.to_string(key)) || Map.get(input, key) || :din_val_not_found

  defp get_value_from_input(key, input),
    do: Map.get(input, key) || :din_val_not_found

  defp parse_errors(key, errors_list),
    do: Enum.map(errors_list, fn {_, msg} -> %{name: key, reason: msg} end)

  defp parse_schema(schema) do
    Enum.map(schema, fn {key, func_list} ->
      {key, Enum.map(func_list, &parse_schema_func/1)}
    end)
  end

  defp parse_schema_func({:type, :string}), do: string()
  defp parse_schema_func({:type, :map}), do: map()
  defp parse_schema_func({:type, :number}), do: number()
  defp parse_schema_func({:type, :list}), do: list()
  defp parse_schema_func({:min, val}), do: min(val)
  defp parse_schema_func({:max, val}), do: max(val)
  defp parse_schema_func({:schema, schema}), do: schema(schema)

  defp parse_schema_func({priority, fun} = other)
       when is_number(priority) and is_function(fun),
       do: other

  defp parse_schema_func({priority_fun, fun} = other)
       when is_function(priority_fun) and is_function(fun),
       do: other

  defp parse_schema_func({key, _args} = _invalid_arg),
    do: raise("Invalid input validation function #{key}.")

  # TYPES
  @doc """
  Validates that the input value is a string.
  """
  @doc scope: :type
  defdelegate string(), to: DIN.Types

  @doc """
  Validates that the input value is a number.
  """
  @doc scope: :type
  defdelegate number(), to: DIN.Types

  @doc """
  Validates that the input value is a map
  """
  @doc scope: :type
  defdelegate map(), to: DIN.Types

  @doc """
  Validates that the input value is a list
  """
  @doc scope: :type
  defdelegate list(), to: DIN.Types

  # TRANSFORMATIONS

  # VALIDATIONS
  @doc """
  Validates that the input has at least the given value.

  The behavior of this functions varies accordingly to input types.

  - String: Validates input length
  - Number: Validates input value
  - List: Validates list length

  """
  @doc scope: :validation
  defdelegate min(min_val), to: DIN.Validations.Min, as: :execute

  @doc """
  Validates that the input has at maximum the given value.

  The behavior of this functions varies accordingly to input types.

  - String: Validates string length
  - Number: Validates number value
  - List: Validates list length
  """
  @doc scope: :validation
  defdelegate max(max_val), to: DIN.Validations.Max, as: :execute

  @doc scope: :validation
  defdelegate schema(schema), to: DIN.Validations.Schema, as: :execute
end
