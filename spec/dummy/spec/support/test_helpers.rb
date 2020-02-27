module TestHelpers
  extend ActiveSupport::Concern

  included do
    def mock_file_content(expected_path, content_lines)
      allow(File).to receive(:readlines).with(
        File.join(Rails.root, expected_path)
      ).and_return(content_lines)
    end
  end
end
