import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

struct Coordinate: Equatable {
    let x: Int
    let y: Int
}

struct Player {
    let coordinate: Coordinate
    let isEnemy: Bool
}

class Square {
    enum Status {
        case empty
        case player
        case opponent1
        case opponent2
        case opponent3
    }
    
    var score: Int = 0
    let status: Status
    let coordinate: Coordinate
    
    // Init with a coordinate and a character read from readLine() in grid
    init(coordinate: Coordinate, character: Character) {
        self.coordinate = coordinate
        if character == "0" { self.status = .player }
        else if character == "1" { self.status = .opponent1 }
        else if character == "2" { self.status = .opponent2 }
        else if character == "3" { self.status = .opponent3 }
        else { self.status = .empty }
    }
    
    // The distance from this square to another square
    func distance(to: Coordinate) -> Int {
        return abs(coordinate.x - to.x) + abs(coordinate.y - to.y)
    }
    
    // Print this square without terminating the line
    func printSquare() {
        print("\(score) ", terminator: "", to: &errStream)
    }
}

class Grid {
    private var grid = [[Square]]()
    
    // The init function will readLine() and setup the internal grid automatically
    init() {
        for y in 0...19 {
            var subArray = [Square]()
            for (x, character) in readLine()!.enumerated() {
                let coordinate = Coordinate(x: x, y: y)
                subArray.append(Square(coordinate: coordinate, character: character))
            }
            grid.append(subArray)
        }
    }
    
    // To enable access of [x, y] on the grid
    subscript(x: Int, y: Int) -> Square {
        get { return grid[y][x] }
        set { grid[y][x] = newValue }
    }

    // Finds the square with the highest score on the grid
    var bestSquare: Square {
        var best = self[0, 0]
        for row in grid {
            for square in row {
                if square.score > best.score {
                    best = square
                }
            }
        }
        return best
    }
    
    // Go through all squares on the grid and give them a score
    func evaluate(player: Player) {
        for row in grid {
            for square in row {
                var score = 99 - square.distance(to: player.coordinate)
                if square.status == .player {
                    score -= 10
                } else if square.status != .empty {
                    score -= 15
                }
                square.score = score
            }
        }
    }
    
    // Print each square on the grid
    func printGrid() {
        for row in grid {
            for square in row {
                square.printSquare()
            }
            print("", to: &errStream)
        }
    }
}

let opponentCount = Int(readLine()!)! // Opponent count

// game loop
while true {
    let gameRound = Int(readLine()!)!
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    let currentX = Int(inputs[0])! // Your x position
    let currentY = Int(inputs[1])! // Your y position
    let player = Player(coordinate: Coordinate(x: currentX, y: currentY), isEnemy: false)
    let backInTimeLeft = Int(inputs[2])! // Remaining back in time
    var opponents = [Player]()
    if opponentCount > 0 {
        for i in 0...(opponentCount-1) {
            let inputs = (readLine()!).split(separator: " ").map(String.init)
            let opponentX = Int(inputs[0])! // X position of the opponent
            let opponentY = Int(inputs[1])! // Y position of the opponent
            let opponentBackInTimeLeft = Int(inputs[2])! // Remaining back in time of the opponent
            opponents.append(Player(coordinate: Coordinate(x: opponentX, y: opponentY), isEnemy: true))
        }
    }
    
    var grid = Grid()
    grid.evaluate(player: player)
    grid.printGrid()
    
    var best = grid.bestSquare
    print("\(best.coordinate.x) \(best.coordinate.y)")
}
