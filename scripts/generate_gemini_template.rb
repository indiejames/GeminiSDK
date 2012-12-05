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
   
   options[:template_dir] = "./templates"
   opts.on('-t', '--templates DIR', 'Source directory') do |dir|
     options[:template_dir] = dir
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
 
 # create template dir
 outpath = options[:output_dir] + "/gemini.xctemplate"
 puts "OUTPATH: #{outpath}" if options[:verbose]
 FileUtils.mkdir_p(outpath)
 FileUtils.cp("#{options[:template_dir]}/TemplateInfo.plist.gemini",  "#{outpath}/TemplateInfo.plist")
 # copy icon file for template
 FileUtils.cp("#{options[:template_dir]}/TemplateIcon.icns",  "#{outpath}/TemplateIcon.icns")

 # copy source files
 Dir.entries(options[:source_dir]).each do |path|
   if !FileTest.directory?(path) && path =~ /.*(m|mm|h|fsh|vsh|icns|pch|lua|png)$/
     
     FileUtils.cp("#{options[:source_dir]}/#{path}", outpath)
     puts "Adding #{path}" if options[:verbose]
   end
 end


