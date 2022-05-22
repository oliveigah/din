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
  @doc scope: :core
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
    results = Enum.map(validation_fun_list, fn fun -> fun.(value) end)
    normalized_value = get_value_from_validations(value, results)

    case filter_validations_by_type(:type_error, results) do
      [] ->
        case filter_validations_by_type(:validation_error, results) do
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

  defp get_value_from_input(key, input),
    do: Map.get(input, Atom.to_string(key)) || Map.get(input, key) || :din_val_not_found

  defp parse_errors(key, errors_list),
    do: Enum.map(errors_list, fn {_, msg} -> %{name: key, reason: msg} end)

  defp filter_validations_by_type(type, errrors_list),
    do: Enum.filter(errrors_list, fn result -> match?({^type, _}, result) end)

  defp get_value_from_validations(current_value, results) do
    case Enum.find(results, fn e -> match?({:ok, _}, e) end) do
      nil -> current_value
      {:ok, normalized_val} -> normalized_val
    end
  end

  # TYPES
  @doc scope: :type
  def string() do
    fn val ->
      if is_bitstring(val), do: :ok, else: {:type_error, "must be a string"}
    end
  end

  @doc scope: :type
  def number() do
    fn val ->
      if is_number(val), do: :ok, else: {:type_error, "must be a number"}
    end
  end

  @doc scope: :type
  def map(schema) do
    fn val ->
      if is_map(val) do
        case normalize(val, schema) do
          {:ok, normalized_val} ->
            {:ok, normalized_val}

          {:error, errors} ->
            {:validation_error, errors}
        end
      else
        {:type_error, "must be an object"}
      end
    end
  end

  # VALIDATIONS
  defp do_min(val, min_val) when is_number(val) do
    if val >= min_val,
      do: :ok,
      else: {:validation_error, "must be greater than or equal to #{min_val}"}
  end

  defp do_min(val, min_val) when is_bitstring(val) do
    if String.length(val) >= min_val,
      do: :ok,
      else: {:validation_error, "must have at least #{min_val} characters"}
  end

  defp do_min(_, _),
    do: {:validation_error, "validation function not applicable for the type"}

  @doc scope: :validation
  def min(min_val), do: &do_min(&1, min_val)
end
