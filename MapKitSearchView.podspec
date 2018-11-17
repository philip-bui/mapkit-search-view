Pod::Spec.new do |s|
  s.name = 'MapKitSearchView'
  s.version = '1.0.1'
  s.license= { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An implementation of Apples Map search view.'
  s.description = 'Standalone view controller for searching and finding places.'
  s.homepage = 'https://github.com/philip-bui/mapkit-search-view'
  s.author = { 'Philip Bui' => 'philip.bui.developer@gmail.com' }
  s.source = { :git => 'https://github.com/philip-bui/mapkit-search-view.git', :tag => s.version }
  s.documentation_url = 'https://github.com/philip-bui/mapkit-search-view'

  s.ios.deployment_target = '11.0'
 
  s.source_files = 'Sources/*/*', 'Sources/*.swift'
  s.screenshots = ['https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit.png', 'https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_Completions.png', 'https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_MapItems.png']
  s.swift_version = '4.2'
end
