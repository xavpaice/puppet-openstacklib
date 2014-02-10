class openstacklib::repo (
  $yum_http_proxy = undef,
  $yum_base_mirror = 'http://mirror.aarnet.edu.au',
  $yum_epel_mirror = 'http://mirror.aarnet.edu.au',
  $apt_proxy_host = undef,
  $apt_proxy_port = undef,
) {

    if $::osfamily == 'Debian' {
        include openstack::repo::uca

        if $apt_proxy_host {
            include apt
        }

        #Package<||> {
        #    require +> Exec['apt-update']
        #}
    }

    if $::osfamily == 'RedHat' {
        include openstack::repo::rdo
        include openstack::repo::epel

        if $yum_epel_mirror { 
            Yumrepo<| title == 'epel' |> {
                baseurl => "${yum_epel_mirror}/pub/epel/\$releasever/\$basearch",
                mirrorlist => absent
            }
        }

        if $yum_http_proxy {
            Yumrepo<||> {
                proxy => $yum_http_proxy
            }
        }

        Yumrepo<||> -> Package<||>

          # Manage base repos via puppet so we can have proxy and mirror settings
          # will need to add proper rhel support
          Yumrepo {
              gpgcheck       => "1",
              gpgkey         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6",
              enabled        => "1",
              mirrorlist => absent
          }

          yumrepo {
           "CentOS-Base":
              descr          => "CentOS-\$releasever - Base",
              mirrorlist     => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os',
              baseurl        => "${yum_base_mirror}/pub/centos/\$releasever/os/\$basearch/";
           "CentOS-Updates":
              descr          => "CentOS-\$releasever - Updates",
              mirrorlist     => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates',
              baseurl        => "${yum_base_mirror}/pub/centos/\$releasever/updates/\$basearch/";
           "CentOS-Extras":
              descr          => "CentOS-\$releasever - Extras",
              mirrorlist     => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras',
              baseurl        => "${yum_base_mirror}/pub/centos/\$releasever/extras/\$basearch/";
          }
    }
}