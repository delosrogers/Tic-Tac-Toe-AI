use std::io;

fn main() {
    let mut board = vec!["", "", "", "", "", "", "", "", ""];

    let mut move_str: String = String::new();
    loop {
        let best_move_idx = make_best_move(&mut board);
        board[best_move_idx] = "PlayerX";
        if checkwin(&board) {
            println!("The AI won");
            println!(
                "{},{},{},\n{},{},{},\n{},{},{},",
                board[0],
                board[1],
                board[2],
                board[3],
                board[4],
                board[5],
                board[6],
                board[7],
                board[8]
            );
            break;
        }
        println!(
            "{},{},{},\n{},{},{},\n{},{},{},",
            board[0],
            board[1],
            board[2],
            board[3],
            board[4],
            board[5],
            board[6],
            board[7],
            board[8]
        );
        println!("make a move");
        io::stdin()
            .read_line(&mut move_str)
            .expect("couldn't read");
        let move_idx: usize = match move_str.trim().parse()
        {
            Ok(num) => num,
            Err(_) => {
                println!("Enter a number");
                continue;
            }
        };
        board[move_idx] = "PlayerO";
        if checkwin(&board) {
            println!("You won congrats");
            println!(
                "{},{},{},\n{},{},{},\n{},{},{},",
                board[0],
                board[1],
                board[2],
                board[3],
                board[4],
                board[5],
                board[6],
                board[7],
                board[8]
            );
            break;
        }
    }
}

fn make_best_move(board: &mut Vec<&str>) -> usize {
    let mut best_score = -(f64::INFINITY) as isize;
    let mut best_move = 0;
    for i in 0..board.len() {
        if board[i] == "" {
            board[i] = "PlayerX";
            let this_score = minimax(&mut *board, 0, false);
            board[i] = "";
            if this_score > best_score {
                best_score = this_score;
                best_move = i;
            }
        }
    }
    best_move
}

fn minimax(board: &mut Vec<&str>, depth: i32, is_maximizing: bool) -> isize {
    if checkwin(&board) {
        if is_maximizing {
            // println!("found a loss {:?} depth:{}", board, depth);
            return -10;
        } else {
            // println!("found a win {:?} depth:{}", board, depth);
            return 10;
        }
    } else if !(board.iter().any(|&player| player == "")) {
        // println!("returned tie");
        return 0;
    }
    let mut best_score = if is_maximizing {
        -(f64::INFINITY as isize)
    } else {
        f64::INFINITY as isize
    };
    if is_maximizing {
        for i in 0..board.len() {
            if board[i] == "" {
                board[i] = "PlayerX";
                let this_score = minimax(&mut *board, depth + 1, !is_maximizing);
                board[i] = "";
                best_score = std::cmp::max(this_score, best_score);
            }
        }
    } else {
        for i in 0..board.len() {
            if board[i] == "" {
                board[i] = "PlayerO";
                let this_score = minimax(&mut *board, depth + 1, !is_maximizing);
                board[i] = "";
                best_score = std::cmp::min(this_score, best_score);
            }
        }
    }
    best_score
}

fn checkwin(board: &Vec<&str>) -> bool {
    (board[0] == board[1] && board[1] == board[2] && board[0] != "")
        || (board[3] == board[4] && board[4] == board[5] && board[3] != "")
        || (board[6] == board[7] && board[7] == board[8] && board[6] != "")
        || (board[0] == board[3] && board[3] == board[6] && board[0] != "")
        || (board[1] == board[4] && board[4] == board[7] && board[7] != "")
        || (board[2] == board[5] && board[5] == board[8] && board[2] != "")
        || (board[0] == board[4] && board[4] == board[8] && board[8] != "")
        || (board[2] == board[4] && board[4] == board[6] && board[2] != "")
}
