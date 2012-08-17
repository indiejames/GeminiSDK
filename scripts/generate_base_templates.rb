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
   opts.banner = "Usage: generate_base_templates.rb [options]"
 
   # Define the options, and what they do
   options[:verbose] = false
   opts.on( '-v', '--verbose', 'Output more information' ) do
     options[:verbose] = true
   end
   
   options[:template_dir] = "./templates"
   opts.on('-t', '--templates DIR', 'Source directory') do
     options[:template_dir] = dir
   end
   
   options[:source_dir] = "./GeminiSDK"
   opts.on('-s', '--source DIR', 'Source directory') do
     options[:source_dir] = dir
   end
   
   options[:output_dir] = "./TemplateBuild"
   opts.on('-o', '--output DIR', 'Output directory') do
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
 
 # create base and bundle templates first
 outpath = options[:output_dir] + "/base.xctemplate"
 puts "OUTPATH: #{outpath}" if options[:verbose]
 FileUtils.mkdir_p(outpath)
 FileUtils.cp("#{options[:template_dir]}/TemplateInfo.plist.base",  "#{outpath}/TemplateInfo.plist")
 
 outpath = options[:output_dir] + "/bundle.xctemplate"
 puts "OUTPATH: #{outpath}" if options[:verbose]
 FileUtils.mkdir_p(outpath)
 FileUtils.cp("#{options[:template_dir]}/TemplateInfo.plist.bundle",  "#{outpath}/TemplateInfo.plist")
 
 # create base_ios template
 outpath = options[:output_dir] + "/base_ios.xctemplate"
 puts "OUTPATH: #{outpath}" if options[:verbose]
 FileUtils.mkdir_p(outpath)
 FileUtils.cp("#{options[:template_dir]}/TemplateInfo.plist.base_ios",  "#{outpath}/TemplateInfo.plist")
 FileUtils.cp_r("#{options[:source_dir]}/Resources", "#{outpath}")
 
