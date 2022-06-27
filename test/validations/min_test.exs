defmodule DIN.Validations.MinTest do
  use ExUnit.Case

  alias DIN.Test.CustomType

  doctest DIN

  describe "min for bitstrings" do
    test "should return a {priority, function} that returns :ok if string has at least X characters otherwise {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Min.execute(5)
      expected_error_message = "must have at least 5 characters"

      assert :ok = fun.("abcde")
      assert :ok = fun.("abcdef")
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.("abcd")
      assert priority_fun.("abc") === 5
    end
  end

  describe "min for numbers" do
    test "should return a {priority, function} that returns :ok if number is greater than or equal to X otherwise {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Min.execute(5)
      expected_error_message = "must be greater than or equal to 5"

      assert :ok = fun.(5.0)
      assert :ok = fun.(5.1)
      assert :ok = fun.(5)
      assert :ok = fun.(6)
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.(4)
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.(4.5)
      assert priority_fun.(123) === 5
      assert priority_fun.(12.3) === 5
    end
  end

  describe "min for not implemented types" do
    test "should return a {priority, function} that always returns {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Min.execute(5)
      expected_error_message = "validation function not applicable for the input type"

      assert {{:validation_error, ^expected_error_message}, :continue} = fun.(:invalid_type)
      assert priority_fun.(:invalid_type) === 5
    end
  end

  describe "min for custom types" do
    test "should be implementable" do
      {priority_fun, fun} = DIN.Validations.Min.execute(5)

      assert :ok = fun.(%CustomType{some_field: 5})

      assert {{:validation_error, "some custom error message"}, :continue} =
               fun.(%CustomType{some_field: 4})

      assert priority_fun.(%CustomType{some_field: 4}) === 5
    end
  end

  describe "min for lists" do
    test "should return a function that returns :ok if list has at least X items otherwise {{:validation_error, message}, :continue}" do
      {priority_fun, fun} = DIN.Validations.Min.execute(5)
      expected_error_message = "must contain at least 5 items"

      assert :ok = fun.([1, 2, 3, 4, 5])
      assert :ok = fun.([1, 2, 3, 4, 5, 6])
      assert {{:validation_error, ^expected_error_message}, :continue} = fun.([1, 2, 3, 4])
      assert priority_fun.([1]) === 5
    end
  end
end
