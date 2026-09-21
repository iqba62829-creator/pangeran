<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Retro Tank Battle - Shooting Enemy Update</title>
    <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; touch-action: none; user-select: none; }
        body, html { width: 100%; height: 100%; overflow: hidden; background: #000; font-family: 'Press Start 2P', monospace; }
        
        #container { display: flex; flex-direction: column; width: 100vw; height: 100vh; }
        
        #game-view { width: 100%; height: 65%; background: #5c4033; position: relative; overflow: hidden; border-bottom: 4px solid #333; }
        #canvas { display: block; width: 100%; height: 100%; image-rendering: pixelated; }
        
        #ui { position: absolute; top: 10px; left: 12px; right: 12px; display: flex; flex-direction: column; gap: 8px; z-index: 10; pointer-events: none; }
        .ui-top { display: flex; justify-content: space-between; align-items: center; color: #55ff55; font-size: 8px; text-shadow: 2px 2px #000; }
        
        .laser-container { display: flex; align-items: center; gap: 6px; font-size: 7px; color: #00ffff; text-shadow: 1px 1px #000; }
        .laser-bar-outer { width: 100px; height: 10px; background: #222; border: 2px solid #00ffff; border-radius: 2px; overflow: hidden; }
        .laser-bar-inner { width: 0%; height: 100%; background: linear-gradient(90deg, #0088ff, #00ffff); transition: width 0.1s linear; }
        
        .btn-pause {
            background: #222; color: #ffff55; border: 2px solid #ffff55; padding: 5px 8px; font-family: 'Press Start 2P', monospace; font-size: 7px; cursor: pointer; border-radius: 4px; box-shadow: 0 2px #000; pointer-events: auto;
        }
        .btn-pause:active { transform: translateY(2px); box-shadow: none; }

        #controls { width: 100%; height: 35%; background: #111; display: flex; align-items: center; justify-content: space-around; padding: 8px; border-top: 2px solid #222; }
        
        .move-group { display: flex; flex-direction: column; gap: 8px; width: 28%; max-width: 100px; }
        .btn-move {
            width: 100%; height: 46px; background-color: #2b2b2b; color: #55ff55; border: 3px solid #444; border-radius: 4px;
            font-family: 'Press Start 2P', monospace; font-size: 14px; box-shadow: 0 4px #000; cursor: pointer;
        }
        .btn-move:active { background-color: #444; transform: translateY(2px); box-shadow: 0 2px #000; }

        .action-group { display: flex; gap: 8px; width: 68%; max-width: 260px; }

        .btn-shoot {
            flex: 1; height: 100px; background-color: #d32f2f; color: #fff; border: 4px solid #ff6666; border-radius: 8px;
            font-family: 'Press Start 2P', monospace; font-size: 9px; box-shadow: 0 5px #7b1fa2; cursor: pointer; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px;
        }
        .btn-shoot:active { background-color: #b71c1c; transform: translateY(3px); box-shadow: 0 2px #7b1fa2; }

        .btn-laser {
            flex: 1; height: 100px; background-color: #333; color: #888; border: 4px solid #555; border-radius: 8px;
            font-family: 'Press Start 2P', monospace; font-size: 8px; box-shadow: 0 5px #222; cursor: not-allowed; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; opacity: 0.6; transition: 0.2s;
        }
        .btn-laser.ready {
            background-color: #0088cc; color: #fff; border-color: #00ffff; box-shadow: 0 5px #004466, 0 0 10px #00ffff; cursor: pointer; opacity: 1; animation: pulse 0.8s infinite alternate;
        }
        .btn-laser.ready:active { transform: translateY(3px); box-shadow: 0 2px #004466; }

        @keyframes pulse {
            0% { border-color: #00ffff; box-shadow: 0 5px #004466, 0 0 5px #00ffff; }
            100% { border-color: #ffffff; box-shadow: 0 5px #004466, 0 0 15px #00ffff; }
        }

        .overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 50; text-align: center; padding: 20px; }
        .title { font-size: 11px; color: #ffcc00; margin-bottom: 12px; line-height: 1.5; letter-spacing: 1px; }
        .desc { font-size: 6px; color: #aaa; line-height: 1.6; max-width: 280px; margin-bottom: 20px; }
        .btn-start { padding: 12px 24px; background: #00aa00; color: #fff; border: 2px solid #55ff55; border-radius: 0px; font-family: 'Press Start 2P', monospace; font-size: 8px; cursor: pointer; box-shadow: 0 4px #005500; }
        .btn-start:active { transform: translateY(2px); box-shadow: 0 2px #005500; }
    </style>
</head>
<body>

<div id="container">
    <div id="game-view">
        <div id="ui">
            <div class="ui-top">
                <div>LIFE: <span id="ui-hp" style="color: #ff5555;">â¤ï¸â¤ï¸â¤ï¸</span></div>
                <button class="btn-pause" id="pauseBtn" onclick="togglePause()">PAUSE</button>
                <div>SCORE: <span id="ui-score" style="color: #ffff55;">0</span></div>
            </div>
            <div class="laser-container">
                <span>LASER GAUGE:</span>
                <div class="laser-bar-outer">
                    <div id="laser-bar-fill" class="laser-bar-inner"></div>
                </div>
            </div>
        </div>
        <canvas id="canvas"></canvas>

        <div id="start-overlay" class="overlay">
            <h1 class="title">RETRO TANK BATTLE</h1>
            <p class="desc">Awas! Tank musuh berjalan pelan tapi bisa menembak balik! Hancurkan mereka dan gunakan Super Laser [E]!</p>
            <button class="btn-start" onclick="startGame()">START GAME</button>
        </div>

        <div id="pause-overlay" class="overlay" style="display: none;">
            <h1 class="title" style="color: #ffff55;">GAME PAUSED</h1>
            <button class="btn-start" onclick="togglePause()">RESUME</button>
        </div>

        <div id="gameover-overlay" class="overlay" style="display: none;">
            <h1 class="title" style="color: #ff3333;">MISSION FAILED</h1>
            <p id="final-score" class="desc">TOTAL SCORE: 0</p>
            <button class="btn-start" onclick="startGame()">TRY AGAIN</button>
        </div>
    </div>

    <div id="controls">
        <div class="move-group">
            <button class="btn-move" id="upBtn">â–²</button>
            <button class="btn-move" id="downBtn">â–¼</button>
        </div>
        <div class="action-group">
            <button class="btn-shoot" id="shootBtn">
                <span>FIRE!</span>
                <span style="font-size: 14px;">ðŸ’£</span>
            </button>
            <button class="btn-laser" id="laserBtn" onclick="fireLaser()">
                <span>ULTIMATE</span>
                <span style="font-size: 14px;">âš¡</span>
            </button>
        </div>
    </div>
</div>

<script>
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext("2d");

    // --- AUDIO RETRO ---
    let audioCtx = null;
    let bgmInterval = null;
    let bgmStep = 0;

    const melody = [
        150, 200, 250, 200, 150, 300, 250, 200,
        180, 220, 270, 220, 180, 330, 270, 220
    ];

    function initAudio() {
        if (!audioCtx) {
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        if (audioCtx.state === 'suspended') {
            audioCtx.resume();
        }
    }

    function startBGM() {
        stopBGM();
        bgmStep = 0;
        bgmInterval = setInterval(() => {
            if (gameState !== "playing" || !audioCtx) return;
            
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(melody[bgmStep], audioCtx.currentTime);
            gain.gain.setValueAtTime(0.05, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.12);
            
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            
            osc.start();
            osc.stop(audioCtx.currentTime + 0.12);
            
            bgmStep = (bgmStep + 1) % melody.length;
        }, 150);
    }

    function stopBGM() {
        if (bgmInterval) {
            clearInterval(bgmInterval);
            bgmInterval = null;
        }
    }

    function playShootSound(pitch = 400) {
        if (!audioCtx) return;
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(pitch, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(80, audioCtx.currentTime + 0.15);
        gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.15);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.15);
    }

    function playLaserSound() {
        if (!audioCtx) return;
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(800, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(120, audioCtx.currentTime + 0.5);
        gain.gain.setValueAtTime(0.4, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.5);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.5);
    }

    function playExplosionSound() {
        if (!audioCtx) return;
        const bufferSize = audioCtx.sampleRate * 0.2;
        const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) data[i] = Math.random() * 2 - 1;

        const noise = audioCtx.createBufferSource();
        noise.buffer = buffer;
        const filter = audioCtx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(600, audioCtx.currentTime);
        filter.frequency.linearRampToValueAtTime(80, audioCtx.currentTime + 0.2);

        const gain = audioCtx.createGain();
        gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.2);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(audioCtx.destination);

        noise.start();
        noise.stop(audioCtx.currentTime + 0.2);
    }

    function playGameOverSound() {
        if (!audioCtx) return;
        const notes = [200, 150, 100];
        notes.forEach((freq, idx) => {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'square';
            osc.frequency.setValueAtTime(freq, audioCtx.currentTime + idx * 0.15);
            gain.gain.setValueAtTime(0.3, audioCtx.currentTime + idx * 0.15);
            gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + (idx + 1) * 0.15);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start(audioCtx.currentTime + idx * 0.15);
            osc.stop(audioCtx.currentTime + (idx + 1) * 0.15);
        });
    }

    // --- GAME LOGIC ---
    let gameState = "start";
    let score = 0;
    let baseHp = 3;
    let enemies = [];
    let bullets = [];
    let enemyBullets = []; // Peluru tembakan musuh
    let explosions = [];
    let activeLaser = null;
    let spawnTimer = 0;
    let groundDetails = [];
    let laserGauge = 0;

    const tank = { x: 20, y: 0, w: 36, h: 36, speed: 220 };
    const keys = { up: false, down: false };

    function generateGroundDetails() {
        groundDetails = [];
        const numDetails = Math.floor((canvas.width * canvas.height) / 3000);
        for (let i = 0; i < numDetails; i++) {
            groundDetails.push({
                x: Math.random() * canvas.width,
                y: 12 + Math.random() * (canvas.height - 24),
                w: Math.random() > 0.5 ? 4 : 8,
                h: Math.random() > 0.5 ? 4 : 8,
                type: Math.floor(Math.random() * 3)
            });
        }
    }

    function resizeCanvas() {
        canvas.width = canvas.parentElement.offsetWidth;
        canvas.height = canvas.parentElement.offsetHeight;
        generateGroundDetails();
        if (gameState === "start") {
            tank.y = canvas.height / 2 - tank.h / 2;
        }
    }
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();

    function startGame() {
        initAudio();
        document.getElementById("start-overlay").style.display = "none";
        document.getElementById("pause-overlay").style.display = "none";
        document.getElementById("gameover-overlay").style.display = "none";
        document.getElementById("pauseBtn").innerText = "PAUSE";
        score = 0;
        baseHp = 3;
        laserGauge = 0;
        enemies = [];
        bullets = [];
        enemyBullets = [];
        explosions = [];
        activeLaser = null;
        spawnTimer = 0;
        tank.y = canvas.height / 2 - tank.h / 2;
        gameState = "playing";
        updateUI();
        startBGM();
    }

    function togglePause() {
        if (gameState === "playing") {
            gameState = "paused";
            document.getElementById("pause-overlay").style.display = "flex";
            document.getElementById("pauseBtn").innerText = "RESUME";
            stopBGM();
        } else if (gameState === "paused") {
            gameState = "playing";
            document.getElementById("pause-overlay").style.display = "none";
            document.getElementById("pauseBtn").innerText = "PAUSE";
            startBGM();
        }
    }

    function addGauge(val) {
        laserGauge = Math.min(100, laserGauge + val);
        updateUI();
    }

    function updateUI() {
        let hearts = "";
        for (let i = 0; i < baseHp; i++) hearts += "â¤ï¸";
        document.getElementById("ui-hp").innerText = hearts || "ðŸ’€";
        document.getElementById("ui-score").innerText = score;

        const fill = document.getElementById("laser-bar-fill");
        fill.style.width = laserGauge + "%";

        const btnLaser = document.getElementById("laserBtn");
        if (laserGauge >= 100) {
            btnLaser.classList.add("ready");
        } else {
            btnLaser.classList.remove("ready");
        }
    }

    function takeDamage() {
        baseHp--;
        updateUI();
        createExplosion(tank.x + tank.w / 2, tank.y + tank.h / 2);
        if (baseHp <= 0) {
            gameState = "gameover";
            stopBGM();
            playGameOverSound();
            document.getElementById("final-score").innerText = "TOTAL SCORE: " + score;
            document.getElementById("gameover-overlay").style.display = "flex";
        }
    }

    function shootBullet() {
        if (gameState !== "playing") return;
        initAudio();
        playShootSound(400);
        bullets.push({ 
            x: tank.x + tank.w + 4, 
            y: tank.y + tank.h / 2 - 2, 
            speed: 450, 
            w: 8,
            h: 4
        });
    }

    function fireLaser() {
        if (gameState !== "playing" || laserGauge < 100) return;
        initAudio();
        playLaserSound();
        
        laserGauge = 0;
        updateUI();

        const laserHeight = 30;
        const laserY = tank.y + tank.h / 2 - laserHeight / 2;

        activeLaser = {
            y: laserY,
            h: laserHeight,
            timer: 0.4
        };

        // Hancurkan musuh & peluru musuh di area laser
        for (let i = enemies.length - 1; i >= 0; i--) {
            let e = enemies[i];
            if (e.y + e.h >= laserY && e.y <= laserY + laserHeight) {
                createExplosion(e.x + e.w / 2, e.y + e.h / 2);
                enemies.splice(i, 1);
                score += 150;
            }
        }
        for (let i = enemyBullets.length - 1; i >= 0; i--) {
            let eb = enemyBullets[i];
            if (eb.y + eb.h >= laserY && eb.y <= laserY + laserHeight) {
                enemyBullets.splice(i, 1);
            }
        }
        updateUI();
    }

    function createExplosion(x, y) {
        playExplosionSound();
        explosions.push({ x: x, y: y, radius: 4, maxRadius: 18, alpha: 1.0 });
    }

    // Input Control Keyboard
    window.addEventListener("keydown", (e) => {
        initAudio();
        if (e.key === "p" || e.key === "P") togglePause();
        if (gameState !== "playing") return;
        if (e.key === "ArrowUp" || e.key === "w" || e.key === "W") keys.up = true;
        if (e.key === "ArrowDown" || e.key === "s" || e.key === "S") keys.down = true;
        if (e.key === " ") shootBullet();
        if (e.key === "e" || e.key === "E" || e.key === "Shift") fireLaser();
    });

    window.addEventListener("keyup", (e) => {
        if (e.key === "ArrowUp" || e.key === "w" || e.key === "W") keys.up = false;
        if (e.key === "ArrowDown" || e.key === "s" || e.key === "S") keys.down = false;
    });

    const setupBtn = (id, keyName) => {
        const btn = document.getElementById(id);
        btn.addEventListener("touchstart", (e) => { e.preventDefault(); initAudio(); keys[keyName] = true; });
        btn.addEventListener("touchend", (e) => { e.preventDefault(); keys[keyName] = false; });
        btn.addEventListener("mousedown", () => { initAudio(); keys[keyName] = true; });
        btn.addEventListener("mouseup", () => keys[keyName] = false);
    };

    setupBtn("upBtn", "up");
    setupBtn("downBtn", "down");

    document.getElementById("shootBtn").addEventListener("click", () => shootBullet());
    document.getElementById("shootBtn").addEventListener("touchstart", (e) => { e.preventDefault(); shootBullet(); });
    document.getElementById("laserBtn").addEventListener("touchstart", (e) => { e.preventDefault(); fireLaser(); });

    let lastTime = performance.now();

    function loop(timestamp) {
        let dt = (timestamp - lastTime) / 1000;
        if (dt > 0.1) dt = 0.1;
        lastTime = timestamp;

        if (gameState === "playing") {
            if (laserGauge < 100) addGauge(3 * dt);

            if (keys.up) tank.y -= tank.speed * dt;
            if (keys.down) tank.y += tank.speed * dt;

            const minY = 12;
            const maxY = canvas.height - tank.h - 12;
            if (tank.y < minY) tank.y = minY;
            if (tank.y > maxY) tank.y = maxY;

            // Spawn Musuh (Kecepatan diperlambat: 30 - 50 px/s)
            spawnTimer += dt;
            if (spawnTimer > 1.8) {
                spawnTimer = 0;
                enemies.push({
                    x: canvas.width,
                    y: Math.random() * (canvas.height - 56) + 14,
                    w: 32,
                    h: 32,
                    speed: Math.random() * 20 + 35, // Gerakan pelan
                    shootTimer: Math.random() * 1.5 + 0.5 // Timer jeda tembak musuh
                });
            }

            // Update Tembakan Musuh (Enemy Shooting AI)
            enemies.forEach(e => {
                e.shootTimer -= dt;
                if (e.shootTimer <= 0) {
                    e.shootTimer = Math.random() * 2.5 + 1.5; // Tembak setiap 1.5 - 4 detik
                    playShootSound(200);
                    enemyBullets.push({
                        x: e.x - 6,
                        y: e.y + e.h / 2 - 2,
                        speed: 250,
                        w: 8,
                        h: 4
                    });
                }
            });

            // Update Peluru Player
            for (let i = bullets.length - 1; i >= 0; i--) {
                bullets[i].x += bullets[i].speed * dt;
                if (bullets[i].x > canvas.width) {
                    bullets.splice(i, 1);
                }
            }

            // Update Peluru Musuh
            for (let i = enemyBullets.length - 1; i >= 0; i--) {
                let eb = enemyBullets[i];
                eb.x -= eb.speed * dt;

                // Peluru Musuh Kena Player
                if (eb.x <= tank.x + tank.w &&
                    eb.x + eb.w >= tank.x &&
                    eb.y + eb.h >= tank.y &&
                    eb.y <= tank.y + tank.h) {
                    
                    enemyBullets.splice(i, 1);
                    takeDamage();
                    continue;
                }

                // Peluru Player Tangkis Peluru Musuh
                for (let j = bullets.length - 1; j >= 0; j--) {
                    let pb = bullets[j];
                    if (pb && eb &&
                        pb.x + pb.w >= eb.x &&
                        pb.x <= eb.x + eb.w &&
                        pb.y + pb.h >= eb.y &&
                        pb.y <= eb.y + eb.h) {
                        
                        createExplosion(eb.x, eb.y);
                        bullets.splice(j, 1);
                        enemyBullets.splice(i, 1);
                        break;
                    }
                }

                if (eb && eb.x < 0) enemyBullets.splice(i, 1);
            }

            // Update Musuh & Tabrakan garis belakang
            for (let i = enemies.length - 1; i >= 0; i--) {
                enemies[i].x -= enemies[i].speed * dt;

                // Musuh capai garis depan
                if (enemies[i].x <= tank.x + tank.w) {
                    enemies.splice(i, 1);
                    takeDamage();
                    continue;
                }

                // Peluru Player Kena Musuh
                for (let j = bullets.length - 1; j >= 0; j--) {
                    let b = bullets[j];
                    let e = enemies[i];

                    if (b && e && 
                        b.x + b.w >= e.x && 
                        b.x <= e.x + e.w && 
                        b.y + b.h >= e.y && 
                        b.y <= e.y + e.h) {
                        
                        createExplosion(e.x + e.w / 2, e.y + e.h / 2);
                        enemies.splice(i, 1);
                        bullets.splice(j, 1);
                        score += 100;
                        addGauge(15);
                        break;
                    }
                }
            }

            // Update Animasi Laser
            if (activeLaser) {
                activeLaser.timer -= dt;
                if (activeLaser.timer <= 0) activeLaser = null;
            }

            // Update Ledakan
            for (let i = explosions.length - 1; i >= 0; i--) {
                explosions[i].radius += 40 * dt;
                explosions[i].alpha -= 2 * dt;
                if (explosions[i].alpha <= 0) {
                    explosions.splice(i, 1);
                }
            }
        }

        // --- RENDER GAME ---
        // 1. Tanah
        ctx.fillStyle = "#6e4726";
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Detail Tanah
        groundDetails.forEach(d => {
            if (d.type === 0) ctx.fillStyle = "#4a2e16";
            else if (d.type === 1) ctx.fillStyle = "#8c8275";
            else ctx.fillStyle = "#3b220c";
            ctx.fillRect(d.x, d.y, d.w, d.h);
        });

        // Batas Rumput
        ctx.fillStyle = "#33aa33";
        ctx.fillRect(0, 0, canvas.width, 10);
        ctx.fillRect(0, canvas.height - 10, canvas.width, 10);

        ctx.fillStyle = "#55ff55";
        for (let x = 0; x < canvas.width; x += 12) {
            ctx.fillRect(x, 10, 4, 3);
            ctx.fillRect(x + 6, canvas.height - 13, 4, 3);
        }

        // Grid Retro
        ctx.strokeStyle = "rgba(0, 0, 0, 0.15)";
        ctx.lineWidth = 1;
        for (let x = 0; x < canvas.width; x += 24) {
            ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke();
        }
        for (let y = 0; y < canvas.height; y += 24) {
            ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke();
        }

        // 2. Tank Player (Hijau)
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(tank.x, tank.y, tank.w, 6);
        ctx.fillRect(tank.x, tank.y + tank.h - 6, tank.w, 6);

        ctx.fillStyle = "#00aa00";
        ctx.fillRect(tank.x + 4, tank.y + 4, tank.w - 8, tank.h - 8);

        ctx.fillStyle = "#55ff55";
        ctx.fillRect(tank.x + 10, tank.y + 10, 14, 14);

        ctx.fillStyle = "#ffffff";
        ctx.fillRect(tank.x + 20, tank.y + 15, 16, 6);

        // 3. Tank Musuh (Merah)
        enemies.forEach(e => {
            ctx.fillStyle = "#333333";
            ctx.fillRect(e.x, e.y, e.w, 5);
            ctx.fillRect(e.x, e.y + e.h - 5, e.w, 5);

            ctx.fillStyle = "#aa0000";
            ctx.fillRect(e.x + 4, e.y + 3, e.w - 8, e.h - 6);

            ctx.fillStyle = "#ff5555";
            ctx.fillRect(e.x + 10, e.y + 9, 12, 12);

            // Meriam musuh menghadap kiri
            ctx.fillStyle = "#ffffff";
            ctx.fillRect(e.x - 8, e.y + 13, 12, 5);
        });

        // 4. Peluru Player (Kuning)
        ctx.fillStyle = "#ffff00";
        bullets.forEach(b => {
            ctx.fillRect(b.x, b.y, b.w, b.h);
        });

        // 5. Peluru Musuh (Merah Cerah)
        ctx.fillStyle = "#ff3300";
        enemyBullets.forEach(eb => {
            ctx.fillRect(eb.x, eb.y, eb.w, eb.h);
        });

        // 6. Super Laser
        if (activeLaser) {
            ctx.fillStyle = "rgba(0, 255, 255, 0.4)";
            ctx.fillRect(tank.x + tank.w, activeLaser.y - 6, canvas.width, activeLaser.h + 12);

            ctx.fillStyle = "#00ffff";
            ctx.fillRect(tank.x + tank.w, activeLaser.y, canvas.width, activeLaser.h);

            ctx.fillStyle = "#ffffff";
            ctx.fillRect(tank.x + tank.w, activeLaser.y + 6, canvas.width, activeLaser.h - 12);
        }

        // 7. Ledakan
        explosions.forEach(exp => {
            ctx.save();
            ctx.globalAlpha = Math.max(0, exp.alpha);
            ctx.fillStyle = "#ff5500";
            ctx.beginPath();
            ctx.arc(exp.x, exp.y, exp.radius, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = "#ffff00";
            ctx.beginPath();
            ctx.arc(exp.x, exp.y, exp.radius * 0.5, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        });

        requestAnimationFrame(loop);
    }

    requestAnimationFrame(loop);
</script>
</body>
</html>
