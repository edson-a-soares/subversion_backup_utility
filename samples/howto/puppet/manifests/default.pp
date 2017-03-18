
    include git
    include subversion
    include subversion::server

    vcsrepo { '/home/vagrant/backup_tool':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/edson-a-soares/subversion_backup_utility.git',
    }

    vcsrepo { '/usr/local/subversion/repositories/store':
        ensure   => present,
        provider => svn,
    }

    vcsrepo { '/usr/local/subversion/repositories/application-core':
        ensure   => present,
        provider => svn,
    }

    vcsrepo { '/usr/local/subversion/repositories/application-administrator':
        ensure   => present,
        provider => svn,
    }

    vcsrepo { '/usr/local/subversion/repositories/application-client':
        ensure   => present,
        provider => svn,
    }

    vcsrepo { '/usr/local/subversion/repositories/application-api':
        ensure   => present,
        provider => svn,
    }
