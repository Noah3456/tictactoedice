<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tic Tac Toe with Dice Roll</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .board {
            display: grid;
            grid-template-columns: repeat(3, 100px);
            grid-template-rows: repeat(3, 100px);
            gap: 5px;
        }
        .cell {
            width: 100px;
            height: 100px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2em;
            background-color: #f0f0f0;
            cursor: pointer;
        }
        .scores, .message, .dice-result, .advantages {
            margin: 10px;
        }
        .reset-button, .dice-button, .advantage-button, .reset-all-button {
            margin-top: 10px;
            padding: 5px 10px;
            cursor: pointer;
        }
        .reset-all-button {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background-color: #f44336;
            color: white;
            font-size: 1.2em;
            border: none;
        }
    </style>
</head>
<body>
    <div class="scores">
        <span id="scoreX">X: 0</span> | <span id="scoreO">O: 0</span>
    </div>
    <div class="board" id="board">
        <!-- Cells will be added by JavaScript -->
    </div>
    <div class="message" id="message"></div>
    <div class="dice-result" id="diceResult"></div>
    <div class="advantages" id="advantages"></div>
    <button class="dice-button" id="diceButton" style="display:none" onclick="rollDice()">Roll Dice</button>
    <button class="reset-button" onclick="resetGame()">Reset Game</button>
    <button class="advantage-button" id="deleteButton" style="display:none" onclick="enableDeleteMode()">Use Delete Advantage</button>
    <button class="reset-all-button" onclick="resetAll()">Reset All</button>

    <script>
        let board = [['', '', ''], ['', '', ''], ['', '', '']];
        let currentPlayer = 'X';
        let scores = { 'X': 0, 'O': 0 };
        let gameOver = false;
        let advantages = { 'X': [], 'O': [] };
        let deleteMode = false;

        const boardElement = document.getElementById('board');
        const messageElement = document.getElementById('message');
        const scoreXElement = document.getElementById('scoreX');
        const scoreOElement = document.getElementById('scoreO');
        const diceResultElement = document.getElementById('diceResult');
        const diceButton = document.getElementById('diceButton');
        const advantagesElement = document.getElementById('advantages');
        const deleteButton = document.getElementById('deleteButton');

        function initBoard() {
            boardElement.innerHTML = '';
            for (let i = 0; i < 3; i++) {
                for (let j = 0; j < 3; j++) {
                    const cell = document.createElement('div');
                    cell.className = 'cell';
                    cell.dataset.row = i;
                    cell.dataset.col = j;
                    cell.addEventListener('click', makeMove);
                    boardElement.appendChild(cell);
                }
            }
            updateAdvantagesDisplay();
        }

        function makeMove(event) {
            if (gameOver || deleteMode) return;
            const row = event.target.dataset.row;
            const col = event.target.dataset.col;
            if (board[row][col] === '') {
                board[row][col] = currentPlayer;
                event.target.textContent = currentPlayer;
                if (checkWinner(currentPlayer)) {
                    scores[currentPlayer]++;
                    messageElement.textContent = `Player ${currentPlayer} wins!`;
                    updateScores();
                    gameOver = true;
                    diceButton.style.display = 'block';
                } else if (checkDraw()) {
                    messageElement.textContent = `It's a draw!`;
                    gameOver = true;
                } else {
                    currentPlayer = currentPlayer === 'X' ? 'O' : 'X';
                    updateAdvantagesDisplay();
                }
            }
        }

        function checkWinner(player) {
            for (let i = 0; i < 3; i++) {
                if (board[i].every(cell => cell === player)) return true;
                if (board.map(row => row[i]).every(cell => cell === player)) return true;
            }
            if ([0, 1, 2].map(i => board[i][i]).every(cell => cell === player)) return true;
            if ([0, 1, 2].map(i => board[i][2 - i]).every(cell => cell === player)) return true;
            return false;
        }

        function checkDraw() {
            return board.flat().every(cell => cell !== '');
        }

        function resetGame() {
            board = [['', '', ''], ['', '', ''], ['', '', '']];
            currentPlayer = 'X';
            gameOver = false;
            deleteMode = false;
            messageElement.textContent = '';
            diceResultElement.textContent = '';
            diceButton.style.display = 'none';
            initBoard();
            updateAdvantagesDisplay(); // Ensure advantage buttons are displayed after reset
        }

        function resetAll() {
            scores = { 'X': 0, 'O': 0 };
            advantages = { 'X': [], 'O': [] };
            updateScores();
            resetGame();
        }

        function updateScores() {
            scoreXElement.textContent = `X: ${scores['X']}`;
            scoreOElement.textContent = `O: ${scores['O']}`;
        }

        function rollDice() {
            const roll = Math.floor(Math.random() * 6) + 1;
            diceResultElement.textContent = `You rolled a ${roll}`;
            diceButton.style.display = 'none';

            if (roll === 6) {
                advantages[currentPlayer].push('delete');
                messageElement.textContent = `Player ${currentPlayer} gets an advantage: Delete Opponent's Mark!`;
            } else if (roll === 4) {
                messageElement.textContent = `Player ${currentPlayer} gets an advantage: Roll Again!`;
                rollDice();
                return;
            }
            updateAdvantagesDisplay();
        }

        function updateAdvantagesDisplay() {
            advantagesElement.innerHTML = `
                <div>Player X's Advantages: ${advantages['X'].join(', ')}</div>
                <div>Player O's Advantages: ${advantages['O'].join(', ')}</div>
            `;
            deleteButton.style.display = advantages[currentPlayer].includes('delete') ? 'block' : 'none';
        }

        function enableDeleteMode() {
            if (advantages[currentPlayer].includes('delete')) {
                deleteMode = true;
                messageElement.textContent = `Player ${currentPlayer}, click on an opponent's mark to delete it.`;
                advantages[currentPlayer] = advantages[currentPlayer].filter(adv => adv !== 'delete');
                updateAdvantagesDisplay();
            }
        }

        function deleteOpponentMark(event) {
            const row = event.target.dataset.row;
            const col = event.target.dataset.col;
            if (board[row][col] !== '' && board[row][col] !== currentPlayer) {
                board[row][col] = '';
                event.target.textContent = '';
                deleteMode = false;
                messageElement.textContent = `Player ${currentPlayer} deleted an opponent's mark!`;
            }
        }

        boardElement.addEventListener('click', function(event) {
            if (deleteMode) {
                deleteOpponentMark(event);
            }
        });

        initBoard();
    </script>
</body>
</html>
