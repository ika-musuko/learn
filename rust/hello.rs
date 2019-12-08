#[derive(Debug)]
struct Person {
    name: str,
    age u8
}

fn main() {
    let sherwyn = Person { "sherwyn", 23 };
    println!("hi {}", sherwyn.name);
    println!("{:#?}", sherwyn);
}
