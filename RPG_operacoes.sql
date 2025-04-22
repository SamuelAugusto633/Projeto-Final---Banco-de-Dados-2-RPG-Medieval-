
USE RPG;


# Operações CRUD para Cada Tabela



-- CRUD para Classe



INSERT INTO Classe (nome, descricao, ataque_base, defesa_base, vida_base, mana_base) 
VALUES ('Bruxo', 'Mestre do caos que evoca o fogo para queimar para destruir inimigos', 20, 8, 120, 200);

SELECT * 
FROM Classe; 



SELECT * FROM Classe WHERE id = 1;

UPDATE Classe SET ataque_base = 12 WHERE id = 1;

DELETE FROM Classe WHERE id = 21; 






-- CRUD para Personagem



INSERT INTO Personagem (nome, nivel, experiencia, vida, mana, ataque, defesa, moedas, classe_id) 
VALUES ('Jack2', 0, 1, 100, 50, 10, 10, 100, 1);



SELECT *
 FROM Personagem;



SELECT * FROM Personagem WHERE id = 1;

UPDATE Personagem SET nivel = 2 WHERE id = 1;


DELETE FROM Personagem WHERE id = 21;



-- CRUD para Item




INSERT INTO Item (nome, descricao, tipo, efeito, poder, valor) 
VALUES ('Poção de Força', 'Aumenta a defesa em 100 pontos', 'consumivel', NULL, 100, 800);


SELECT *
 FROM Item;

SELECT * FROM Item WHERE id = 1;


UPDATE Item SET valor = 60 WHERE id = 1;


DELETE FROM Item WHERE id = 21;



-- CRUD para Inimigo




INSERT INTO Inimigo (nome, vida, ataque, defesa, experiencia_fornecida, moedas_dropadas) 
VALUES ('Malbog', 250, 50, 50, 350, 380);

SELECT * 
FROM Inimigo;


SELECT * FROM Inimigo WHERE id = 1;


UPDATE Inimigo SET vida = 110 WHERE id = 1;


DELETE FROM Inimigo WHERE id = 21;


-- CRUD para Habilidade


INSERT INTO Habilidade (nome, descricao, custo_mana, dano, efeito, classe_id) 
VALUES ('O chamado do vazio', 'Conjura um guerreiro esqueleto', 20, 35, 'Dano extra em arqueiros', 22);

select *
from Classe;


SELECT * FROM Habilidade WHERE id = 21;

-- leitura com detalhes da classe
SELECT h.*, c.nome AS classe_nome 
FROM Habilidade h
JOIN Classe c ON h.classe_id = c.id
WHERE h.id = 21;


UPDATE Habilidade 
SET custo_mana = 30, dano = 40 
WHERE id = 21; -- o último ID inserido

-- Delete (com verificaçao de relacionamento)
DELETE FROM Habilidade 
WHERE id = 21 
AND NOT EXISTS (SELECT 1 FROM PersonagemHabilidade WHERE habilidade_id = 21);




-- CRUD para PersonagemHabilidade


-- Create (associar habilidade a personagem)
INSERT INTO PersonagemHabilidade (personagem_id, habilidade_id, nivel_habilidade) 
VALUES (22, 5, 3);

select *
from Personagem;

select *
from PersonagemHabilidade;

-- leituraa (habilidades de um personagem)

SELECT h.nome, h.descricao, ph.nivel_habilidade 
FROM PersonagemHabilidade ph
JOIN Habilidade h ON ph.habilidade_id = h.id
WHERE ph.personagem_id = 22;

-- leitura (personagens com uma habilidade específica)

SELECT p.nome, p.nivel, ph.nivel_habilidade 
FROM PersonagemHabilidade ph
JOIN Personagem p ON ph.personagem_id = p.id
WHERE ph.habilidade_id = 5;

-- Update (melhorar nível da habilidade)

UPDATE PersonagemHabilidade 
SET nivel_habilidade = nivel_habilidade + 1 
WHERE personagem_id = 22 AND habilidade_id = 3;

-- Delete (remover habilidade do personagem)

DELETE FROM PersonagemHabilidade 
WHERE personagem_id = 22 AND habilidade_id = 5;




-- CRUD para Inventario


INSERT INTO Inventario (personagem_id, item_id, quantidade) 
VALUES (2, 5, 3);


SELECT i.nome, i.tipo, inv.quantidade, i.efeito 
FROM Inventario inv
JOIN Item i ON inv.item_id = i.id
WHERE inv.personagem_id = 1;


SELECT quantidade 
FROM Inventario 
WHERE personagem_id = 1 AND item_id = 1;


UPDATE Inventario 
SET quantidade = 50 
WHERE personagem_id = 1 AND item_id = 1;


DELETE FROM Inventario 
WHERE personagem_id = 2 AND item_id = 5;


DELETE FROM Inventario 
WHERE personagem_id = 1 
AND item_id IN (SELECT id FROM Item WHERE tipo = 'consumivel');


-- CRUD para Batalha

--  (registrar batalha manualmente)
INSERT INTO Batalha (personagem_id, inimigo_id, resultado, experiencia_ganha, moedas_ganhas) 
VALUES (1, 5, 'vitória', 150, 30);

--  (todas as batalhas de um personagem)
SELECT b.*, i.nome AS inimigo_nome 
FROM Batalha b
JOIN Inimigo i ON b.inimigo_id = i.id
WHERE b.personagem_id = 1
ORDER BY b.data_batalha DESC;

-- (estatísticas de batalha)
SELECT 
    COUNT(*) AS total_batalhas,
    SUM(CASE WHEN resultado = 'vitória' THEN 1 ELSE 0 END) AS vitorias,
    SUM(CASE WHEN resultado = 'derrota' THEN 1 ELSE 0 END) AS derrotas,
    SUM(experiencia_ganha) AS exp_total,
    SUM(moedas_ganhas) AS moedas_total
FROM Batalha 
WHERE personagem_id = 1;

-- Update (corrigir registro de batalha
UPDATE Batalha 
SET experiencia_ganha = 200 
WHERE id = 1;

# correção erro para teste delete
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Batalha WHERE data_batalha < DATE_SUB(NOW(), INTERVAL 30 DAY);
SET SQL_SAFE_UPDATES = 1;

-- Delete (remover registros de batalha antigos)
DELETE FROM Batalha 
WHERE data_batalha < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Delete (remover todas as derrotas)
DELETE FROM Batalha 
WHERE personagem_id = 1 AND resultado = 'derrota';



















#=================================================================================================


#4. Stored Procedures 


-- 1. Procedure para simular batalha


drop procedure SimularBatalha;

DELIMITER //
CREATE PROCEDURE SimularBatalha(IN p_id INT, IN i_id INT)
BEGIN
    DECLARE p_vida INT;
    DECLARE p_ataque INT;
    DECLARE p_defesa INT;
    DECLARE p_nivel INT;
    DECLARE p_classe_id INT;
    DECLARE i_vida INT;
    DECLARE i_ataque INT;
    DECLARE i_defesa INT;
    DECLARE exp_ganha INT;
    DECLARE moedas_ganhas INT;
    DECLARE resultado VARCHAR(10);
    DECLARE vida_base_classe INT;
    
    -- Obter atributos do personagem
    SELECT vida, ataque, defesa, nivel, classe_id 
    INTO p_vida, p_ataque, p_defesa, p_nivel, p_classe_id
    FROM Personagem WHERE id = p_id;
    
    -- Obter vida base da classe em variável separada
    SELECT vida_base INTO vida_base_classe FROM Classe WHERE id = p_classe_id;
    
    -- Obter atributos do inimigo
    SELECT vida, ataque, defesa, experiencia_fornecida, moedas_dropadas 
    INTO i_vida, i_ataque, i_defesa, exp_ganha, moedas_ganhas
    FROM Inimigo WHERE id = i_id;
    
    -- Simulação simplificada de batalha
    WHILE p_vida > 0 AND i_vida > 0 DO
        -- Personagem ataca inimigo
        SET i_vida = i_vida - GREATEST(1, (p_ataque * (1 + p_nivel * 0.1) - i_defesa * 0.5));
        
        -- Inimigo ataca personagem se ainda estiver vivo
        IF i_vida > 0 THEN
            SET p_vida = p_vida - GREATEST(1, (i_ataque - p_defesa * 0.7));
        END IF;
    END WHILE;
    
    -- Determinar resultado
    IF p_vida > 0 THEN
        SET resultado = 'vitória';
        
        -- Atualizar personagem (experiencia moedas e talvez nível se tiver pontos suficientes)
        UPDATE Personagem 
        SET experiencia = experiencia + exp_ganha,
            moedas = moedas + moedas_ganhas,
            vida = p_vida
        WHERE id = p_id;
        
        -- Verificar subida de nível
        CALL VerificarSubidaNivel(p_id);
    ELSE
        SET resultado = 'derrota';
        SET exp_ganha = 0;
        SET moedas_ganhas = 0;
        
        -- Resetar vida do personagem após derrota (usando a variável já obtida)
        UPDATE Personagem 
        SET vida = vida_base_classe
        WHERE id = p_id;
    END IF;
    
    -- Registrar batalha
    INSERT INTO Batalha (personagem_id, inimigo_id, resultado, experiencia_ganha, moedas_ganhas)
    VALUES (p_id, i_id, resultado, exp_ganha, moedas_ganhas);
    
    SELECT resultado AS 'Resultado da Batalha';
END //
DELIMITER ;


#testes Batalha 



-- Teste 1: Personagem forte vs inimigo fraco 
CALL SimularBatalha(1, 1);  -- Aragorn vs Goblin

-- Verificar resultados:
SELECT * FROM Batalha WHERE personagem_id = 1 ORDER BY id DESC LIMIT 1;
SELECT * FROM Personagem WHERE id = 1;  -- Verificar XP, moedas, vida

-- Teste 2: Personagem fraco vs inimigo forte 
CALL SimularBatalha(2, 20);     -- Gandalf vs Rei Esqueleto

-- Verificar resultados:
SELECT * FROM Batalha WHERE personagem_id = 2 ORDER BY id DESC LIMIT 1;
SELECT * FROM Personagem WHERE id = 2;  

-- Teste 3: Batalha equilibrada (resultado aleatorio)
CALL SimularBatalha(1, 2);  -- Aragorn vs Orc

-- Teste 4: Personagem inválido (  erro)
CALL SimularBatalha(999, 1);  -- Personagem não existe

-- Teste 5: Inimigo inválido ( erro)
CALL SimularBatalha(1, 999);  -- Inimigo não existe





-- 2. Procedure para verificar subida de nível



DELIMITER //
CREATE PROCEDURE VerificarSubidaNivel(IN p_id INT)
BEGIN
    DECLARE novo_nivel INT;
    DECLARE exp_atual INT;
    DECLARE exp_necessaria INT;
    
    -- Obter experiência atual
    SELECT experiencia, nivel INTO exp_atual, novo_nivel FROM Personagem WHERE id = p_id;
    
    -- Fórmula para subir de nível (1000 exp por nível)
    WHILE exp_atual >= (novo_nivel * 1000) DO
        SET novo_nivel = novo_nivel + 1;
    END WHILE;
    
    -- Atualizar nível se necessário
    IF novo_nivel > (SELECT nivel FROM Personagem WHERE id = p_id) THEN
        UPDATE Personagem 
        SET nivel = novo_nivel,
            vida = vida + (10 * (novo_nivel - 1)),
            ataque = ataque + (5 * (novo_nivel - 1)),
            defesa = defesa + (3 * (novo_nivel - 1)),
            mana = mana + (8 * (novo_nivel - 1))
        WHERE id = p_id;
        
        SELECT CONCAT('Parabéns! Personagem subiu para o nível ', novo_nivel) AS Mensagem;
    END IF;
END //
DELIMITER ;


--  Atualizar personagem para teste
UPDATE Personagem SET experiencia = 1050, nivel = 1 WHERE id = 3;  -- Legolas

select *
from Personagem;

-- Teste 1: XP suficiente para subir de nível
CALL VerificarSubidaNivel(3);
SELECT * FROM Personagem WHERE id = 3;  -- Verificar se subiu para nível 2

-- Teste 2: XP insuficiente (não vai subir)
UPDATE Personagem SET experiencia = 500, nivel = 1 WHERE id = 4;  -- Shadow
CALL VerificarSubidaNivel(4);
SELECT * FROM Personagem WHERE id = 4;  

-- Teste 3: Subir múltiplos níveis de uma vez
UPDATE Personagem SET experiencia = 3500, nivel = 1 WHERE id = 5;  -- Cleric
CALL VerificarSubidaNivel(5);
SELECT * FROM Personagem WHERE id = 5;  -- vai subir para nível 3







-- 3. Procedure para comprar item

drop procedure ComprarItem;    
#------------------------------------------------------------------------------------------------



DELIMITER //

CREATE PROCEDURE ComprarItem(
    IN p_id INT,
    IN p_item_id INT,
    IN qtd_compra INT
)
BEGIN
    DECLARE v_valor_item INT;
    DECLARE v_valor_total INT;
    DECLARE v_moedas_p INT;
    
    -- Obter valor do item
    SELECT valor INTO v_valor_item FROM Item WHERE id = p_item_id;
    
    -- Calcular total
    SET v_valor_total = v_valor_item * qtd_compra;
    
    -- Verificar moedas
    SELECT moedas INTO v_moedas_p FROM Personagem WHERE id = p_id;
    
    IF v_moedas_p >= v_valor_total THEN
        -- Atualizar moedas
        UPDATE Personagem
        SET moedas = moedas - v_valor_total
        WHERE id = p_id;
        
        -- Atualizar inventário
        IF EXISTS (
            SELECT 1
            FROM Inventario
            WHERE personagem_id = p_id AND item_id = p_item_id
        ) THEN
            UPDATE Inventario
            SET quantidade = quantidade + qtd_compra
            WHERE personagem_id = p_id AND item_id = p_item_id;
        ELSE
            INSERT INTO Inventario (personagem_id, item_id, quantidade)
            VALUES (p_id, p_item_id, qtd_compra);
        END IF;
        
        SELECT 'Compra realizada com sucesso!' AS Resultado;
    ELSE
        SELECT 'Erro: Moedas insuficientes' AS Resultado;
    END IF;
END //

DELIMITER ;


# teste 

INSERT INTO Inventario (personagem_id, item_id, quantidade)
VALUES (1, 5, 1);   

DESCRIBE Inventario;
DESCRIBE Batalha;



--  Resetar moedas para teste
UPDATE Personagem SET moedas = 2900 WHERE id = 1;  -- Aragorn

select * 
from Personagem;


-- Teste 1: Compra 
CALL ComprarItem(1, 5, 2);  -- Aragorn compra 2 poções de cura (custo: 100)


SELECT * FROM Inventario WHERE personagem_id = 1;  --  mostra poções no inventario

select *
from Item;

-- Verifique o item no inventário 
SELECT * FROM Inventario WHERE personagem_id = 1 AND item_id = 5;

# teste resto

SELECT * FROM Inventario WHERE personagem_id = 1 AND item_id = 5;
SELECT moedas FROM Personagem WHERE id = 1;  --  100 moedas restantes

# teste sem dinheiro


CALL ComprarItem(1, 5, 2);  -- Aragorn compra 2 poções de cura (custo: 100)

SELECT * FROM Inventario WHERE personagem_id = 1 AND item_id = 5;
SELECT moedas FROM Personagem WHERE id = 1;  --  0 moedas restantes 







-- 4. Stored Procedure para resetar o status de um personagem

drop procedure ResetarPersonagem;


-- Define o nível, experiência, vida e mana para os valores iniciais


DELIMITER //

CREATE PROCEDURE ResetarPersonagem(IN p_id INT)
BEGIN
    -- Verificar se o personagem existe
    IF NOT EXISTS (SELECT 1 FROM Personagem WHERE id = p_id) THEN
        SELECT 'Erro: Personagem não encontrado' AS Mensagem;
    ELSE
        -- Resetar os atributos do personagem
        UPDATE Personagem
        SET nivel = 1,
            experiencia = 0,
            vida = 100,
            mana = 100
        WHERE id = p_id;

       
        SELECT 'Personagem resetado com sucesso!' AS Mensagem;
    END IF;
END;
//

DELIMITER ;

CALL ResetarPersonagem(1);  


select * 
from Personagem;




-- 5  Stored Procedure para adicionar experiência a um personagem
--
DELIMITER //

CREATE PROCEDURE AdicionarExperiencia(
    IN p_personagem_id INT,
    IN p_experiencia INT
)
BEGIN
    -- Verificar se o personagem existe
    IF NOT EXISTS (SELECT 1 FROM Personagem WHERE id = p_personagem_id) THEN
        SELECT 'Erro: Personagem não encontrado' AS Mensagem;
    ELSE
        -- Atualizar a experiência do personagem
        UPDATE Personagem
        SET experiencia = experiencia + p_experiencia
        WHERE id = p_personagem_id;

       
        SELECT CONCAT('Experiência adicionada: ', p_experiencia, ' pontos') AS Mensagem;
    END IF;
END;
//

DELIMITER ;


CALL AdicionarExperiencia(1, 50); 


select * 
from Personagem;






#========================================================================================================

# 5. Funções de Cálculo

# calcular quantidade total de itens no inventário

drop function CalcularQuantidadeItem;


DELIMITER //
CREATE FUNCTION CalcularQuantidadeItem(p_personagem_id INT, p_item_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    
    RETURN (SELECT COALESCE(SUM(quantidade), 0)
            FROM Inventario
            WHERE personagem_id = p_personagem_id
              AND item_id = p_item_id);
END;
//
DELIMITER ;





select * 
from Personagem;

SELECT * FROM Inventario WHERE personagem_id = 1;

INSERT INTO Inventario (personagem_id, item_id, quantidade) VALUES (1, 5, 10); -- 10 poções

CALL ComprarItem(1, 5, 2);  -- Aragorn compra 2 poções de cura (custo: 100)

SELECT CalcularQuantidadeItem(1, 5); 

# teste base
SELECT SUM(quantidade)
FROM Inventario
WHERE personagem_id = 1 AND item_id = 5;
















-- 2. Função para calcular experiência para próximo nível

drop function ExperienciaProximoNivel;


DELIMITER //
CREATE FUNCTION ExperienciaProximoNivel(p_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE nivel_atual INT;
    DECLARE exp_necessaria INT;
    
    -- Obter o nível atual do personagem
    SELECT nivel INTO nivel_atual FROM Personagem WHERE id = p_id;
    
    -- Calcular a experiência necessária para o próximo nível
    SET exp_necessaria = (nivel_atual * 1000);  
    
    
    RETURN exp_necessaria;
END //
DELIMITER ;


SELECT ExperienciaProximoNivel(2);

CALL AdicionarExperiencia(1, 1000); 


select * 
from Personagem;



-- Function para calcular o nível de um personagem com base na experiência

drop function CalcularNivelEX;

DELIMITER //
CREATE FUNCTION CalcularNivelEX(experiencia INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN FLOOR(experiencia / 1000) + 1;
END;
//
DELIMITER ;


select * 
from Personagem;


SELECT CalcularNivelEX(500);   --  1
SELECT CalcularNivelEX(1000);  -- 2
SELECT CalcularNivelEX(2500);  -- 3
SELECT CalcularNivelEX(999);   -- 1





#===========================================================================================


#Triggers de Integridade



-- 1. Trigger para atualizar atributos ao definir classe (automatico simula personagem base no jogo)

drop trigger AtualizarStatusClasse;

DELIMITER //
CREATE TRIGGER AtualizarStatusClasse
BEFORE INSERT ON Personagem
FOR EACH ROW
BEGIN
    DECLARE atk INT;
    DECLARE def INT;
    DECLARE hp INT;
    DECLARE mp INT;

    -- Pega os atributos base da classe
    SELECT ataque_base, defesa_base, vida_base, mana_base
    INTO atk, def, hp, mp
    FROM Classe
    WHERE id = NEW.classe_id;

    -- Define os atributos do personagem com base na classe
    SET NEW.ataque = atk;
    SET NEW.defesa = def;
    SET NEW.vida = hp;
    SET NEW.mana = mp;

    -- Nível inicial e experiência 
    IF NEW.nivel IS NULL THEN
        SET NEW.nivel = 1;
    END IF;
    
    IF NEW.experiencia IS NULL THEN
        SET NEW.experiencia = 0;
    END IF;
END;
//
DELIMITER ;

# teste 
-- Suponha que a classe com iD 2 tenha:
-- ataque_base = 15, defesa_base = 10, vida_base = 120, mana_base = 50

INSERT INTO Personagem (nome, classe_id)
VALUES ('Boromir', 2);

SELECT * FROM Personagem WHERE nome = 'Boromir';




-- 2. Trigger para evitar nível negativo

select *
from Personagem;



drop trigger verificar_nivel_personagem;

DELIMITER //
CREATE TRIGGER verificar_nivel_personagem
BEFORE UPDATE ON Personagem
FOR EACH ROW
BEGIN
    IF NEW.nivel < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O nível do personagem não pode ser menor que 1.';
    END IF;
END;
//
DELIMITER ;

-- o personagem com id = 1 está no nível 5
SELECT nome, nivel FROM Personagem WHERE id = 1;

-- Tentativa de reduzir o nível para 0 
UPDATE Personagem SET nivel = 0 WHERE id = 1;


SELECT nome, nivel FROM Personagem WHERE id = 1;




-- 3. Trigger para garantir experiência não negativa


# trigger para Nível Negativo 


 
 DROP TRIGGER IF EXISTS verificar_nivel_insert;
 
DELIMITER //
CREATE TRIGGER verificar_nivel_insert
BEFORE INSERT ON Personagem
FOR EACH ROW
BEGIN
    IF NEW.nivel < 1 THEN
        -- Exibe mensagem de erro e cancela a operação
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Nível não pode ser menor que 1';
    END IF;
END //
DELIMITER ;


INSERT INTO Personagem (nome, classe_id, nivel, experiencia, vida, mana)
VALUES ('corinthiano sofredor', 1, 0, 0, 100, 50);





# Trigger para Experiência Negativa

DELIMITER //
CREATE TRIGGER verificar_experiencia_insert
BEFORE INSERT ON Personagem
FOR EACH ROW
BEGIN
    IF NEW.experiencia < 0 THEN
        -- Exibe mensagem de erro e cancela a operação
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Experiência não pode ser negativa';
    END IF;
END //
DELIMITER ;

INSERT INTO Personagem (nome, classe_id, nivel, experiencia, vida, mana)
VALUES ('Bugado', 1, 1, -100, 100, 50);

#teste t

INSERT INTO Personagem (nome, nivel, experiencia, vida, mana, ataque, defesa, moedas, classe_id) 
VALUES ('Jack3', 1, -10, 100, 50, 10, 10, 100, 1);


-- 4 Trigger para garantir que o nome de um personagem seja único

DELIMITER //
CREATE TRIGGER NomeUnicoPersonagem
BEFORE INSERT ON Personagem
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Personagem WHERE nome = NEW.nome) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nome de personagem já existe!';
    END IF;
END;
//
DELIMITER ;

INSERT INTO Personagem (nome, classe_id, nivel, experiencia, vida, mana)
VALUES ('Aragorn', 1, 1, 0, 100, 50);






-- 5. Trigger para validar batalha


DELIMITER //
CREATE TRIGGER validar_batalha
BEFORE INSERT ON Batalha
FOR EACH ROW
BEGIN
    -- Verificar se o personagem existe
    IF NEW.personagem_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Personagem WHERE id = NEW.personagem_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Personagem não existe';
    END IF;
    
    -- Verificar se o inimigo existe
    IF NEW.inimigo_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Inimigo WHERE id = NEW.inimigo_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inimigo não existe';
    END IF;
END //
DELIMITER ;

SELECT id FROM Personagem LIMIT 1;
SELECT id FROM Inimigo LIMIT 4;

INSERT INTO Batalha (personagem_id, inimigo_id, resultado, data_batalha)
VALUES (1, 4, 'Vitoria', NOW());


# erro batalha bloqueada  

INSERT INTO Batalha (personagem_id, inimigo_id, resultado, data_batalha)
VALUES (999, 2, 'Derrota', NOW());


-- 6 impede que o nível de um personagem seja maior do que 100:

DELIMITER //
CREATE TRIGGER VerificarNivelMaximo
BEFORE UPDATE ON Personagem
FOR EACH ROW
BEGIN
    -- Verifica se o novo nível é maior que 100
    IF NEW.nivel > 100 THEN
        
        SET NEW.nivel = 100;
        
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Nível máximo atingido: 100';
    END IF;
END;
//
DELIMITER ;

UPDATE Personagem
SET nivel = 120
WHERE id = 1; 





#============================================================================================


#  Views Úteis



-- 1. View para ranking de personagens



CREATE VIEW RankingPersonagens AS
SELECT 
    p.id,
    p.nome,
    c.nome AS classe,
    p.nivel,
    p.experiencia,
    CONCAT(p.vida, '/', (SELECT vida_base FROM Classe WHERE id = p.classe_id)) AS vida,
    CONCAT(p.mana, '/', (SELECT mana_base FROM Classe WHERE id = p.classe_id)) AS mana,
    p.ataque,
    p.defesa,
    p.moedas,
    (SELECT COUNT(*) FROM Batalha WHERE personagem_id = p.id AND resultado = 'vitória') AS vitorias,
    (SELECT COUNT(*) FROM Batalha WHERE personagem_id = p.id AND resultado = 'derrota') AS derrotas
FROM Personagem p
JOIN Classe c ON p.classe_id = c.id
ORDER BY p.nivel DESC, p.experiencia DESC;



SELECT * FROM RankingPersonagens;





-- 2. View para inventário detalhado


CREATE VIEW InventarioDetalhado AS
SELECT 
    p.nome AS personagem,
    i.nome AS item,
    inv.quantidade,
    i.tipo,
    i.poder,
    i.efeito,
    i.valor,
    (inv.quantidade * i.valor) AS valor_total
FROM Inventario inv
JOIN Personagem p ON inv.personagem_id = p.id
JOIN Item i ON inv.item_id = i.id
ORDER BY p.nome, i.tipo, i.nome;

SELECT * FROM InventarioDetalhado;



-- 3. View para histórico de batalhas



CREATE VIEW HistoricoBatalhas AS
SELECT 
    b.id,
    p.nome AS personagem,
    i.nome AS inimigo,
    b.resultado,
    b.experiencia_ganha,
    b.moedas_ganhas,
    b.data_batalha,
    CASE 
        WHEN b.resultado = 'vitória' THEN 'green'
        ELSE 'red'
    END AS cor_resultado
FROM Batalha b
LEFT JOIN Personagem p ON b.personagem_id = p.id
LEFT JOIN Inimigo i ON b.inimigo_id = i.id
ORDER BY b.data_batalha DESC;



SELECT * FROM HistoricoBatalhas;


# View para ver Personagens de uma Classe escolhida


CREATE VIEW PersonagensPorClasse AS
SELECT 
    p.id AS personagem_id,
    p.nome AS personagem_nome,
    c.nome AS classe_nome,
    p.nivel,
    p.experiencia,
    p.vida,
    p.mana,
    p.ataque,
    p.defesa,
    p.moedas
FROM Personagem p
JOIN Classe c ON p.classe_id = c.id
ORDER BY c.nome, p.nivel DESC;


SELECT * FROM PersonagensPorClasse;
SELECT * FROM PersonagensPorClasse WHERE classe_nome = 'Mago';




#===================================================================================================



# testes base apenas para correções, cada operação do banco possui teste separados dentro do codigo acima


-- Simular uma batalha
CALL SimularBatalha(1, 5);

select * 
from Personagem;

-- Comprar um item
CALL ComprarItem(1, 5, 3); -- Personagem 1 compra 3 poções de cura



-- Ver ranking
SELECT * FROM RankingPersonagens;

-- Ver inventário
SELECT * FROM InventarioDetalhado WHERE personagem = 'Aragorn';

-- Ver histórico de batalhas
SELECT * FROM HistoricoBatalhas;



#=========================================================================================





# Criação dos Papéis (Roles)



-- Papel de Administrador do Servidor (equivalente a root/desenvolvedor do jogo)
CREATE ROLE 'rpg_root';

-- Papel de Mestre da Guilda (pode gerenciar itens e membros)
CREATE ROLE 'rpg_guild_master';

-- Papel de Campeão do Servidor (leitura privilegiada)
CREATE ROLE 'rpg_champion';

-- Papel de Pro Player (acesso básico a informações do jogo)
CREATE ROLE 'rpg_pro_player';



# Atribuição de Permissões para Cada Papel


-- Permissões para Administrador do Servidor (acesso total)

GRANT ALL PRIVILEGES ON RPG.* TO 'rpg_root';

-- Permissões para Mestre da Guilda
GRANT SELECT, INSERT, UPDATE ON RPG.Item TO 'rpg_guild_master';
GRANT SELECT, INSERT, UPDATE ON RPG.Inventario TO 'rpg_guild_master';
GRANT SELECT, INSERT, UPDATE ON RPG.Personagem TO 'rpg_guild_master';
GRANT SELECT, INSERT, UPDATE ON RPG.PersonagemHabilidade TO 'rpg_guild_master';
GRANT SELECT ON RPG.* TO 'rpg_guild_master';
GRANT EXECUTE ON PROCEDURE RPG.ComprarItem TO 'rpg_guild_master';
GRANT EXECUTE ON PROCEDURE RPG.VerificarSubidaNivel TO 'rpg_guild_master';
GRANT EXECUTE ON FUNCTION RPG.CalcularDanoHabilidade TO 'rpg_guild_master';

-- Permissões para Campeão do Servidor (leitura privilegiada)
GRANT SELECT ON RPG.* TO 'rpg_champion';
GRANT EXECUTE ON FUNCTION RPG.CalcularDanoHabilidade TO 'rpg_champion';
GRANT EXECUTE ON FUNCTION RPG.ExperienciaProximoNivel TO 'rpg_champion';
GRANT EXECUTE ON PROCEDURE RPG.SimularBatalha TO 'rpg_champion';  -- Pode simular para teste

-- Permissões para Pro Player
GRANT SELECT ON RPG.Personagem TO 'rpg_pro_player';
GRANT SELECT ON RPG.Item TO 'rpg_pro_player';
GRANT SELECT ON RPG.Classe TO 'rpg_pro_player';
GRANT SELECT ON RPG.Inimigo TO 'rpg_pro_player';
GRANT EXECUTE ON FUNCTION RPG.ExperienciaProximoNivel TO 'rpg_pro_player';



# Criação dos Usuários 


-- Usuário 1: Administrador do Servidor (Root/Dev)

CREATE USER 'samuel'@'localhost' IDENTIFIED BY '123';
GRANT 'rpg_root' TO 'samuel'@'localhost';
SET DEFAULT ROLE 'rpg_root' TO 'samuel'@'localhost';

-- Usuário 2: Mestre da Guilda

CREATE USER 'leonardo'@'localhost' IDENTIFIED BY '456';
GRANT 'rpg_guild_master' TO 'leonardo'@'localhost';
SET DEFAULT ROLE 'rpg_guild_master' TO 'leonardo'@'localhost';

-- Usuário 3: Campeão do Servidor

CREATE USER 'vitor'@'localhost' IDENTIFIED BY '789';
GRANT 'rpg_champion' TO 'vitor'@'localhost';
SET DEFAULT ROLE 'rpg_champion' TO 'vitor'@'localhost';

-- Usuário 4: Pro Player


CREATE USER 'matheus'@'localhost' IDENTIFIED BY '111';
GRANT 'rpg_pro_player' TO 'matheus'@'localhost';
SET DEFAULT ROLE 'rpg_pro_player' TO 'matheus'@'localhost';

FLUSH PRIVILEGES;

#=================================================================================================



# Tabela de Log usuarios  TRIGGER numero 7:

CREATE TABLE AcaoUsuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    acao VARCHAR(255) NOT NULL,
    tabela_afetada VARCHAR(50),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER log_acoes_item
AFTER INSERT ON Item
FOR EACH ROW
BEGIN
    INSERT INTO AcaoUsuario (usuario, acao, tabela_afetada)
    VALUES (CURRENT_USER(), CONCAT('Criou novo item: ', NEW.nome), 'Item');
END //
DELIMITER ;


SELECT CURRENT_USER();



GRANT SELECT ON RPG.AcaoUsuario TO 'samuel'@'localhost';

# teste log 

INSERT INTO Item (nome, descricao, tipo, efeito, poder, valor)
VALUES ('Poção de Invisibilidade', 'Fica invisível por 10s', 'consumivel', 'invisibilidade', 0, 50);


SELECT * FROM AcaoUsuario ORDER BY data_hora DESC;




