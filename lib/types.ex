defmodule DIN.Types do
  @moduledoc false

  import DIN.Helper

  def string() do
    fn val ->
      if is_bitstring(val), do: :ok, else: validation_error("must be a string", true)
    end
    |> add_priority(0)
  end

  def number() do
    fn val ->
      if is_number(val), do: :ok, else: validation_error("must be a number", true)
    end
    |> add_priority(0)
  end

  def map() do
    fn val ->
      if is_map(val), do: :ok, else: validation_error("must be an object", true)
    end
    |> add_priority(0)
  end

  def list() do
    fn val ->
      if is_list(val), do: :ok, else: validation_error("must be a list", true)
    end
    |> add_priority(0)
  end

  defp add_priority(fun, priority), do: {priority, fun}
end
