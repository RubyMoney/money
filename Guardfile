guard "spork" do
  watch("Gemfile")
  watch("Gemfile.lock")
  watch("spec/spec_helper.rb") { :rspec }
end

guard "rspec", :cli => "--drb" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb")  { "spec" }
end
