defmodule DIN.Validations.MaxTest do
  use ExUnit.Case

  alias DIN.Test.CustomType

  doctest DIN

  describe "max for bitstrings" do
    test "should return a {priority, function} that returns :ok if string has at maximum X characters otherwise {{{:validation_error, message}, :continue}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Max.execute(5)
      expected_error_message = "must have at maximum 5 characters"

      assert :ok = fun.("abcd")
      assert :ok = fun.("abcde")
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.("abcdef")
      assert priority_fun.("ab") === 5
    end
  end

  describe "max for numbers" do
    test "should return {priority, function} that returns :ok if number is less than or equal to X otherwise {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Max.execute(5)
      expected_error_message = "must be less than or equal to 5"

      assert :ok = fun.(4)
      assert :ok = fun.(5)
      assert :ok = fun.(4.5)
      assert :ok = fun.(5.0)
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.(6)
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.(5.1)
      assert priority_fun.(4) === 5
      assert priority_fun.(4.5) === 5
    end
  end

  describe "max for not implemented types" do
    test "should return {priority, function} that always returns {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Max.execute(5)
      expected_error_message = "validation function not applicable for the input type"

      assert {{:validation_error, ^expected_error_message}, :continue} = fun.(:invalid_type)
      assert priority_fun.(:invalid_type) === 5
    end
  end

  describe "max for custom types" do
    test "should be implementable" do
      {priority_fun, fun} = DIN.Validations.Max.execute(5)

      assert :ok = fun.(%CustomType{some_field: 4})
      assert {:validation_error, "some custom error message"} = fun.(%CustomType{some_field: 6})
      assert priority_fun.(%CustomType{some_field: 6}) === 5
    end
  end

  describe "max for lists" do
    test "should return {priority, function} that returns :ok if list has less than or equal to X items otherwise {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Max.execute(5)
      expected_error_message = "must contain a maximum of 5 items"

      assert :ok = fun.([1, 2, 3, 4])
      assert :ok = fun.([1, 2, 3, 4, 5])
      assert {{:validation_error, ^expected_error_message}, :halt} = fun.([1, 2, 3, 4, 5, 6])
      assert priority_fun.([1, 2, 3]) === 1
    end
  end
end
