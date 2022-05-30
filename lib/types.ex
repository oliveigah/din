defmodule DIN.Types do
  @moduledoc false
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

  def map(schema) do
    fn val ->
      if is_map(val) do
        case DIN.normalize(val, schema) do
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
end
