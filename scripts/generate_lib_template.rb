#!/usr/bin/env ruby
# generates Xcode 4 project templates
require 'erb'
require 'find'
require 'pathname'
require 'fileutils'
require 'optparse'



 # This hash will hold all of the options
 # parsed from the command-line by
 # OptionParser.
 options = {}
 
 optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: generate_template.rb [options] template_file1 template_file2 ..."
 
   # Define the options, and what they do
   options[:verbose] = false
   opts.on( '-v', '--verbose', 'Output more information' ) do
     options[:verbose] = true
   end
   
   options[:source_dir] = "./GeminiSDK"
   opts.on('-s', '--source DIR', 'Source directory') do |dir|
     options[:source_dir] = dir
   end
   
   options[:output_dir] = "./TemplateBuild"
   opts.on('-o', '--output DIR', 'Output directory') do |dir|
     options[:output_dir] = dir
   end
 
   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
 end
 
 # Parse the command-line
 optparse.parse!
 
 
 ARGV.each do|f|
   puts "Processing template file #{f}..."
   
   templateFile = File.new(f)
   @template = templateFile.sysread(templateFile.size)
   @template_processor = ERB.new(@template, 0, "%<>")
   templateFile.close
   
   lib_name = f.rpartition('_')[2]
   
   puts "Processing library #{lib_name}" if options[:verbose]
   
   @input_dir = options[:source_dir] 
   
   puts "Processing directory #{@input_dir}/libs/#{lib_name}" if options[:verbose]

   @paths = []

   b = binding
   
   Find.find("#{@input_dir}/libs/#{lib_name}") do |path|
     puts path if options[:verbose]
     if !FileTest.directory?(path) && !path.end_with?('TemplateInfo.plist')
       path.sub!(@input_dir, '')
       @paths << path
       puts "Adding #{path}" if options[:verbose]
     end
   end

   output = @template_processor.result(b)

   outpath = options[:output_dir] + "/lib_#{lib_name}.xctemplate"
   puts "OUTPATH: #{outpath}" if options[:verbose]
   FileUtils.mkdir_p("#{outpath}/libs")
   

   # copy files to output path
   lib_path = "#{@input_dir}/libs/#{lib_name}"
   license_path = "#{@input_dir}/libs/LICENSE_#{lib_name}.txt"
   FileUtils.cp_r(lib_path, "#{outpath}/libs/#{lib_name}")
   FileUtils.cp(license_path, "#{outpath}/libs")

   # write out the template plist
   outfile = File.new(outpath + "/TemplateInfo.plist", "w")
   outfile << output
   outfile.close

 end
