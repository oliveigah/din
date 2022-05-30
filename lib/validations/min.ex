defmodule DIN.Validations.Min do
  @moduledoc false
  def min(min_val), do: &DIN.Validations.Protocols.Min.validate(&1, min_val)
end

defprotocol DIN.Validations.Protocols.Min do
  @fallback_to_any true

  @spec validate(any(), pos_integer()) :: :ok | {:validation_error, String.t()}
  def validate(val, min_val)
end

defimpl DIN.Validations.Protocols.Min, for: Any do
  def validate(_, _),
    do: {:validation_error, "validation function not applicable for the input type"}
end

defimpl DIN.Validations.Protocols.Min, for: BitString do
  def validate(val, min_val) do
    if String.length(val) >= min_val,
      do: :ok,
      else: {:validation_error, "must have at least #{min_val} characters"}
  end
end

defimpl DIN.Validations.Protocols.Min, for: [Integer, Float] do
  def validate(val, min_val) do
    if val >= min_val,
      do: :ok,
      else: {:validation_error, "must be greater than or equal to #{min_val}"}
  end
end
