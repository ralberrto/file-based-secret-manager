# Secret manager

## Description

Simple, bash-portable, secret manager that allows for searching, encrypting and decrypting of secrets.


## Specification of interfaces

- Each json file contains a particular secret with several attributes.
- The top-level attribute `filename` is relative to this directory.
- Secrets must have the structure layed out it in `./model.json.ex`.
- There's a cli for creating secrets, `./create.sh` and linked by `/usr/local/bin/creates` that works along with the file template file.
  The template file should have a first level `.hidden` attribute, which populates the `.shown.content` attribute.
  The `.hidden` object can have any structure as the secret might require, as long as it's json compliant;
  The `.shown` object structure should not be modified! Only the values may be customized.
- There's a cli for decrypting secrets in `./decrypt.sh` and linked by `/usr/local/bin/decrypts`.
- There's a cli for searching through secrets in `./search.sh` and linked by `/usr/local/bin/searchs`.
- The following test should always return nothing:

    ```
    find ./ -name "*.json" -not -path "*/templates/*" | while read ; do FNAME=$(jq -r .filename < $REPLY) ; [ "$FNAME" = "${REPLY##*/}" ] || ( echo $FNAME && echo ${REPLY##*/} && echo "not equal $REPLY" ) ; done
    ```
