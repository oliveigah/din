defmodule DIN.TestHelpers do
  def find_error(error_list, name),
    do: Enum.find(error_list, &match?(%{name: ^name, reason: _}, &1))
end
