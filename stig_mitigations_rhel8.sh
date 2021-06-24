#!/bin/bash

#V-230235 	High 	RHEL 8 operating systems booted with a BIOS must require authentication upon booting into single-user and maintenance modes.

if [[ -d /efi/sys/firmware/ ]]
then
	echo "V-230235 NOT APPLICABLE"
else
	if [[ $(grep -iw grub2_password /boot/grub2/grub.cfg | grep  "grub.pbkdf2.sha512") ]]
	then 
		echo "V-230235 NOT APPLICABLE"
	else
		echo "V-230325 FOUND: You have to set a grub password via "sudo grub2-setpassword" "
	fi
fi

#V-230234 	High 	RHEL 8 operating systems booted with United Extensible Firmware Interface (UEFI) implemented must require authentication upon booting into single-user mode and maintenance.


if [[ -d /efi/sys/firmware/ ]]
then
	if [[ $(grep -iw grub2_password /boot/grub2/grub.cfg | grep  "grub.pbkdf2.sha512") ]]
	then 
		echo "V-230235 NOT APPLICABLE"
	else
		echo "You have to set a grub password via "sudo grub2-setpassword" "
	fi
else
	echo "V-230235 NOT APPLICABLE"

fi

#V-230380 	High 	RHEL 8 must not have accounts configured with blank or null passwords.


if [[ $(grep -i nullok /etc/pam.d/system-auth /etc/pam.d/password-auth 2> /dev/null) ]]
then
	sed -i 's|nullok||g' /etc/pam.d/system-auth /etc/pam.d/password-auth
	echo "V-230380 (1/2) MITIGATED"
else
	echo "V-230380 (1/2) NOT APPLICABLE"
fi
if [[ $(grep -i "PermitEmptyPasswords yes" /etc/ssh/sshd_config) ]]
then
	sed -i 's|PermitEmptyPasswords yes|PermitEmptyPasswords no|' /etc/ssh/sshd_config
	systemctl restart sshd
	echo "V-230380 (2/2) MITIGATED"
else
	echo "V-230380 (2/2) NOT APPLICABLE"
fi

#V-230329 	High 	Unattended or automatic logon via the RHEL 8 graphical user interface must not be allowed.

if [[ $(rpm -qa gdm) ]]
then 
	if [[ $(grep -i automaticloginenable /etc/gdm/custom.conf) ]]
	then 
		if [[ $(grep -i automaticloginenable /etc/gdm/custom.conf | grep true) ]]
		then 
			sed -i 's|AutomaticLoginEnable=true|AutomaticLoginEnable=false'
			echo "V-230329 MITIGATED"
		else
			echo "V-230329 NOT APPLICABLE"
		fi
	else
		echo "AutomaticLoginEnable=false" >> /etc/gdm/custom.conf
		echo "V-230329 MITIGATED"
	fi
else
	echo "V-230329 NOT APPLICABLE"
fi

#V-230558 	High 	A File Transfer Protocol (FTP) server package must not be installed unless mission essential on RHEL 8.

if [[ $(rpm -qa vsftpd) ]]
then
	echo "FTP is installed, If not documented with ISSO, remove it."
else
	echo "V-230558 NOT APPLICABLE"
fi

#V-230529 	High 	The x86 Ctrl-Alt-Delete key sequence must be disabled on RHEL 8.

if [[ $(systemctl list-unit-files | awk '/masked/ {print $1}' | grep ctrl-alt-del) ]]
then
	echo "V-230529 NOT APPLICABLE"
else
	systemctl mask ctrl-alt-del.target
	echo "V-230529 MITIGATED"
fi

#V-230284 	High 	There must be no .shosts files on the RHEL 8 operating system.

if [[ $(find / -type f -name *.shosts 2> /dev/null) ]]
then
	find / -type f -name *.shosts -exec rm -rf {} \; 2> /dev/null
	echo "V-230284 MITIGATEd"
else
	echo "V-230284 NOT APPLICABLE"
fi

#V-230283 	High 	There must be no shosts.equiv files on the RHEL 8 operating system.

if [[ $(find / -type f -name shosts.equiv 2> /dev/null) ]]
then
	find / -type f -name shosts.equiv -exec rm -rf {} \; 2> /dev/null
	echo "V-230283 MITIGATEd"
else
	echo "V-230283 NOT APPLICABLE"
fi

#V-230487 	High 	RHEL 8 must not have the telnet-server package installed.

if [[ $(rpm -qa telnet) ]]
then
	yum remove -y telnet
	echo "V-230487 MITIGATED"
else
	echo "V-230487 NOT APPLICABLE"
fi

#V-230264 	High 	RHEL 8 must prevent the installation of software, patches, service packs, device drivers, or operating system components from a repository without verification they have been digitally signed using a certificate that is issued by a Certificate Authority (CA) that is recognized and approved by the organization.

if [[ $(egrep "#?gpgcheck=0" /etc/yum.repos.d/*.repo) ]]
then
	sed -i 's|gpgcheck=0|gpgcheck=1|g' /etc/yum.repos.d/*.repo
	sed -i 's|#gpgcheck=0|gpgcheck=1|g' /etc/yum.repos.d/*.repo
	sed -i 's|#gpgcheck=1|gpgcheck=1|g' /etc/yum.repos.d/*.repo
	echo "V-230264 MITIGATED"
else
	echo "V-230264 NOT APPLICABLE"
fi

#V-230265 	High 	RHEL 8 must prevent the installation of software, patches, service packs, device drivers, or operating system components of local packages without verification they have been digitally signed using a certificate that is issued by a Certificate Authority (CA) that is recognized and approved by the organization.


if [ $(egrep "^localpkg_gpgcheck=1" /etc/dnf/dnf.conf) -o $(egrep "^localpkg_gpgcheck=True" /etc/dnf/dnf.conf) -o $(egrep "^localpkg_gpgcheck=yes" /etc/dnf/dnf.conf) ]
then
	echo "V-230265 NOT APPLICABLE"
else
	if [[ $(grep -i localpkg_gpgcheck /etc/dnf/dnf.conf) ]]
	then
		sed -i 's|#localpkg_gpgcheck|localpkg_gpgcheck|g' /etc/dnf/dnf.conf
		sed -i 's|localpkg_gpgcheck=0|localpkg_gpgcheck=1|g' /etc/dnf/dnf.conf
		sed -i 's|localpkg_gpgcheck=False|localpkg_gpgcheck=True|g' /etc/dnf/dnf.conf
		sed -i 's|localpkg_gpgcheck=no|localpkg_gpgcheck=yes|g' /etc/dnf/dnf.conf
		sed -i 's|localpkg_gpgcheck=false|localpkg_gpgcheck=True|g' /etc/dnf/dnf.conf
		echo "V-230265 MITIGATED"
	else
		echo "localpkg_gpgcheck=1" >> /etc/dnf/dnf.conf
		echo "V-230265 MITIGATED"
	fi
fi

#V-230223 	High 	RHEL 8 must implement NIST FIPS-validated cryptography for the following: to provision digital signatures, to generate cryptographic hashes, and to protect data requiring data-at-rest protections in accordance with applicable federal laws, Executive Orders, directives, policies, regulations, and standards.

if [[ ! $(rpm -qa fipscheck) ]]
then
	yum install -y fipscheck
fi

if [[ $(fipscheck 2>&1 | grep "fips mode is off") ]] || [[ ! $(grub2-editenv - list | grep "fips") ]] || [[ $(cat /proc/sys/crypto/fips_enabled | grep "0") ]]
then
	sed -i 's|GRUB_CMDLINE_LINUX="|GRUB_CMDLINE_LINUX="fips |' /etc/default/grub
	grub2-mkconfig -o /boot/grub2/grub.cfg
	fips-mode-setup --enable
	echo "V-230223 MITIGATED, reboot the system"
else
	yum remove -y fipscheck
	echo "V-230223 NOT APPLICABLE"
fi

#V-230534 	High 	The root account must be the only account having unrestricted access to the RHEL 8 system.

if [[ $(awk -F: '$3 == 0 {print $1}' /etc/passwd | grep -v root | wc -l | grep 0) ]]
then
	echo "V-230534 NOT APPLICABLE"
else
	echo "$(awk -F: '$3 == 0 {print $1}' | grep -v root) have UID 0, make sure only root has UID 0"
fi

#V-230533 	High 	The Trivial File Transfer Protocol (TFTP) server package must not be installed if not required for RHEL 8 operational support.

if [[ $(rpm -qa tftp-server) ]]
then
	echo "TFPT server is installed, if not documented with ISSO, remove it"
else
	echo "V-230533 NOT APPLICABLE"
fi

#V-230530 	High 	The x86 Ctrl-Alt-Delete key sequence in RHEL 8 must be disabled if a graphical user interface is installed.

if [[ $(rpm -qa mutter) ]]
then
	if [[ $(grep "^logout=''$" /etc/dconf/db/local.d/* 2> /dev/null) ]]
	then
		echo "V-230530 NOT APPLICABLE"
	else
		echo "[org/gnome/settings-daemon/plugins/media-keys]" > /etc/dconf/db/local.d/00-disable-CAD
		echo "logout=''" >> /etc/dconf/db/local.d/00-disable-CAD
		echo "V-230530 MITIGATED"
	fi
else
	echo "V-230530 NOT APPLICABLE"
fi

#V-230531 	High 	The systemd Ctrl-Alt-Delete burst key sequence in RHEL 8 must be disabled.

if [[ ! $(grep "^CtrlAltDelBurstAction=none$" /etc/systemd/system.conf) ]]
then
	sed -i 's/.*CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=none/' /etc/systemd/system.conf
#	if [[ $(grep "CtrlAltDelBurstAction" /etc/systemd/system.conf | grep none) ]]
#	then
		echo "V-230531 MITIGATED"
#	else
#		sed -i 's/.*CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=none/' /etc/systemd/system.conf
#		echo "V-230531 MITIGATED"
#	fi
else
#	echo "CtrlAltDelBurstAction=none" >> /etc/systemd/system.conf
	echo "V-230531 NOT APPLICABLE"
fi

#V-230492 	High 	RHEL 8 must not have the rsh-server package installed.

if [[ $(rpm -qa rsh-server) ]]
then
	yum remove -y rsh-server
	echo "V-230492 MITIGATED"
else
	echo "V-230492 NOT APPLICABLE"
fi

