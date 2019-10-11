Pod::Spec.new do |s|
  s.name             = 'AWSPlacePicker'
  s.version          = '0.1'
  s.summary          = 'AWSPlacePicker SDK'
  s.description      = <<-DESC TODO: AWSPlacePicker SDK DESC

  s.homepage         = 'https://github.com/mawshd/AWSPlacePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Awais Shahid' => 'm_aws_s@hotmail.com' }
  s.source           = { :git => 'https://github.com/mawshd/AWSPlacePicker.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'

  
  s.subspec 'Resources' do |resources|
      resources.resource_bundle = {'SDKImages' => ['AWSPlacePicker/AWSPlacePickerSDK/Resources/**/*.{png}'],'SDKJsons' => ['AWSPlacePicker/AWSPlacePickerSDK/Resources/**/*.{json}'],'SDKNibs' => ['AWSPlacePicker/AWSPlacePickerSDK/**/*.{xib}']}
  end
  
  s.static_framework = true
  
  s.dependency 'GoogleMaps'
  s.dependency 'GooglePlaces'
  s.dependency 'DropDown'

end
