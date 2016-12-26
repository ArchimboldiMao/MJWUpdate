Pod::Spec.new do |spec|
  spec.name = "MJWUpdate"
  spec.version = "1.0.1"
  spec.summary = "It's a framework for check your app's latest version in App Store, and alert user to update."
  spec.homepage = "https://github.com/ArchimboldiMao/MJWUpdate"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Archimboldi Mao" => "archimboldi.mao@gmail.com" }
  spec.social_media_url = "https://twitter.com/ArchimboldiMao"

  spec.source = { :git => "https://github.com/ArchimboldiMao/MJWUpdate.git", :tag => "#{spec.version}", :submodules => true }
  spec.source_files = "MJWUpdate/**/*.{h,m}"
  spec.platform = :ios, "8.0"
  spec.requires_arc = true
end
