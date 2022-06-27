defmodule DIN.Helper do
  @moduledoc false
  @type validation_error_t :: {{:validation_error, String.t()}, :continue | :halt}

  def validation_error(message, true = _halt?),
    do: {{:validation_error, message}, :halt}

  def validation_error(message, false = _halt?),
    do: {{:validation_error, message}, :continue}
end
