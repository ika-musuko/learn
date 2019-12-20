use std::env;
use std::str;

fn main() {
    let args: Vec<String> = env::args().collect();
    match args.len() {
        0 | 1 => panic!("hex2rgb: converts a hex color code to dec rgb values (need an argument)"),
        _ => println!("rgb255 {}", hex2rgb(&args[1])),
    };
}

fn hex2rgb(color_code: &str) -> String {
    let color_code_slice: String = match color_code.chars().next() {
        Some('#') => color_code.chars().skip(1).collect::<String>(),
        _ => match color_code.len() {
            6 => String::from(color_code),
            _ => {
                panic!("expecting hexadecimal color code! (with or without #). expecting len=6 but got len={}", color_code.len());
            }
        },
    };

    color_code_slice
        .as_bytes()
        .chunks(2)
        .map(|color_value| {
            i64::from_str_radix(
                str::from_utf8(color_value).expect("expecting single-byte chars"),
                16,
            )
            .expect("invalid hex string")
            .to_string()
        })
        .collect::<Vec<String>>()
        .join(" ")
}
