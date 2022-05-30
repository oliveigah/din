defmodule DIN.Validations.Max do
  @moduledoc false
  def max(max_val), do: &DIN.Validations.Protocols.Max.validate(&1, max_val)
end

defprotocol DIN.Validations.Protocols.Max do
  @fallback_to_any true

  @spec validate(any(), pos_integer()) :: :ok | {:validation_error, String.t()}
  def validate(val, max_val)
end

defimpl DIN.Validations.Protocols.Max, for: Any do
  def validate(_, _),
    do: {:validation_error, "validation function not applicable for the input type"}
end

defimpl DIN.Validations.Protocols.Max, for: BitString do
  def validate(val, max_val) do
    if String.length(val) <= max_val,
      do: :ok,
      else: {:validation_error, "must have at maximum #{max_val} characters"}
  end
end

defimpl DIN.Validations.Protocols.Max, for: [Integer, Float] do
  def validate(val, max_val) do
    if val <= max_val,
      do: :ok,
      else: {:validation_error, "must be lesser than or equal to #{max_val}"}
  end
end
