# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

inhibit_all_warnings!

target 'planit v0.2' do

  # Pods for planit v0.2
    pod 'pop', '~> 1.0'
    pod "Apollo"
    pod 'JTAppleCalendar', '~> 6.0'
    
    # Pods for ZLswipeableview
    pod 'UIColor+FlatColors'
    pod 'Cartography'
    
    # Pods for GoogleMaps
    pod 'GoogleMaps'
    pod 'GooglePlaces'
    
    # Pods for WhirlyGlobeView
    pod 'WhirlyGlobe', :http => 'https://s3-us-west-1.amazonaws.com/whirlyglobemaplydistribution/iOS_daily_builds/WhirlyGlobe-Maply_Nightly_latest.zip'
    pod 'WhirlyGlobeResources'

  target 'planit v0.2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'planit v0.2UITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
