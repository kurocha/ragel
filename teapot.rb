
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "1.0.0"

define_target "ragel" do |target|
	target.build do
		source_files = Files::Directory.join(target.package.path, "ragel-6.10")
		cache_prefix = environment[:build_prefix] / environment.checksum + "ragel"
		package_files = environment[:install_prefix] / "bin/ragel"
		
		copy source: source_files, prefix: cache_prefix
		
		configure prefix: cache_prefix do
			run! "autoreconf", "-fiv", chdir: cache_prefix
			
			run! "./configure",
				"--prefix=#{environment[:install_prefix]}",
				"--disable-dependency-tracking",
				"--enable-shared=no",
				"--enable-static=yes",
				*environment[:configure],
				chdir: cache_prefix
		end
		
		make prefix: cache_prefix, package_files: package_files
	end
	
	target.depends :platform
	
	target.depends "Build/Files"
	target.depends "Build/Make"
	
	target.provides "Convert/Ragel" do
		define Rule, "convert.ragel-file" do
			input :source_file, pattern: /\.rl/
			output :destination_path
			
			parameter :ragel, optional: true do |path, arguments|
				arguments[:ragel] = path || (environment[:install_prefix] + "bin/ragel")
			end
			
			apply do |arguments|
				mkpath File.dirname(arguments[:destination_path])
				
				run!(arguments[:ragel], "-G2", arguments[:source_file], "-o", arguments[:destination_path])
			end
		end
	end
end

define_configuration "ragel" do |configuration|
	configuration.public!
	
	configuration.require "platforms"
	configuration.require "build-make"
end
