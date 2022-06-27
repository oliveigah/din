defmodule DIN.Validations.Max do
  @moduledoc false
  def execute(max_val),
    do: {
      &DIN.Validations.Protocols.Max.priority(&1),
      &DIN.Validations.Protocols.Max.validate(&1, max_val)
    }
end

defprotocol DIN.Validations.Protocols.Max do
  @fallback_to_any true

  @spec validate(any(), pos_integer()) :: :ok | DIN.Helper.validation_error_t()
  def validate(val, max_val)

  @spec priority(any()) :: integer()
  def priority(val)
end

defimpl DIN.Validations.Protocols.Max, for: Any do
  def validate(_, _),
    do:
      DIN.Helper.validation_error("validation function not applicable for the input type", false)

  def priority(_), do: 5
end

defimpl DIN.Validations.Protocols.Max, for: BitString do
  def validate(val, max_val) do
    if String.length(val) <= max_val,
      do: :ok,
      else: DIN.Helper.validation_error("must have at maximum #{max_val} characters", false)
  end

  def priority(_), do: 5
end

defimpl DIN.Validations.Protocols.Max, for: [Integer, Float] do
  def validate(val, max_val) do
    if val <= max_val,
      do: :ok,
      else: DIN.Helper.validation_error("must be less than or equal to #{max_val}", false)
  end

  def priority(_), do: 5
end

defimpl DIN.Validations.Protocols.Max, for: List do
  def validate(val, max_val) do
    if Enum.count_until(val, max_val + 1) <= max_val,
      do: :ok,
      else: DIN.Helper.validation_error("must contain a maximum of #{max_val} items", true)
  end

  def priority(_), do: 1
end
