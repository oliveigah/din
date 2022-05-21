defmodule DIN do
  def normalize(input, schema) do
    Enum.reduce(
      schema,
      {%{}, []},
      fn {key, fun_list}, {normalized_input, errors} ->
        value = get_value_from_input(key, input)

        results = Enum.map(fun_list, fn fun -> fun.(value) end)

        case filter_errors_by_type(:type_error, results) do
          [] ->
            case filter_errors_by_type(:validation_error, results) do
              [] ->
                {Map.put(normalized_input, key, value), errors}

              validation_errors ->
                {normalized_input, parse_errors(key, validation_errors) ++ errors}
            end

          type_errors ->
            {normalized_input, parse_errors(key, type_errors) ++ errors}
        end
      end
    )
  end

  defp get_value_from_input(key, input),
    do: Map.get(input, Atom.to_string(key)) || Map.get(input, key) || :din_val_not_found

  defp parse_errors(key, errors_list),
    do: Enum.map(errors_list, fn {_, msg} -> %{name: key, reason: msg} end)

  defp filter_errors_by_type(type, errrors_list),
    do: Enum.filter(errrors_list, fn result -> match?({^type, _}, result) end)

  def string() do
    fn val ->
      if is_bitstring(val), do: :ok, else: {:type_error, "must be a string"}
    end
  end

  def number() do
    fn val ->
      if is_number(val), do: :ok, else: {:type_error, "must be a number"}
    end
  end

  def map() do
    fn val ->
      if is_map(val), do: :ok, else: {:type_errors, "must be an object"}
    end
  end

  def min(min_val) do
    fn
      val when is_number(val) ->
        if val >= min_val,
          do: :ok,
          else: {:validation_error, "must be greater than or equal to #{min_val}"}

      val when is_bitstring(val) ->
        if String.length(val) >= min_val,
          do: :ok,
          else: {:validation_error, "must have at least #{min_val} characters"}
    end
  end
end
