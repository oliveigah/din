defmodule DIN.TestHelpers do
  def find_error(error_list, [target_name | []]) do
    error_list
    |> Enum.filter(fn %{name: name, reason: reason} ->
      name === target_name && is_bitstring(reason)
    end)
  end

  def find_error(error_list, [name | rest]) do
    error_list
    |> Enum.filter(&match?(%{name: ^name, reason: _}, &1))
    |> Enum.filter(&is_list(&1.reason))
    |> Enum.flat_map(& &1.reason)
    |> find_error(rest)
  end
end
