fn main() {
    let s1 = String::from("hasdfasdf");
    let len = calculate_length(&s1);
    println!("len of '{}': {}", s1, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}
