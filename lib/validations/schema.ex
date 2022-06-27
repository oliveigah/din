defmodule DIN.Validations.Schema do
  def execute(schema) do
    {
      &DIN.Validations.Protocols.Schema.priority(&1),
      &DIN.Validations.Protocols.Schema.validate_schema(&1, schema)
    }
  end
end

defprotocol DIN.Validations.Protocols.Schema do
  @fallback_to_any true

  @spec validate_schema(any(), pos_integer()) :: {:ok, any()} | DIN.Helper.validation_error_t()
  def validate_schema(val, schema)

  @spec priority(any()) :: integer()
  def priority(val)
end

defimpl DIN.Validations.Protocols.Schema, for: Any do
  def validate_schema(_, _),
    do:
      DIN.Helper.validation_error(
        "validation function not applicable for the input type",
        false
      )

  def priority(_), do: 2
end

defimpl DIN.Validations.Protocols.Schema, for: Map do
  def validate_schema(val, schema) do
    case DIN.normalize(val, schema) do
      {:ok, normalized_val} ->
        {:ok, normalized_val}

      {:error, errors} ->
        DIN.Helper.validation_error(errors, false)
    end
  end

  def priority(_), do: 2
end

defimpl DIN.Validations.Protocols.Schema, for: List do
  def validate_schema(val, schema) do
    # TODO: MAKE THIS CODE MORE EFFICIENT
    input =
      val
      |> Enum.with_index(fn e, i -> {"index_#{i + 1}", e} end)
      |> Map.new()

    schema =
      input
      |> Enum.map(fn {key, _} -> {key, schema} end)

    case DIN.normalize(input, schema) do
      {:ok, normalized_val} ->
        result = Enum.map(normalized_val, fn {_k, v} -> v end)
        {:ok, result}

      {:error, errors} ->
        DIN.Helper.validation_error(errors, false)
    end
  end

  def priority(_), do: 2
end
