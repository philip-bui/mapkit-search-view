Pod::Spec.new do |s|
  s.name = 'MapKitSearchView'
  s.version = '2.0.0'
  s.license= { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An implementation of Apples Map search view with bottom sheet gestures.'
  s.description = 'Standalone view controller for searching and finding places.'
  s.homepage = 'https://github.com/philip-bui/mapkit-search-view'
  s.author = { 'Philip Bui' => 'philip.bui.developer@gmail.com' }
  s.source = { :git => 'https://github.com/philip-bui/mapkit-search-view.git', :tag => s.version }
  s.documentation_url = 'https://github.com/philip-bui/mapkit-search-view'

  s.ios.deployment_target = '11.0'
 
  s.source_files = 'Sources/**/*.swift'
  s.resources    = ['Sources/Resources/*', 'Sources/**/*.xib']
  s.screenshots = ['https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit.png', 'https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_Completions.png', 'https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_MapItems.png']
  s.swift_version = '5.0'
end
