Pod::Spec.new do |s|
  s.name         = "ShortMediaCache"
  s.version      = "0.1.0"
  s.summary      = "A cache for short video while playing."
  s.homepage     = "https://github.com/dangercheng/ShortMediaCache"
  s.license      = "MIT"
  s.author             = { "DandJ" => "877478415@qq.com" }
  s.source       = { :git =>    "https://github.com/dangercheng/ShortMediaCache.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.source_files  = "ShortMediaCache/*.{h,m}"
end