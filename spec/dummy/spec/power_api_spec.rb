require "rails_helper"

describe PowerApi::ExampleClass do
  before do
    helper_example
  end

  it "says hi" do
    expect(described_class.say_hi).to eq("Hello Platanus developer!")
  end

  it "uses fixtures" do
    file = fixture_file_upload("image.png", "image/png")
    expect(file.original_filename).to eq("image.png")
  end
end
