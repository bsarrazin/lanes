lane :playground do |options|
  unless options[:docs].nil?
    UI.header 'Lane Documentation'
    UI.message 'playground_scheme:MyScheme'.light_blue                   + ' ' + 'Required'.red
    UI.message 'playground_workspace:MyWorkspace.xcworkspace'.light_blue + ' ' + 'Required'.red
    UI.verbose 'Present Workding Directory: '.yellow + ENV['PWD']
    next
  end

  scheme = options[:playground_scheme]
  workspace = options[:playground_workspace]
  if scheme.nil? || workspace.nil?
    UI.error 'You must provide values for both playground_scheme and playground_workspace options'
    UI.error "  e.g. $ bundle exec fastlane playground playground_scheme:MyScheme playground_workspace:MyWorkspace.xcworkspace"
  end

  build_settings = sh "cd #{ENV['PWD']} && xcodebuild -workspace #{workspace} -scheme #{scheme} -configuration Debug -sdk iphonesimulator -showBuildSettings"
  
  built_products_dir = build_settings.lines.find do |line|
    line[/ BUILT_PRODUCTS_DIR =/]
  end.split('=').last.strip
  derived_data_dir = Pathname.new(built_products_dir)
  carthage_platform_dir = Pathname.new "#{ENV['PWD']}/Carthage/Build/iOS"
  Dir.entries(carthage_platform_dir).each do |entry|
    next unless entry.end_with?('.framework')
    FileUtils.mkdir_p(derived_data_dir)
    FileUtils.cp_r(carthage_platform_dir + entry, derived_data_dir)
  end
end
