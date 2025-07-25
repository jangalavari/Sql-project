# Sports Tournament Tracker Project

## Objective
Manage match results and player statistics for a sports tournament using MySQL.

---

## Step 1: Database Schema Design

**Entities and Relationships:**
- **Teams**: Each team has many players.
- **Players**: Each player belongs to a team.
- **Matches**: Each match is played between two teams.
- **Stats**: Each stat entry records a player's performance in a match.

**DDL Statements:**

```sql
-- Teams Table
CREATE TABLE Teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL
);

-- Players Table
CREATE TABLE Players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    team_id INT,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

-- Matches Table
CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    match_date DATE,
    team1_id INT,
    team2_id INT,
    team1_score INT,
    team2_score INT,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id)
);

-- Stats Table
CREATE TABLE Stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    player_id INT,
    runs_scored INT DEFAULT 0,
    wickets_taken INT DEFAULT 0,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);
```

---

## Step 2: Insert Sample Tournament Data

```sql
-- Insert Teams
INSERT INTO Teams (team_name) VALUES ('Warriors'), ('Titans'), ('Rangers'), ('Falcons');

-- Insert Players
INSERT INTO Players (player_name, team_id) VALUES
('Alice', 1), ('Bob', 1), ('Charlie', 2), ('David', 2),
('Eve', 3), ('Frank', 3), ('Grace', 4), ('Heidi', 4);

-- Insert Matches
INSERT INTO Matches (match_date, team1_id, team2_id, team1_score, team2_score) VALUES
('2025-07-20', 1, 2, 150, 145),
('2025-07-21', 3, 4, 160, 155),
('2025-07-22', 1, 3, 140, 138),
('2025-07-23', 2, 4, 155, 152);

-- Insert Stats (simplified for brevity)
INSERT INTO Stats (match_id, player_id, runs_scored, wickets_taken) VALUES
(1, 1, 45, 1), (1, 2, 30, 0), (1, 3, 55, 2), (1, 4, 40, 1),
(2, 5, 50, 1), (2, 6, 40, 2), (2, 7, 55, 1), (2, 8, 50, 2),
(3, 1, 35, 0), (3, 2, 40, 1), (3, 5, 38, 1), (3, 6, 45, 1),
(4, 3, 60, 2), (4, 4, 50, 1), (4, 7, 52, 2), (4, 8, 48, 0);
```

---

## Step 3: Core Queries

### 3.1 Get Match Results

```sql
SELECT
    m.match_id,
    t1.team_name AS team1,
    m.team1_score,
    t2.team_name AS team2,
    m.team2_score,
    CASE 
        WHEN m.team1_score > m.team2_score THEN t1.team_name
        WHEN m.team2_score > m.team1_score THEN t2.team_name
        ELSE 'Draw'
    END AS winner
FROM
    Matches m
    JOIN Teams t1 ON m.team1_id = t1.team_id
    JOIN Teams t2 ON m.team2_id = t2.team_id;
```

### 3.2 Get Player Scores in Each Match

```sql
SELECT
    s.match_id,
    p.player_name,
    t.team_name,
    s.runs_scored,
    s.wickets_taken
FROM
    Stats s
    JOIN Players p ON s.player_id = p.player_id
    JOIN Teams t ON p.team_id = t.team_id
ORDER BY s.match_id, p.player_name;
```

---

## Step 4: Leaderboards and Points Table Views

### 4.1 Player Leaderboard (Most Runs)

```sql
CREATE VIEW Player_Leaderboard AS
SELECT
    p.player_name,
    t.team_name,
    SUM(s.runs_scored) AS total_runs,
    SUM(s.wickets_taken) AS total_wickets
FROM
    Stats s
    JOIN Players p ON s.player_id = p.player_id
    JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_id
ORDER BY total_runs DESC;
```

### 4.2 Points Table (Team Standings)

```sql
CREATE VIEW Points_Table AS
SELECT
    t.team_id,
    t.team_name,
    SUM(
        CASE
            WHEN (t.team_id = m.team1_id AND m.team1_score > m.team2_score) OR 
                 (t.team_id = m.team2_id AND m.team2_score > m.team1_score)
            THEN 2 ELSE 0 END
    ) AS points,
    COUNT(m.match_id) AS matches_played
FROM
    Teams t
    LEFT JOIN Matches m ON t.team_id = m.team1_id OR t.team_id = m.team2_id
GROUP BY t.team_id
ORDER BY points DESC, matches_played DESC;
```

---

## Step 5: CTE for Average Player Performance

**Average Runs & Wickets per Match for Each Player**

```sql
WITH PlayerMatchCounts AS (
    SELECT player_id, COUNT(*) AS matches_played
    FROM Stats
    GROUP BY player_id
)
SELECT
    p.player_name,
    t.team_name,
    SUM(s.runs_scored) / pmc.matches_played AS avg_runs,
    SUM(s.wickets_taken) / pmc.matches_played AS avg_wickets
FROM
    Stats s
    JOIN Players p ON s.player_id = p.player_id
    JOIN Teams t ON p.team_id = t.team_id
    JOIN PlayerMatchCounts pmc ON s.player_id = pmc.player_id
GROUP BY s.player_id;
```

---

## Step 6: Export Team Performance Reports

**Export Example (You can use `SELECT ... INTO OUTFILE` in MySQL):**

```sql
SELECT
    t.team_name,
    SUM(CASE WHEN t.team_id = m.team1_id THEN m.team1_score
             WHEN t.team_id = m.team2_id THEN m.team2_score
             ELSE 0 END) AS total_runs_scored,
    COUNT(m.match_id) AS matches_played
FROM
    Teams t
    LEFT JOIN Matches m ON t.team_id = m.team1_id OR t.team_id = m.team2_id
GROUP BY t.team_id
INTO OUTFILE '/tmp/team_performance.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';
```

---

## Deliverables

- **Schema**: DDL for all tables.
- **Sample Data**: Provided INSERT statements.
- **Queries**: For match results, player scores, leaderboards.
- **Views**: Player leaderboard, points table.
- **CTE**: For average player performance.
- **Export**: SQL example for exporting team performance report.

---

