defmodule DIN.Test.CustomType do
  defstruct [:some_field]

  defimpl DIN.Validations.Protocols.Max, for: DIN.Test.CustomType do
    def validate(%{some_field: val}, max_val) do
      if val <= max_val,
        do: :ok,
        else: {:validation_error, "some custom error message"}
    end
  end

  defimpl DIN.Validations.Protocols.Min, for: DIN.Test.CustomType do
    def validate(%{some_field: val}, min_val) do
      if val >= min_val,
        do: :ok,
        else: {:validation_error, "some custom error message"}
    end
  end
end
