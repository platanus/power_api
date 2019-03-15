guard :rspec, cmd: "bundle exec rspec" do
  spec_dic = "spec/dummy/spec"
  # RSpec files
  watch("spec/spec_helper.rb") { spec_dic }
  watch("spec/rails_helper.rb") { spec_dic }
  watch(%r{^spec\/dummy\/spec\/support\/(.+)\.rb$}) { spec_dic }
  watch(%r{^spec\/dummy\/spec\/.+_spec\.rb$})
  # Engine files
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/dummy/spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/dummy/spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb)$}) { |m| "spec/dummy/spec/#{m[1]}#{m[2]}_spec.rb" }
  # Dummy app files
  watch(%r{^spec\/dummy\/app/(.+)\.rb$}) { |m| "spec/dummy/spec/#{m[1]}_spec.rb" }
  watch(%r{^spec\/dummy\/app/(.*)(\.erb)$}) { |m| "spec/dummy/spec/#{m[1]}#{m[2]}_spec.rb" }
end
