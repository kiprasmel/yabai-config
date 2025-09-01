if `/tmp/skhd_kipras.err.log` prints:

```
skhd: secure keyboard entry is enabled by (595) 'system settings'! abort..
```

one of your applications is forcing secure input.
likely a password manager that autofocuses input, e.g. keepassxc.
to solve:

https://github.com/koekeishiya/skhd/issues/48#issuecomment-421511393

```sh
ioreg -l -w 0 \
    | perl -nle 'print $1 if /"kCGSSessionSecureInputPID"=(\d+)/' \
    | uniq \
    | xargs -I{} ps -p {} -o comm=
```


