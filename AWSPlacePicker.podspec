Pod::Spec.new do |s|
  s.name             = 'AWSPlacePicker'
  s.version          = '1.0'
  s.summary          = 'AWSPlacePicker SDK'
  s.description      = <<-DESC 
	TODO: AWSPlacePicker SDK 
DESC

  s.homepage         = 'https://github.com/mawshd/AWSPlacePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Awais Shahid' => 'm_aws_s@hotmail.com' }
  s.source           = { :git => 'https://github.com/mawshd/AWSPlacePicker.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'

  s.source_files = 'AWSPlacePicker/SDK/**/*.{h,m,swift}'
  
  s.subspec 'Resources' do |resources|
      resources.resource_bundle = {'SDKImages' => ['AWSPlacePicker/SDK/Assets/**/*.{png, jpg, jpeg}'],'SDKJsons' => ['AWSPlacePicker/SDK/Assets/**/*.{json}'],'SDKNibs' => ['AWSPlacePicker/SDK/**/*.{xib}']}
  end
  
  s.static_framework = true
  
  s.dependency 'GoogleMaps'
  s.dependency 'GooglePlaces'
  s.dependency 'DropDown'
  s.dependency 'IQKeyboardManagerSwift'

end
