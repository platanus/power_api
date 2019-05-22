describe PowerApi::VersionHelper do
  let(:version_number) { "1" }
  let(:class_definition) do
    Proc.new do
      include PowerApi::VersionHelper

      attr_reader :version_number

      def initialize(version_number)
        @version_number = version_number
      end
    end
  end

  before { create_test_class(&class_definition) }

  subject { TestClass.new(version_number) }

  describe "#version_number" do
    def perform
      subject.version_number
    end

    it { expect(perform).to eq("1") }

    context "with undefined version_number reader" do
      let(:class_definition) do
        Proc.new do
          include PowerApi::VersionHelper

          def initialize(version_number)
            @version_number = version_number
          end
        end
      end

      it { expect { perform }.to raise_error("version_number not implemented") }
    end
  end

  describe "validate_version_number!" do
    def perform
      subject.validate_version_number!(version_number)
    end

    context "with valid version number" do
      let(:version_number) { "1" }

      it { expect(perform).to eq(true) }
    end

    context "with invalid version number" do
      let(:version_number) { "A" }

      it { expect { perform }.to raise_error("invalid version number") }
    end

    context "with zero version number" do
      let(:version_number) { 0 }

      it { expect { perform }.to raise_error("invalid version number") }
    end

    context "with nil version number" do
      let(:version_number) { nil }

      it { expect { perform }.to raise_error("invalid version number") }
    end

    context "with nil blank number" do
      let(:version_number) { "" }

      it { expect { perform }.to raise_error("invalid version number") }
    end

    context "with negative version number" do
      let(:version_number) { -1 }

      it { expect { perform }.to raise_error("invalid version number") }
    end
  end
end
