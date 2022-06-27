defmodule DIN.Validations.Min do
  @moduledoc false
  def execute(min_val),
    do: {
      &DIN.Validations.Protocols.Min.priority(&1),
      &DIN.Validations.Protocols.Min.validate(&1, min_val)
    }
end

defprotocol DIN.Validations.Protocols.Min do
  @fallback_to_any true

  @spec validate(any(), pos_integer()) ::
          :ok | DIN.Helper.validation_error_t()
  def validate(val, min_val)

  @spec priority(any()) :: integer()
  def priority(val)
end

defimpl DIN.Validations.Protocols.Min, for: Any do
  def validate(_, _),
    do:
      DIN.Helper.validation_error("validation function not applicable for the input type", false)

  def priority(_), do: 5
end

defimpl DIN.Validations.Protocols.Min, for: BitString do
  def validate(val, min_val) do
    if String.length(val) >= min_val,
      do: :ok,
      else: DIN.Helper.validation_error("must have at least #{min_val} characters", false)
  end

  def priority(_), do: 5
end

defimpl DIN.Validations.Protocols.Min, for: [Integer, Float] do
  def validate(val, min_val) do
    if val >= min_val,
      do: :ok,
      else: DIN.Helper.validation_error("must be greater than or equal to #{min_val}", false)
  end

  def priority(_), do: 5
end

defimpl DIN.Validations.Protocols.Min, for: List do
  def validate(val, min_val) do
    if Enum.count_until(val, min_val) >= min_val,
      do: :ok,
      else: DIN.Helper.validation_error("must contain at least #{min_val} items", false)
  end

  def priority(_), do: 5
end
