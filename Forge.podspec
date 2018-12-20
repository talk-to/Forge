Pod::Spec.new do |s|
  s.name             = 'Forge'
  s.version          = '0.1.0'
  s.summary          = 'A scalable system to run tasks for your app with support for persistence.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Provides a framework to submit your tasks to. The tasks run parallely and provide
a hook to make changes to your system locally before starting a task. The framework
also persists tasks with it so that any pending tasks can be restarted across app restarts.
                       DESC

  s.homepage         = 'https://github.com/talk-to/Forge'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  s.author           = { 'Ayush Goel' => 'ayushgoel111@gmail.com' }
  s.source           = { :git => 'https://github.com/talk-to/Forge.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Forge/Classes/**/*'

  # s.resource_bundles = {
  #   'Forge' => ['Forge/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Result', '~> 4.0'

end
