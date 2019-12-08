use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    // generate random
    let min = 1;
    let max = 10;
    let secret_number = rand::thread_rng().gen_range(min, max);

    // guess
    loop {
        println!("Guess the number ({} to {})", min, max - 1);
        println!("input: ");
        let mut guess = String::new();
        io::stdin()
            .read_line(&mut guess)
            .expect("error reading line");
        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => {
                println!("not a number!!");
                continue;
            }
        };

        // compare
        println!("your guess: {}", guess);
        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You Win");
                break;
            }
        }
    }
}
