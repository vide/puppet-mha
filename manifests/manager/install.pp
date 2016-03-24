class mha::manager::install {

  require ::epel

  $ensure        = "${mha::manager::version}.el${::operatingsystemmajrelease}"
  $rpm           = "mha4mysql-manager-${ensure}.noarch.rpm"
  $source_url    = "http://www.mysql.gr.jp/frame/modules/bwiki/index.php?plugin=attach&pcmd=open&file=${rpm}&refer=matsunobu"
  $download_path = "/usr/local/src/${rpm}"

  if !defined(Class['mha::node::install']) {
    class { 'mha::node::install':
      version => $mha::manager::node_version,
    }
  }

  $perl_pkgs = $::operatingsystemmajrelease ? {
    '5' => [
      'perl-Config-Tiny',
      'perl-Log-Dispatch',
      'perl-Parallel-ForkManager',
    ],
    '6' => [
      'perl-Config-Tiny',
      'perl-Log-Dispatch',
      'perl-Parallel-ForkManager',
      'perl-Time-HiRes',
    ],
  }

  ensure_packages($perl_pkgs)

  # Because the rpm command on centos5 is failed.
  exec { 'download mha-manager':
    command => "wget -O ${download_path} \"${source_url}\"",
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    creates => $download_path,
  }

  package { 'mha4mysql-manager':
    ensure   => $ensure,
    provider => rpm,
    source   => $download_path,
    require  => [
      Exec['download mha-manager'],
      Package[$perl_pkgs],
      Class['mha::node::install'],
    ],
  }

}
