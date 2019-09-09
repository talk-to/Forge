Pod::Spec.new do |s|
  s.name             = 'Forge'
  s.version          = '1.1.3'
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
  s.license          = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  s.author           = { 'Ayush Goel' => 'ayushgoel111@gmail.com' }
  s.source           = { :git => 'https://github.com/talk-to/Forge.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'

  s.source_files = 'Forge/Classes/**/*'

  s.resource_bundles = {
    'Forge' => ['Forge/Assets/*.xcdatamodeld', 'Forge/Classes/*.storyboard']
  }

  s.dependency 'Result', '~> 4.0'

end
