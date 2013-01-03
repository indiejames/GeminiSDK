require 'RMagick'
include Magick

# utility methods

# get the iOS version
def iOSVersion
	return server_version["iOS_version"]
end

# get a string identifying the device
def device_str
	dev_str = {
		  "iPhone" => "iPhone",
		  "iPad (Retina)" => "iPad_Retina",
		  "iPhone (Retina 4-inch)"	=> "iPhone_Retina_4_inch",
		  "iPhone (Retina 3.5-inch)" => "iPhone_Retina_3.5_inch"
	}

	sv = server_version["simulator"]
	sv=~/\((.*)\//
	dev_str[$1]

end

# load the proper reference image based on the filename and the device used for testing
def reference_image(filename)
	path = "features/reference/#{iOSVersion}/#{device_str}/#{filename}"
	img = Magick::Image::read(path).first
end

# step definitions

Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(STEP_PAUSE)
end

Given /^I am at the "(.*?)" scene$/ do |scene_name|
  backdoor("calabashBackdoor:", "goto_#{scene_name}")
end

Then /^screenshot\("(.*?)"\)$/ do |filename|
  base64 = backdoor("calabashBackdoor:", "screenshot")
  File.open(filename, 'wb') do |f|
  	f.write(Base64.decode64(base64))
  end
end

Then /^screen_compare\("(.*?)"\)$/ do |filename|
  base64 = backdoor("calabashBackdoor:", "screenshot")
  ref_img = reference_image(filename)
  img = Image.read_inline(base64).first
  diff, dist = img.compare_channel(ref_img, RootMeanSquaredErrorMetric)
  assert dist < 0.01, "Screenshot differs from reference image #{filename}"
end
