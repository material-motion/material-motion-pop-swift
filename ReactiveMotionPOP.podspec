Pod::Spec.new do |s|
  s.name         = "ReactiveMotionPOP"
  s.summary      = "Reactive Motion POP extension"
  s.version      = "1.0.0"
  s.authors      = "The Material Motion Authors"
  s.license      = "Apache 2.0"
  s.homepage     = "https://github.com/material-motion/reactive-motion-pop-swift"
  s.source       = { :git => "https://github.com/material-motion/reactive-motion-pop-swift.git", :tag => "v" + s.version.to_s }
  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source_files = "src/**/*.{swift}"

  s.dependency "ReactiveMotion", "~> 1.0"
end
