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

  def map() do
    fn val ->
      if is_map(val), do: {:ok, val}, else: {:type_error, "must be an object"}
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

  def list() do
    fn val ->
      if is_list(val), do: {:ok, val}, else: {:type_error, "must be a list"}
    end
  end

  def list(validations) do
    # TODO: HOW TO MAKE THIS CODE MORE SAFE AND EFFICIENT?
    fn val ->
      if is_list(val) do
        input =
          val
          |> Enum.with_index(fn e, i -> {"index_#{i + 1}", e} end)
          |> Map.new()

        schema =
          input
          |> Enum.map(fn {key, _} -> {key, validations} end)

        case DIN.normalize(input, schema) do
          {:ok, normalized_val} ->
            result = Enum.map(normalized_val, fn {_k, v} -> v end)
            {:ok, result}

          {:error, errors} ->
            {:validation_error, errors}
        end
      else
        {:type_error, "must be a list"}
      end
    end
  end
end
