
CREATE DATABASE BankDB;
USE BankDB;

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Accounts table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(12,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    transaction_type ENUM('Credit', 'Debit'),
    amount DECIMAL(12,2),
    description VARCHAR(255),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Sample customer data
INSERT INTO customers (full_name, email, phone, address) VALUES
('Omkar Borkar', 'omkar@email.com', '9876543210', 'Pune'),
('Riya Sen', 'riya@email.com', '9123456780', 'Mumbai');

-- Sample account data
INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1, 'Savings', 5000),
(1, 'Current', 20000),
(2, 'Savings', 15000);

-- Stored Procedure for transactions
DELIMITER //

CREATE PROCEDURE perform_transaction (
    IN acc_id INT,
    IN trans_type ENUM('Credit', 'Debit'),
    IN amt DECIMAL(12,2),
    IN desc_text VARCHAR(255)
)
BEGIN
    DECLARE current_balance DECIMAL(12,2);

    SELECT balance INTO current_balance FROM accounts WHERE account_id = acc_id;

    IF trans_type = 'Debit' AND current_balance < amt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient Balance';
    ELSE
        IF trans_type = 'Credit' THEN
            UPDATE accounts SET balance = balance + amt WHERE account_id = acc_id;
        ELSE
            UPDATE accounts SET balance = balance - amt WHERE account_id = acc_id;
        END IF;

        INSERT INTO transactions (account_id, transaction_type, amount, description)
        VALUES (acc_id, trans_type, amt, desc_text);
    END IF;
END //

DELIMITER ;

-- View for Mini Statement
CREATE VIEW mini_statement AS
SELECT 
    t.transaction_id,
    c.full_name,
    a.account_type,
    t.transaction_type,
    t.amount,
    t.description,
    t.transaction_date
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY t.transaction_date DESC;
