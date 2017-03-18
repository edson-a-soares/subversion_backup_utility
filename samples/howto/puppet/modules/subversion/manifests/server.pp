class subversion::server {

	exec { "apt-get-add":
		command	=> "sudo apt-add-repository ppa:dominik-stadler/subversion-1.8",
		unless  => "test -f /etc/apt/sources.list.d/dominik-stadler-subversion-1_8-trusty.list",
		path    => [ "/bin", "/usr/bin" ],
	}

	exec { "apt-update":
		command	    => "sudo apt-get update -y --force-yes",
		subscribe   => Exec["apt-get-add"],
		refreshonly => true,
		path        => [ "/bin", "/usr/bin" ],
	}

	package { "subversion":
		ensure	=> installed,
		require	=> Exec["apt-update"],
	}

	exec { "create-repositories-root-directory":
		command 	=> "sudo mkdir -p /usr/local/subversion/repositories",
		unless  	=> "test -e /usr/local/subversion/repositories",
		subscribe	=> Package["subversion"],
		refreshonly	=> true,
		path    	=> [ "/bin", "/usr/bin" ],
	}

	file { "add-setup-subversion-to-init.d":
		ensure	=> file,
		owner	=> root,
		group	=> root,
		mode	=> "ugo+x",
		path	=> "/etc/init.d/setup-subversion.sh",
		source	=> "puppet:///modules/subversion/setup-subversion.sh",
		require	=> Package["subversion"],
	}

	exec { "define-repositories-path":
		command	    => "sudo sh setup-subversion.sh",
		cwd         => "/etc/init.d",
		subscribe	=> Package["subversion"],
		refreshonly	=> true,
		path	    => [ "/bin", "/usr/bin" ],
	}

	exec { "add-setup-subversion-to-startup-machine":
		command	    => "sudo update-rc.d setup-subversion.sh defaults",
		cwd         => "/etc/init.d",
		require	    => File["add-setup-subversion-to-init.d"],
		subscribe	=> Package["subversion"],
		refreshonly	=> true,
		path	    => [ "/bin", "/usr/bin" ],
	}

	file { "/home/vagrant/run-backup.sh":
		ensure	=> file,
		owner	=> vagrant,
		group	=> vagrant,
		mode	=> "ugo+x",
		source	=> "puppet:///modules/subversion/run-backup.sh",
		require	=> Package["subversion"],
	}

	cron { "backup-svn-repositories":
		command 	=> "sudo bash /home/vagrant/run-backup.sh",
		ensure		=> "present",
		user		=> root,
		hour		=> "*",
		minute		=> "*/1",
		provider	=> "crontab",
		require   	=> File["/home/vagrant/run-backup.sh"],
	}

}
