defmodule DIN.Helper do
  @moduledoc false

  def validation_error(message, true = _halt?), do: {{:validation_error, message}, :halt}
  def validation_error(message, false = _halt?), do: {{:validation_error, message}, :continue}

  def din_function(fun, priority) when is_function(fun), do: {priority, fun}
end
