desc "Build a gem"
task :gem do
	sh "gem build money.gemspec"
end

task "Generate RDoc documentation"
task :rdoc do
	sh "hanna README.rdoc lib -U"
end

task :upload => :rdoc do
	sh "scp -r doc/* rubyforge.org:/var/www/gforge-projects/money/"
end

desc "Run unit tests"
task :test do
	ruby "-S spec -f s -c test/*_spec.rb"
end
