# base32.sh

encode and decode with base32 in shell

## Usage

### Encode

```sh
$ ./base32.sh encode <string>
$ ./base32.sh encode abcdefg
MFRGGZDFMZTQ====
```

### Decode

```sh
$ ./base32.sh decode <string>
$ ./base32.sh decode MFRGGZDFMZTQ====
\x61\x62\x63\x64\x65\x66\x67
$ echo $(./base32.sh decode MFRGGZDFMZTQ====)
abcdefg
```

## License

[MIT License](https://opensource.org/licenses/MIT).
