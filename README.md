# Secret manager

## Description

Simple, bash-portable, secret manager that allows for searching, encrypting and decrypting of secrets.


## Installation

The installation only ever modifies the files inside the directory in which you clone this repository
and appends a few lines to the `~/.bashrc`.

- Prior to the installation define the directory into which you'll store all your encrypted secrets,
  in the following example the `passwd` directory in `$HOME`, if you don't define any,
  installation will default to `$HOME/passwd`:
  
    ```
    SECRETDIR=$HOME/passwd
    ```

- Clone this repository:

    ```
    git clone -b v1.0 https://github.com/ralberrto/file-based-secret-manager.git ${SECRETDIR:-$HOME/passwd}
    ```

- Run the installer script found in `src/install.sh`:

    ```
    ${SECRETDIR:-$HOME/passwd}/src/install.sh
    ```

- It will prompt you to enter the recipient for gpg secret key (the uid of its public key).
- You're done!


## Uninstallation

- If you don't recall where you cloned the repository you can find it with:

    ```
    find / -name .filebasedsecretmanager -exec dirname {} \; 2>/dev/null
    ```

- Delete the directiroy where you cloned the `v1.0` repository, e.g.

    ```
    rm -r $HOME/passswd
    ```
  *Note that by doing this you'll get rid of all the secrets you might have created.*

- Remove the following lines from ~/.bashrc:

    ```
    # START: Added by file-based-secret-manager https://github.com/ralberrto/file-based-secret-manager
    . . .
    # END: Added by file-based-secret-manager https://github.com/ralberrto/file-based-secret-manager
    ```

- You're done! Pretty clean wasn't it?


## Specification of interfaces

- Each json file contains a particular secret with several attributes.
- The top-level attribute `filename` is relative to this directory.
- Secrets must have the structure layed out it in `templates/user-passwd.json`
- There's a cli for creating secrets, `src/create.sh` and linked by `bin/creates` that works along with the file template file.
  The template file should have a first level `.hidden` attribute, which populates the `.shown.content` attribute.
  The `.hidden` object can have any structure as the secret might require, as long as it's json compliant;
  The `.shown` object structure should not be modified! Only the values may be customized.
- There's a cli for decrypting secrets in `src/decrypt.sh` and linked by `bin/decrypts`
- There's a cli for searching through secrets in `src/search.sh` and linked by `bin/decrypts`
- The following test should always return nothing:

    ```
    find ./ -name "*.json" -not -path "*/templates/*" | while read ; do FNAME=$(jq -r .filename < $REPLY) ; [ "$FNAME" = "${REPLY##*/}" ] || ( echo $FNAME && echo ${REPLY##*/} && echo "not equal $REPLY" ) ; done
    ```
