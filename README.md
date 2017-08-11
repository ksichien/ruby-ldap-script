# ruby-ldap-script

This is a script for creating new users on an OpenLDAP server using the net/ldap ruby gem.

It was part of a gradual process to simplify OpenLDAP user creation, the next step can be found in my rails-ldap-app project.

It can be executed from a terminal with:
```
$ ruby ruby-ldap-script john smith c groups.txt
```

The arguments are as follows:
- the user's first name
- the user's last name
- the desired OpenLDAP operation to be performed, the options are:
  - "a" for adding a user to the groups specified in the groups.txt file
  - "c" for creating a user
  - "s" for searching all groups the user is a member of
- (optional) the location of the groups.txt file for the "c" command

When the script is executed, it will perform the requested operation on the OpenLDAP server and print the result to the terminal.
