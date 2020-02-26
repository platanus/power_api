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

    def mock_file_content(expected_path, content_lines)
      allow(File).to receive(:readlines).with(
        File.join(Rails.root, expected_path)
      ).and_return(content_lines)
    end
  end
end
