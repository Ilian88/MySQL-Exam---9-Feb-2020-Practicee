CREATE SCHEMA `fsd`;

CREATE TABLE `countries`(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL
);

CREATE TABLE `towns` (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
country_id INT NOT NULL,

CONSTRAINT fk_towns_countries
FOREIGN KEY (country_id)
REFERENCES `countries`(id)
);

CREATE TABLE `stadiums`(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
capacity INT NOT NULL ,
town_id INT NOT NULL,

CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES `towns`(id)
);

CREATE TABLE `teams`(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT(20) NOT NULL DEFAULT 0,
stadium_id INT NOT NULL,

CONSTRAINT fk_teams_stadiums
FOREIGN KEY (stadium_id)
REFERENCES `stadiums`(id)
);

CREATE TABLE `skills_data`(
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT DEFAULT 0,
pace INT DEFAULT 0,
passing INT DEFAULT 0,
shooting INT DEFAULT 0,
speed INT DEFAULT 0,
strength INT DEFAULT 0
);

CREATE TABLE `coaches`(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
coach_level INT NOT NULL DEFAULT 0
);

CREATE TABLE `players`(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL DEFAULT 0,
position CHAR(1) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
hire_date DATETIME ,
skills_data_id INT NOT NULL,
team_id INT ,

CONSTRAINT fk_players_skills_data
FOREIGN KEY (skills_data_id)
REFERENCES skills_data(id),

CONSTRAINT fk_players_teams
FOREIGN KEY (team_id)
REFERENCES teams(id)
);

CREATE TABLE `players_coaches`(
player_id INT ,
coach_id INT,

CONSTRAINT pk_players_coaches
PRIMARY KEY (player_id,coach_id),

CONSTRAINT fk_players_coaches_players
FOREIGN KEY (player_id)
REFERENCES players(id),

CONSTRAINT fk_players_coaches_coaches
FOREIGN KEY (coach_id)
REFERENCES coaches(id)
);

#2
INSERT INTO coaches (first_name,last_name,salary,coach_level) 
(
SELECT p.first_name,p.last_name,p.salary * 2,CHAR_LENGTH(p.first_name)
FROM players AS p
WHERE p.age >=45
);

#3
UPDATE coaches AS c
JOIN players_coaches AS pc
ON c.id = pc.coach_id
SET coach_level = coach_level + 1
WHERE c.first_name LIKE 'A%';

#4
DELETE FROM players 
WHERE age >=45;

#5
SELECT first_name , age, salary
FROM players
ORDER BY salary DESC;

#6
SELECT e.id,CONCAT(e.first_name,' ',e.last_name) AS `full_name`,e.age,e.`position`,e.hire_date
FROM players AS e
JOIN skills_data AS sd
ON e.skills_data_id = sd.id
WHERE age < 23 AND position = 'A' AND hire_date IS NULL AND sd.strength > 50
ORDER BY salary , age;

#7
 SELECT t.`name` AS team_name , t.established,t.fan_base , COUNT(p.id) AS players_count
 FROM teams AS t
 LEFT JOIN players AS p
 ON t.id = p.team_id
 GROUP BY t.id
 ORDER BY players_count DESC , fan_base DESC;
 
 #8
 SELECT MAX(sd.speed) AS 'max_speed' , t.`name` AS 'town_name' 
FROM players AS p 
RIGHT JOIN skills_data AS sd ON p.skills_data_id = sd.id
RIGHT JOIN teams AS tm ON p.team_id = tm.id
RIGHT JOIN stadiums AS s ON tm.stadium_id = s.id
JOIN towns AS t ON s.town_id = town_id
 WHERE tm.`name` != 'Devify'
 GROUP BY t.id
 ORDER BY max_speed DESC , t.`name`;
 
 #9
 SELECT c.`name` , COUNT(p.id) AS total_count_of_players ,SUM(p.salary) AS total_sum_of_salaries
 FROM countries AS c 
 LEFT JOIN towns AS t
 ON c.id = t.country_id
 LEFT JOIN stadiums AS st
 ON t.id = st.town_id
 LEFT JOIN teams AS tm
 ON st.id = tm.stadium_id
 LEFT JOIN players AS p
 ON tm.id = p.team_id
 GROUP BY c.`name`
 ORDER BY total_count_of_players DESC , c.`name` ;
 
 #10
 DELIMITER $$
 CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
 RETURNS INT
 DETERMINISTIC
 BEGIN 
 DECLARE count INT ;
 SET  count := 
 (SELECT COUNT(p.id)
 FROM players AS p
 LEFT JOIN teams AS t
 ON p.team_id = t.id 
 LEFT JOIN stadiums AS st
 ON t.stadium_id = st.id
 GROUP BY st.`name`
 HAVING st.`name` = stadium_name
 );
 IF count IS NULL THEN RETURN 0;
 ELSE RETURN count;
 END IF;
 END$$
 
 #11
 DELIMITER $$
 CREATE PROCEDURE udp_find_playmaker(min_dribble_points INT , team_name VARCHAR(45))
 BEGIN
 SELECT CONCAT(p.first_name,' ',p.last_name)  AS full_name , p.age,p.salary,st.dribbling,st.speed,t.`name` AS 'team_name'
 FROM players AS p
 JOIN skills_data AS st
 ON p.skills_data_id = st.id
 JOIN teams AS t
 ON p.team_id = t.id
 WHERE t.`name` = 'Skyble' AND st.dribbling > 20 #AND st.speed > AVG(st.speed)
 GROUP BY p.`first_name`
 ORDER BY st.speed DESC 
 LIMIT 1;
 
 END$$
 
 CALL udp_find_playmaker (20, 'Skyble');