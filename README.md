# ruby-ldap-script

This is a script I wrote for creating new users on an OpenLDAP server using the net/ldap ruby gem.

It can take 4 arguments, the first and second being the user's first and last name.

The third argument is the operation that needs to be performed, it can be either a (for adding a user to user groups), c (for creating a new user) or s (for searching all user groups a user belongs to).

The fourth argument is optional and specifies the location of a text file with all user groups the user needs to be added to.

It can be executed from a terminal with:
```
$ ruby ruby-ldap-script john smith c groups.txt
```
