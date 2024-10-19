# xor-file-enc-asm
Xor encrypt a file in assembly. No malloc since libc is not used meaning you have to configure the max file size variable to read bigger files. Couldnt be bothered to implement chunk reading.

Compile with `make`

Run with `bin/main your_file_path your_key_string`
