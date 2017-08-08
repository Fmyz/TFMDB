Pod::Spec.new do |s|
  s.name         = "TFMDB"
  s.version      = "1.0.0"

  s.summary      = "FMDB Cipher, Model auto SQL"
  
  s.homepage     = "https://github.com/Fmyz/TFMDB"
  s.license      = "MIT"
  s.author       = { "Fmyz" => "https://github.com/Fmyz/TFMDB" }

  s.platform     = :ios,'7.0'
  s.source       = { :git => "https://github.com/Fmyz/TFMDB.git", :tag => "#{s.version}" }

  s.requires_arc = true

  s.default_subspec = 'All'

  s.subspec 'SQLCipher' do |ss|
    ss.source_files = 'TFMDB/*.{h,m}'
    ss.dependency 'FMDB/SQLCipher'
  end

  s.subspec 'All' do |ss|
    ss.source_files = 'TFMDB/*.{h,m}', 'TFMDB/TDBModel/*.{h,m}'
    ss.dependency 'FMDB/SQLCipher'
    ss.dependency 'MJExtension'
  end

end
