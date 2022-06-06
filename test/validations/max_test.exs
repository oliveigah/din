defmodule DIN.Validations.MaxTest do
  use ExUnit.Case

  alias DIN.Test.CustomType

  doctest DIN

  describe "max for bitstrings" do
    test "should return a function that returns :ok if string has at maximum X characters otherwise {:validation_error, message}" do
      fun = DIN.Validations.Max.execute(5)
      expected_error_message = "must have at maximum 5 characters"

      assert :ok = fun.("abcd")
      assert :ok = fun.("abcde")
      assert {:validation_error, ^expected_error_message} = fun.("abcdef")
    end
  end

  describe "max for numbers" do
    test "should return a function that returns :ok if number is less than or equal to X otherwise {:validation_error, message}" do
      fun = DIN.Validations.Max.execute(5)
      expected_error_message = "must be lesser than or equal to 5"

      assert :ok = fun.(4)
      assert :ok = fun.(5)
      assert :ok = fun.(4.5)
      assert :ok = fun.(5.0)
      assert {:validation_error, ^expected_error_message} = fun.(6)
      assert {:validation_error, ^expected_error_message} = fun.(5.1)
    end
  end

  describe "max for not implemented types" do
    test "should return a function that always returns {:validation_error, message}" do
      fun = DIN.Validations.Max.execute(5)
      expected_error_message = "validation function not applicable for the input type"

      assert {:validation_error, ^expected_error_message} = fun.(:invalid_type)
    end
  end

  describe "max for custom types" do
    test "should be implementable" do
      fun = DIN.Validations.Max.execute(5)

      assert :ok = fun.(%CustomType{some_field: 4})
      assert {:validation_error, "some custom error message"} = fun.(%CustomType{some_field: 6})
    end
  end
end
