class people::giginet {
  # resources
  include dropbox
  include skype
  include iterm2::stable
  include chrome
  include firefox
  include alfred
  include wunderlist
  include pycharm
  include pythonbrew
  include pip

  # install from Homebrew
  package {
    [
      # homebrew
      'zsh',
      'vim',
      'tmux',
      'reattach-to-user-namespace',
      'tig',
      'hub',
      'git-flow',
      'yuicompressor',
      'mercurial'
      # GUI
      'XtraFinder':
        source   => "http://www.trankynam.com/xtrafinder/downloads/XtraFinder.dmg",
        provider => pkgdmg;
      'Google Japanese Input':
        source   => "http://dl.google.com/dl/japanese-ime/1.8.1310.1/googlejapaneseinput.dmg",
        provider => pkgdmg;
    ]
  }

  $home = "/Users/${::luser}"
  $documents = "${home}/Documents"
  $dotfiles = "${documents}/dotfiles"
  $desktop = "${home}/Desktop"
  
  # define files
  file { $documents:
    ensure => directory
  }

  # checkout dotfiles and setup
  repository { $dotfiles:
    source => "giginet/dotfiles",
    require => File[$documents]
  }
  exec { "sh ${dotfiles}/setup.sh":
    cwd => $dotfiles,
    require => Repository[$dotfiles]
  }

  # setup autojump from source
  # when I install it via homebrew, it seems to be not working.
  repository { $desktop:
    source => "joelthelion/autojump",
    require => File[$desktop]
  }
  exec { "sh ${desktop}/autojump/install.sh -g":
    cwd => "${desktop}/autojump",
    require => Repository["${desktop}/autojump"]
  }

  # change login shell for zsh via Homebrew
  file_line { 'add zsh to /etc/shells':
      path    => '/etc/shells',
      line    => "${boxen::config::homebrewdir}/bin/zsh",
      require => Package['zsh'],
      before  => Osx_chsh[$::luser];
  }
  osx_chsh { $::luser:
      shell   => "${boxen::config::homebrewdir}/bin/zsh";
  }

  class { 'ruby::global':
      version => '1.9.3'
  }

  # install gem packages
  package { "cocoapods":
    ensure => 'installed',
    provider => 'gem'
  }
  ruby::gem { "cocoapods":
      gem     => 'cocoapods',
      ruby    => '1.9.3',
  }

  # setup python environment
  class{'pythonbrew', }
  python_version {'2.7.4':
    ensure      => 'present',
    default_use => true,
    require     => Class['pythonbrew']
  }
  python_version {'3.3.1':
    ensure      => 'present',
    default_use => false,
    require     => Class['pythonbrew']
  }

  # install pip packages
  package { "PIL":
    ensure => 'latest',
    provider => 'pip',
  }
  package { "bpython":
    ensure => 'latest',
    provider => 'pip',
  }

  # install any arbitrary nodejs version
  nodejs { 'v0.10.1': }

  # install npm packages
  nodejs::module { 'coffee-script':
    nodejs_version => 'v0.10.1'
  }

} 
