fn factorial(n: u64) -> u64 {
    (1..=n).product()
}

fn hash_board(board: Vec<u64>) -> u64 {
    let head_hash: u64 = board[0] * factorial((board.len() - 1) as u64);
    if board.len() == 1 {
        return head_hash;
    }

    let tail: Vec<u64> = (board[1..])
        .into_iter()
        .map(|tile| if tile > &board[0] { tile - 1 } else { *tile })
        .collect();

    head_hash + hash_board(tail)
}

fn main() {
    println!("{}", hash_board(vec![0, 1]));
    println!("{}", hash_board(vec![1, 0]));
    println!("{}", hash_board(vec![3, 0, 1, 2]));
    println!("{}", hash_board(vec![3, 2, 1, 0]));
    println!("{}", hash_board((0..=7).rev().collect::<Vec<u64>>()));
    println!("{}", hash_board((0..16).rev().collect::<Vec<u64>>()));
}
