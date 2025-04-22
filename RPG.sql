-- TRabalho final 


DROP DATABASE IF EXISTS RPG;


CREATE DATABASE RPG;

USE RPG;


CREATE TABLE Classe (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    ataque_base INT NOT NULL,
    defesa_base INT NOT NULL,
    vida_base INT NOT NULL,
    mana_base INT NOT NULL
);


CREATE TABLE Habilidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    custo_mana INT NOT NULL,
    dano INT,
    efeito VARCHAR(100),
    classe_id INT,
    FOREIGN KEY (classe_id) REFERENCES Classe(id)
);


CREATE TABLE Item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    tipo ENUM('arma', 'armadura', 'consumivel', 'outro') NOT NULL,
    efeito VARCHAR(100),
    poder INT,
    valor INT NOT NULL
);


CREATE TABLE Personagem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    nivel INT DEFAULT 1,
    experiencia INT DEFAULT 0,
    vida INT NOT NULL,
    mana INT NOT NULL,
    ataque INT NOT NULL,
    defesa INT NOT NULL,
    moedas INT DEFAULT 100,
    classe_id INT,
    FOREIGN KEY (classe_id) REFERENCES Classe(id)
);


CREATE TABLE PersonagemHabilidade (
    personagem_id INT,
    habilidade_id INT,
    nivel_habilidade INT DEFAULT 1,
    PRIMARY KEY (personagem_id, habilidade_id),
    FOREIGN KEY (personagem_id) REFERENCES Personagem(id) ON DELETE CASCADE,
    FOREIGN KEY (habilidade_id) REFERENCES Habilidade(id) ON DELETE CASCADE
);


CREATE TABLE Inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    personagem_id INT,
    item_id INT,
    quantidade INT DEFAULT 1,
    FOREIGN KEY (personagem_id) REFERENCES Personagem(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Item(id) ON DELETE CASCADE
);

CREATE TABLE Inimigo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    vida INT NOT NULL,
    ataque INT NOT NULL,
    defesa INT NOT NULL,
    experiencia_fornecida INT NOT NULL,
    moedas_dropadas INT NOT NULL
);


CREATE TABLE Batalha (
    id INT AUTO_INCREMENT PRIMARY KEY,
    personagem_id INT,
    inimigo_id INT,
    resultado ENUM('vitória', 'derrota') NOT NULL,
    experiencia_ganha INT,
    moedas_ganhas INT,
    data_batalha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (personagem_id) REFERENCES Personagem(id) ON DELETE SET NULL,
    FOREIGN KEY (inimigo_id) REFERENCES Inimigo(id) ON DELETE SET NULL
);


# inserções 
#---------------------------------------------------------------------------------



USE RPG;



-- Inserção de Classes (20)
INSERT INTO Classe (nome, descricao, ataque_base, defesa_base, vida_base, mana_base) VALUES
('Guerreiro', 'Especialista em combate corpo a corpo', 15, 12, 100, 30),
('Mago', 'Mestre das artes arcanas', 8, 6, 60, 120),
('Arqueiro', 'Especialista em ataques à distância', 12, 8, 80, 50),
('Ladino', 'Especialista em furtividade e ataques precisos', 10, 7, 70, 60),
('Clérigo', 'Curandeiro e guerreiro divino', 9, 10, 90, 80),
('Bárbaro', 'Guerreiro selvagem com ataques poderosos', 18, 8, 120, 20),
('Paladino', 'Cavaleiro sagrado com bênçãos divinas', 14, 14, 110, 60),
('Necromante', 'Manipulador das forças da morte', 7, 5, 65, 130),
('Druida', 'Guardião da natureza que se transforma em animais', 10, 9, 85, 90),
('Feiticeiro', 'Usuário de magia inata', 6, 5, 55, 140),
('Bardo', 'Usa música e arte para magia', 8, 8, 75, 100),
('Monge', 'Mestre em artes marciais', 12, 11, 95, 40),
('Patrulheiro', 'Explorador e caçador', 11, 9, 85, 50),
('Alquimista', 'Mistura poções e cria itens', 5, 6, 60, 110),
('Cavaleiro', 'Mestre em combate montado', 13, 15, 100, 30),
('Xamã', 'Comunica-se com espíritos', 7, 7, 70, 100),
('Assassino', 'Mestre em eliminar alvos', 16, 6, 75, 40),
('Inventor', 'Cria dispositivos mecânicos', 4, 7, 65, 80),
('Pirata', 'Mestre em combate naval', 12, 9, 90, 30),
('Samurai', 'Guerreiro disciplinado com katana', 14, 12, 95, 50);

-- Inserção de Habilidades (20)
INSERT INTO Habilidade (nome, descricao, custo_mana, dano, efeito, classe_id) VALUES
('Golpe Poderoso', 'Ataque com força aumentada', 10, 25, NULL, 1),
('Bola de Fogo', 'Conjura uma esfera de fogo', 20, 40, 'Queimadura', 2),
('Disparo Preciso', 'Tiro certeiro no ponto fraco', 15, 30, NULL, 3),
('Ataque Furtivo', 'Golpe pelas costas', 10, 35, NULL, 4),
('Cura Leve', 'Recupera vida do aliado', 15, NULL, 'Cura 30 HP', 5),
('Fúria', 'Aumenta ataque temporariamente', 10, NULL, 'Ataque +10 por 3 turnos', 6),
('Escudo Divino', 'Proteção sagrada', 20, NULL, 'Defesa +15 por 2 turnos', 7),
('Esvaziamento Vital', 'Drena vida do inimigo', 25, 20, 'Rouba 15 HP', 8),
('Transformação Urso', 'Assume forma de urso', 30, NULL, 'Vida +50, Ataque +20', 9),
('Raio Arcano', 'Disparo de energia mágica', 15, 35, NULL, 10),
('Canção de Cura', 'Cura aliados com música', 20, NULL, 'Cura 20 HP para todos', 11),
('Soco de Dragão', 'Golpe rápido e poderoso', 10, 30, NULL, 12),
('Armadilha de Espinhos', 'Prende o inimigo em espinhos', 15, 20, 'Reduz velocidade', 13),
('Poção Explosiva', 'Lança uma poção que explode', 25, 45, NULL, 14),
('Investida Montada', 'Ataque com a força da montaria', 20, 50, NULL, 15),
('Chamado dos Ancestrais', 'Invoca espíritos para ajudar', 30, NULL, 'Ataque +15 para aliados', 16),
('Golpe Mortal', 'Ataque com chance de crítico', 25, 60, NULL, 17),
('Granada de Fumaça', 'Cria uma nuvem de fumaça', 10, NULL, 'Reduz precisão inimiga', 18),
('Tiro de Canhão', 'Dispara um canhão', 30, 70, NULL, 19),
('Corte Rápido', 'Série de golpes velozes', 15, 40, NULL, 20);

-- Inserção de Itens (20)
INSERT INTO Item (nome, descricao, tipo, efeito, poder, valor) VALUES
('Espada Longa', 'Espada de duas mãos', 'arma', NULL, 15, 100),
('Cajado Arcano', 'Aumenta poder mágico', 'arma', 'Magia +10', 10, 150),
('Arco Recurvo', 'Arco de alta precisão', 'arma', NULL, 12, 120),
('Adaga Sombria', 'Adaga afiada para ataques furtivos', 'arma', NULL, 8, 80),
('Poção de Cura', 'Recupera 50 HP', 'consumivel', 'Cura 50 HP', NULL, 50),
('Armadura de Placas', 'Armadura pesada de metal', 'armadura', 'Defesa +20', NULL, 200),
('Túnica do Mago', 'Veste com resistência mágica', 'armadura', 'Resistência Mágica +15', NULL, 180),
('Capuz do Ladino', 'Aumenta furtividade', 'armadura', 'Furtividade +10', NULL, 130),
('Poção de Mana', 'Recupera 30 MP', 'consumivel', 'Recupera 30 MP', NULL, 60),
('Escudo de Aço', 'Escudo resistente', 'armadura', 'Defesa +15', NULL, 150),
('Martelo de Guerra', 'Martelo pesado para esmagar', 'arma', NULL, 18, 160),
('Livro de Feitiços', 'Contém conhecimentos arcanos', 'outro', 'Magia +5', NULL, 100),
('Flechas', 'Pacote com 20 flechas', 'consumivel', NULL, NULL, 20),
('Botas Velozes', 'Aumenta velocidade', 'armadura', 'Velocidade +10', NULL, 90),
('Veneno', 'Aplica veneno à arma', 'consumivel', 'Dano +10 por 3 turnos', NULL, 70),
('Anel de Proteção', 'Protege contra magias', 'outro', 'Resistência Mágica +10', NULL, 120),
('Elmo do Dragão', 'Elmo com resistência a fogo', 'armadura', 'Resistência a Fogo +20', NULL, 140),
('Poção de Força', 'Aumenta força temporariamente', 'consumivel', 'Ataque +15 por 5 turnos', NULL, 80),
('Luvas de Ferro', 'Aumenta dano de socos', 'armadura', 'Dano de soco +10', NULL, 70),
('Pergaminho de Teleporte', 'Teleporta para cidade', 'consumivel', 'Teleporte', NULL, 200);

-- Inserção de Personagens (20)
INSERT INTO Personagem (nome, nivel, experiencia, vida, mana, ataque, defesa, moedas, classe_id) VALUES
('Aragorn', 5, 2500, 150, 50, 30, 25, 500, 1),
('Gandalf', 8, 6500, 90, 200, 20, 18, 800, 2),
('Legolas', 6, 3800, 110, 70, 35, 20, 600, 3),
('Shadow', 4, 1800, 85, 80, 28, 15, 400, 4),
('Cleric', 7, 5200, 130, 120, 22, 28, 700, 5),
('Conan', 3, 900, 140, 30, 32, 16, 300, 6),
('Uther', 9, 8200, 160, 90, 28, 35, 900, 7),
('Necro', 5, 2400, 80, 180, 15, 12, 450, 8),
('Druid', 6, 3500, 120, 130, 24, 22, 550, 9),
('Sorcerer', 7, 4800, 70, 210, 18, 14, 750, 10),
('Bard', 4, 1900, 90, 120, 16, 16, 350, 11),
('Lee', 5, 2600, 110, 60, 30, 25, 500, 12),
('Ranger', 6, 3700, 100, 70, 27, 22, 600, 13),
('Alchemist', 3, 1200, 75, 100, 12, 14, 250, 14),
('Lancelot', 8, 7000, 150, 50, 30, 40, 850, 15),
('Shaman', 5, 2300, 95, 130, 16, 18, 420, 16),
('Assassin', 7, 4500, 100, 60, 38, 15, 680, 17),
('Gadget', 2, 500, 70, 90, 10, 12, 150, 18),
('Blackbeard', 6, 3900, 130, 50, 32, 22, 620, 19),
('Kenshin', 9, 8500, 140, 80, 36, 30, 950, 20);

-- Inserção de PersonagemHabilidade (20)
INSERT INTO PersonagemHabilidade (personagem_id, habilidade_id, nivel_habilidade) VALUES
(1, 1, 2), (2, 2, 3), (3, 3, 2), (4, 4, 1), (5, 5, 3),
(6, 6, 1), (7, 7, 2), (8, 8, 1), (9, 9, 2), (10, 10, 3),
(11, 11, 1), (12, 12, 2), (13, 13, 1), (14, 14, 1), (15, 15, 2),
(16, 16, 1), (17, 17, 3), (18, 18, 1), (19, 19, 2), (20, 20, 3);

-- Inserção de Inimigos (20)
INSERT INTO Inimigo (nome, vida, ataque, defesa, experiencia_fornecida, moedas_dropadas) VALUES
('Goblin', 50, 10, 5, 100, 20),
('Orc', 80, 15, 10, 150, 35),
('Esqueleto', 60, 12, 8, 120, 25),
('Aranha Gigante', 70, 18, 6, 180, 30),
('Lobo Selvagem', 55, 14, 7, 130, 22),
('Bandido', 65, 16, 9, 140, 40),
('Zumbi', 90, 13, 12, 160, 15),
('Troll', 120, 22, 15, 250, 60),
('Harpia', 60, 17, 5, 170, 28),
('Esqueleto Guerreiro', 100, 20, 18, 220, 45),
('Mago Negro', 70, 25, 8, 200, 50),
('Golem', 150, 18, 25, 300, 70),
('Dragãozinho', 110, 30, 12, 350, 100),
('Vampiro', 95, 22, 14, 280, 80),
('Demônio Pequeno', 85, 28, 10, 320, 90),
('Cavaleiro Maldito', 130, 24, 20, 380, 110),
('Necromante', 90, 32, 12, 400, 120),
('Quimera', 140, 26, 18, 450, 130),
('Gigante', 200, 35, 25, 500, 150),
('Rei Esqueleto', 180, 40, 30, 600, 200);

-- Inserção de Inventário (20)
INSERT INTO Inventario (personagem_id, item_id, quantidade) VALUES
(1, 1, 1), (1, 6, 1), (1, 10, 1), (2, 2, 1), (2, 7, 1),
(3, 3, 1), (3, 13, 20), (4, 4, 2), (4, 8, 1), (5, 5, 5),
(5, 9, 3), (6, 11, 1), (7, 6, 1), (7, 10, 1), (8, 12, 1),
(9, 14, 1), (10, 2, 1), (11, 16, 1), (12, 17, 1), (13, 18, 2);

-- Inserção de Batalhas (20)
INSERT INTO Batalha (personagem_id, inimigo_id, resultado, experiencia_ganha, moedas_ganhas) VALUES
(1, 1, 'vitória', 100, 20), (2, 3, 'vitória', 120, 25), (3, 2, 'vitória', 150, 35),
(4, 4, 'derrota', 0, 0), (5, 5, 'vitória', 130, 22), (6, 6, 'derrota', 0, 0),
(7, 7, 'vitória', 160, 15), (8, 8, 'vitória', 250, 60), (9, 9, 'derrota', 0, 0),
(10, 10, 'vitória', 220, 45), (11, 11, 'vitória', 200, 50), (12, 12, 'derrota', 0, 0),
(13, 13, 'vitória', 350, 100), (14, 14, 'vitória', 280, 80), (15, 15, 'vitória', 320, 90),
(16, 16, 'derrota', 0, 0), (17, 17, 'vitória', 400, 120), (18, 18, 'derrota', 0, 0),
(19, 19, 'vitória', 500, 150), (20, 20, 'vitória', 600, 200);




