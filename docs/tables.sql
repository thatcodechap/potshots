CREATE TABLE users (
    email VARCHAR(320) PRIMARY KEY,
    name VARCHAR(70),
    digest CHAR(64)
);

CREATE TABLE pots (
    id INTEGER AUTO_INCREMENT UNIQUE,
    goal VARCHAR(50),
    target INTEGER,
    balance INTEGER DEFAULT 0,
    targetDate DATE,
    creationDate DATE,
    owner VARCHAR(320),
    locked BIT(1) DEFAULT b'0'
    PRIMARY KEY(goal, owner),
    FOREIGN KEY(owner) REFERENCES users(email)
);

CREATE TABLE shared(
    pot INTEGER,
    user VARCHAR(320),
    PRIMARY KEY(pot, user),
    FOREIGN KEY(pot) references pots(id),
    FOREIGN KEY(user) references users(email)
);

CREATE TABLE transactions(
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20),
    amount INTEGER,
    paymentDate DATETIME,
    pot INTEGER NOT NULL,
    FOREIGN KEY(pot) REFERENCES pots(id)
);

DELIMITER $$
CREATE TRIGGER updateBalance
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'add' THEN
        UPDATE pots
        SET balance = balance + NEW.amount
        WHERE id = NEW.pot;
    ELSEIF NEW.type = 'withdraw' THEN
        UPDATE pots
        SET balance = balance - NEW.amount
        WHERE id = NEW.pot;
    END IF;
END$$
DELIMITER ;