/**
 * Domino Scorekeeper App Logic
 * Evaluates points, manages player selection, calculates winner, handles UI interactions.
 */

// State Management
const state = {
    gameMode: 2, // 2 or 4 players
    players: [],
    teamAScore: 0,
    teamBScore: 0,
    history: [],
    currentInput: "",
    targetScore: 200 // Default max score for domino match
};

// UI Elements
const viewSetup = document.getElementById('view-setup');
const viewScoreboard = document.getElementById('view-scoreboard');
const btnModeOptions = document.querySelectorAll('.btn-mode');
const btnLimitOptions = document.querySelectorAll('.btn-limit');
const playersFormContainer = document.getElementById('players-form-container');
const btnStartGame = document.getElementById('btn-start-game');
const cameraInput = document.getElementById('camera-input');

// Keypad
const pointsInput = document.getElementById('points-input');
const keypadKeys = document.querySelectorAll('.key');
const btnBackspace = document.getElementById('btn-backspace');

// Assign Buttons
const btnAddTeamA = document.getElementById('btn-add-team-a');
const btnAddTeamB = document.getElementById('btn-add-team-b');
const btnUndo = document.getElementById('btn-undo');
const btnEndGame = document.getElementById('btn-end-game');

// Active Avatar Button (for camera assignment)
let currentAvatarBtn = null;

// Initialize
function init() {
    renderPlayerForm(state.gameMode);
    attachEventListeners();
}

/**
 * Renders the player registration form based on mode (2 or 4 players)
 */
function renderPlayerForm(mode) {
    let html = '';
    
    if(mode === 2) {
        html = `
            <div class="team-section">
                <p class="section-title team-a-color">Jugador 1</p>
                <div class="player-input-group">
                    <button class="avatar-btn" data-player="0"><i class="ri-camera-fill"></i></button>
                    <input type="text" class="glass-input player-name" placeholder="Nombre" id="p_0">
                </div>
            </div>
            <div class="team-section">
                <p class="section-title team-b-color">Jugador 2</p>
                <div class="player-input-group">
                    <button class="avatar-btn" data-player="1"><i class="ri-camera-fill"></i></button>
                    <input type="text" class="glass-input player-name" placeholder="Nombre" id="p_1">
                </div>
            </div>
        `;
    } else {
        html = `
            <div class="team-section">
                <p class="section-title team-a-color">Equipo A</p>
                <div class="player-input-group">
                    <button class="avatar-btn" data-player="0"><i class="ri-camera-fill"></i></button>
                    <input type="text" class="glass-input player-name" placeholder="Jugador 1" id="p_0">
                </div>
                <div class="player-input-group">
                    <button class="avatar-btn" data-player="1"><i class="ri-camera-fill"></i></button>
                    <input type="text" class="glass-input player-name" placeholder="Jugador 2" id="p_1">
                </div>
            </div>
            
            <div class="team-section">
                <p class="section-title team-b-color">Equipo B</p>
                <div class="player-input-group">
                    <button class="avatar-btn" data-player="2"><i class="ri-camera-fill"></i></button>
                    <input type="text" class="glass-input player-name" placeholder="Jugador 3" id="p_2">
                </div>
                <div class="player-input-group">
                    <button class="avatar-btn" data-player="3"><i class="ri-camera-fill"></i></button>
                    <input type="text" class="glass-input player-name" placeholder="Jugador 4" id="p_3">
                </div>
            </div>
        `;
    }
    
    playersFormContainer.innerHTML = html;
    
    // Attach listener for avatar buttons
    document.querySelectorAll('.avatar-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            currentAvatarBtn = e.currentTarget;
            cameraInput.click();
        });
    });
}

/**
 * Main Event Listeners
 */
function attachEventListeners() {
    // Mode Selection
    btnModeOptions.forEach(btn => {
        btn.addEventListener('click', (e) => {
            btnModeOptions.forEach(b => b.classList.remove('active'));
            e.currentTarget.classList.add('active');
            state.gameMode = parseInt(e.currentTarget.dataset.mode);
            renderPlayerForm(state.gameMode);
        });
    });

    // Score Limit Selection
    btnLimitOptions.forEach(btn => {
        btn.addEventListener('click', (e) => {
            btnLimitOptions.forEach(b => b.classList.remove('active'));
            e.currentTarget.classList.add('active');
            state.targetScore = parseInt(e.currentTarget.dataset.limit);
        });
    });
    
    // Camera Input Handling (Convert file to Object URL)
    cameraInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if(file && currentAvatarBtn) {
            const url = URL.createObjectURL(file);
            currentAvatarBtn.innerHTML = `<img src="${url}" alt="Avatar">`;
            currentAvatarBtn.dataset.avatarSrc = url;
            currentAvatarBtn.style.border = 'none';
        }
    });

    // Start Game
    btnStartGame.addEventListener('click', startGame);

    // Keypad Logic
    keypadKeys.forEach(key => {
        key.addEventListener('click', (e) => {
            const val = e.currentTarget.dataset.val || e.currentTarget.innerText;
            // If they press "C" or "P" add straight value 100 or 25
            if(val === '100' || val === '25') {
                state.currentInput = val; 
            } else {
                if(state.currentInput === '100' || state.currentInput === '25') {
                    state.currentInput = '';
                }
                if(state.currentInput.length < 3) {
                    state.currentInput += val;
                }
            }
            updateInputDisplay();
        });
    });

    btnBackspace.addEventListener('click', () => {
        state.currentInput = state.currentInput.slice(0, -1);
        updateInputDisplay();
    });

    // Assigning Points
    btnAddTeamA.addEventListener('click', () => addPoints('A'));
    btnAddTeamB.addEventListener('click', () => addPoints('B'));

    btnUndo.addEventListener('click', undoLastScore);
    btnEndGame.addEventListener('click', resetApp);
    
    // Winner Modal
    document.getElementById('btn-new-game').addEventListener('click', hideWinnerModal);
    document.querySelector('.modal-backdrop').addEventListener('click', hideWinnerModal);
}

function updateInputDisplay() {
    pointsInput.value = state.currentInput;
}

function startGame() {
    state.players = [];
    const numPlayers = state.gameMode;
    
    for(let i=0; i<numPlayers; i++) {
        const input = document.getElementById(`p_${i}`);
        const avatarBtn = document.querySelector(`.avatar-btn[data-player="${i}"]`);
        
        let name = input.value.trim();
        if(!name) name = `Jugador ${i+1}`;
        
        let avatar = avatarBtn.dataset.avatarSrc || 'https://api.dicebear.com/7.x/initials/svg?seed=' + encodeURIComponent(name) + '&backgroundColor=0d1117&textColor=ffffff';
        
        state.players.push({ id: i, name, avatar });
    }

    // Set Teams Header Data
    if(state.gameMode === 2) {
        document.getElementById('team-a-name').innerText = state.players[0].name;
        document.getElementById('team-b-name').innerText = state.players[1].name;
        
        document.getElementById('team-a-avatars').innerHTML = `<img src="${state.players[0].avatar}" alt="">`;
        document.getElementById('team-b-avatars').innerHTML = `<img src="${state.players[1].avatar}" alt="">`;
        
        btnAddTeamA.innerHTML = `<i class="ri-arrow-left-line"></i> ${state.players[0].name.substring(0,6)}...`;
        btnAddTeamB.innerHTML = `${state.players[1].name.substring(0,6)}... <i class="ri-arrow-right-line"></i>`;
    } else {
        document.getElementById('team-a-name').innerText = "Equipo A";
        document.getElementById('team-b-name').innerText = "Equipo B";
        
        document.getElementById('team-a-avatars').innerHTML = `<img src="${state.players[0].avatar}" alt=""><img src="${state.players[1].avatar}" alt="">`;
        document.getElementById('team-b-avatars').innerHTML = `<img src="${state.players[2].avatar}" alt=""><img src="${state.players[3].avatar}" alt="">`;
        
        btnAddTeamA.innerHTML = `<i class="ri-arrow-left-line"></i> Eq. A`;
        btnAddTeamB.innerHTML = `Eq. B <i class="ri-arrow-right-line"></i>`;
    }

    viewSetup.classList.add('hidden');
    viewScoreboard.classList.remove('hidden');
    renderScore();
}

function addPoints(team) {
    const points = parseInt(state.currentInput);
    if(isNaN(points) || points <= 0) return;

    if(team === 'A') {
        state.teamAScore += points;
    } else {
        state.teamBScore += points;
    }

    state.history.push({ team, points });
    state.currentInput = '';
    updateInputDisplay();
    renderScore();

    // Pulse animation
    const el = document.getElementById(`team-${team.toLowerCase()}-score`);
    el.classList.remove('pulse-score');
    void el.offsetWidth; // trigger reflow
    el.classList.add('pulse-score');

    checkWin();
}

function undoLastScore() {
    if(state.history.length === 0) return;
    const lastOp = state.history.pop();
    
    if(lastOp.team === 'A') {
        state.teamAScore -= lastOp.points;
    } else {
        state.teamBScore -= lastOp.points;
    }
    
    renderScore();
}

function renderScore() {
    document.getElementById('team-a-score').innerText = state.teamAScore;
    document.getElementById('team-b-score').innerText = state.teamBScore;
    
    // Render History
    const historyList = document.getElementById('history-list');
    historyList.innerHTML = '';
    
    // Iterating backwards to show newest first
    for(let i = state.history.length - 1; i >= 0; i--) {
        const item = state.history[i];
        const teamName = item.team === 'A' ? 
            (state.gameMode === 2 ? state.players[0].name : "Equipo A") :
            (state.gameMode === 2 ? state.players[1].name : "Equipo B");
            
        const div = document.createElement('div');
        div.className = `history-item team-${item.team.toLowerCase()}-hist fade-in`;
        div.innerHTML = `
            <span>${teamName}</span>
            <span class="history-item-points">+${item.points}</span>
        `;
        historyList.appendChild(div);
    }
}

function checkWin() {
    if(state.teamAScore >= state.targetScore) {
        showWinnerModal('A', state.teamAScore);
    } else if (state.teamBScore >= state.targetScore) {
        showWinnerModal('B', state.teamBScore);
    }
}

function showWinnerModal(team, points) {
    // Función de confeti simple sin librería externa
    function fireConfetti() {
        const colors = ['#ffd700', '#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ff9f43'];
        
        // Crear canvas para confeti
        const canvas = document.createElement('canvas');
        canvas.id = 'confetti-canvas';
        canvas.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:9999;';
        document.body.appendChild(canvas);
        
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        const particles = [];
        const particleCount = 200;
        
        for (let i = 0; i < particleCount; i++) {
            particles.push({
                x: canvas.width / 2,
                y: canvas.height / 2,
                vx: (Math.random() - 0.5) * 20,
                vy: (Math.random() - 1) * 15,
                color: colors[Math.floor(Math.random() * colors.length)],
                size: Math.random() * 8 + 4,
                rotation: Math.random() * 360,
                rotationSpeed: (Math.random() - 0.5) * 10,
                gravity: 0.3,
                opacity: 1
            });
        }
        
        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            
            let allDone = false;
            
            particles.forEach(p => {
                p.x += p.vx;
                p.y += p.vy;
                p.vy += p.gravity;
                p.rotation += p.rotationSpeed;
                p.opacity -= 0.005;
                
                if (p.opacity <= 0) {
                    p.opacity = 0;
                    allDone = true;
                } else {
                    ctx.save();
                    ctx.translate(p.x, p.y);
                    ctx.rotate(p.rotation * Math.PI / 180);
                    ctx.fillStyle = p.color;
                    ctx.globalAlpha = p.opacity;
                    ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size);
                    ctx.restore();
                }
            });
            
            if (!allDone) {
                requestAnimationFrame(animate);
            } else {
                canvas.remove();
            }
        }
        
        animate();
    }
    
    // Ejecutar confeti
    fireConfetti();
    
    // Obtener datos del ganador
    let winnerName, winnerPhoto;
    if (state.gameMode === 2) {
        winnerName = team === 'A' ? state.players[0].name : state.players[1].name;
        winnerPhoto = team === 'A' ? state.players[0].avatar : state.players[1].avatar;
    } else {
        winnerName = team === 'A' ? 'Equipo A' : 'Equipo B';
        winnerPhoto = team === 'A' ? state.players[0].avatar : state.players[2].avatar;
    }
    
    // Actualizar modal con datos del winner
    document.getElementById('winner-photo').src = winnerPhoto;
    document.getElementById('winner-name').textContent = winnerName;
    document.getElementById('winner-points').textContent = points;
    
    // Mostrar modal con animación
    const modal = document.getElementById('modal-winner');
    modal.classList.remove('hidden');
    
    // Agregar clase para animación de entrada
    setTimeout(() => {
        modal.querySelector('.modal-content').classList.add('show');
    }, 50);
}

function hideWinnerModal() {
    const modal = document.getElementById('modal-winner');
    modal.querySelector('.modal-content').classList.remove('show');
    setTimeout(() => {
        modal.classList.add('hidden');
        resetApp(true);
    }, 300);
}

function resetApp(force = false) {
    if(force || confirm('¿Seguro que deseas terminar la partida actual y volver al menú?')) {
        state.teamAScore = 0;
        state.teamBScore = 0;
        state.history = [];
        state.currentInput = '';
        updateInputDisplay();
        
        viewScoreboard.classList.add('hidden');
        viewSetup.classList.remove('hidden');
    }
}

// Start
init();
