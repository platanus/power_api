module TestHelpers
  extend ActiveSupport::Concern

  included do
    def create_test_class(&definition)
      remove_test_class
      Object.const_set("TestClass", Class.new(&definition))
    end

    def remove_test_class
      Object.send(:remove_const, :TestClass)
    rescue NameError
      # do nothing
    end
  end
end
