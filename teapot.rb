
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "3.0"

define_target "ragel" do |target|
	target.depends :platform
	
	target.depends "Build/Files"
	target.depends "Build/Make"
	
	target.provides "Convert/Ragel" do
		source_files = Files::Directory.join(target.package.path, "ragel-6.10")
		
		build_prefix = cache_prefix = environment[:build_prefix] / environment.checksum + "ragel"
		
		source_prefix = build_prefix + "source"
		install_prefix = build_prefix
		
		ragel_binary_path = install_prefix / "bin/ragel"
		
		copy source: source_files, prefix: source_prefix
		
		configure prefix: source_prefix do
			run! "autoreconf", "-fiv", chdir: source_prefix
			
			run! "./configure",
				"--prefix=#{install_prefix}",
				"--disable-dependency-tracking",
				*environment[:configure],
				chdir: source_prefix
		end
		
		make prefix: source_prefix, package_files: ragel_binary_path
		
		ragel ragel_binary_path
		
		define Rule, "convert.ragel-file" do
			input :source_file, pattern: /\.rl/
			output :destination_path
			
			input :ragel, optional: true do |path, arguments|
				arguments[:ragel] = environment[:ragel]
			end
			
			apply do |arguments|
				mkpath File.dirname(arguments[:destination_path])
				
				run!(arguments[:ragel], "-G2", arguments[:source_file], "-o", arguments[:destination_path])
			end
		end
	end
end

# Configurations

define_configuration "development" do |configuration|
	configuration[:source] = "https://github.com/kurocha/"
	configuration.import "ragel"
	
	configuration.require 'generate-project'
	configuration.require 'generate-travis'
	
	# Provides all the build related infrastructure:
	configuration.require "platforms"
end

define_configuration "ragel" do |configuration|
	configuration.public!
	
	configuration.require "platforms"
	configuration.require "build-make"
end
