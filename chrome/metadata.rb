name 'chrome'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'MIT'
description 'Installs/Configures Chrome browser'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '4.0.1'

supports 'centos', '>= 7.0'
supports 'redhat', '>= 7.0'
supports 'fedora'
supports 'mac_os_x'
supports 'debian'
supports 'ubuntu'
supports 'windows'

depends 'apt'
# depends 'dmg', '>= 3.0'
