-- Create 'bitcoin' table
CREATE TABLE IF NOT EXISTS bitcoin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

-- Create index on 'player_id' column for faster lookups
CREATE INDEX idx_player_id ON bitcoin (player_id);
