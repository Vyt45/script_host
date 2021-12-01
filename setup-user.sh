#!/bin/bash

#
# Initial script to create users when launching an Ubuntu server EC2 instance
#

declare -A USERKEY

#
# Create one entry for every user who needs access. Be sure to change the key to their
# public key. The keys here are all my key.
#
USERKEY[developer]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwCx4TaRXMqd0A8cE3e24sl9zbmkzI5JeQ+hhHgtvsID0E+OVedW9wYngQFC96glJINcIkXqMZBk+nVNg7yYbPINK1RWEKLjsDKyzg+eSzSI+sgdPBs+IFJrg11tXJAdC6oMImuh0Zwvavf+7wy59LX6rY9YAZAn40Ietsw/DMFCJ090Z18MzhgUcSzG6GmdwMbn/Nh3hGdWc6uEw8lKDuzVMphejC1d9Z8Uea5AcQyMUcVY0w1CXOiKO32O8UcULgbSBtzIR78qnwrBFFQo86jiTqOOtndm0HKQW/SHgxz0E2aX3dGeogZppMeDgKnutaIIChIt1yLYiHVF/uQtb5shyCjNwXbKxTZOAMKVkCeizkg2BayKc1zxijGmD6ohTpgitBfe/3O9oY3GJWiYFFhIwSABEn4BCikDDfDSXWAaistT0zyS+CCPgiXL+SgmxBlnT+cMgK1RzEcNdgt7+oIpuxVLtNbUEr0ZXZPkFWeqK1XFkQp6Mzb2GNL/4vAD0= devb\vytautas.parulis@DBG-GXCT0J3
"

declare -A SUDOUSER

#
# Add one entry below for each user who needs sudo access.
# The usernames should be same as above.
#
SUDOUSER[developer]=y

# Iterate through all users (based on the associative array USERKEY)
for user in "${!USERKEY[@]}" ; do
  # Add the user (--gecos "" ensures that this runs non-interactively)
  adduser --disabled-password --gecos "" $user

  # Give read-only access to log files by adding the user to adm group
  # Other groups that you may want to add are apache, nginx, mysql etc. for their log files
  usermod -a -G adm $user

  # If the user needs sudo access, give that.
  if [ "${SUDOUSER[$user]}" == 'y' ] ; then
    # Give sudo access by adding the user to sudo group
    usermod -a -G sudo $user
    # Allow passwordless sudo
    echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
  fi

  # Add the user's auth key to allow ssh access
  mkdir /home/$user/.ssh
  echo "${USERKEY[$user]}" >> /home/$user/.ssh/authorized_keys

  # Change ownership and access modes for the new directory/file
  chown -R $user:$user /home/$user/.ssh
  chmod -R go-rx /home/$user/.ssh
done