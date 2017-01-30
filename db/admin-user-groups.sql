--
-- User group table
--

CREATE TABLE user_group (
  `user_group_id` int NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Person user group mapping
--

CREATE TABLE person_user_group (
  `person_user_group_id` int NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `user_group_id` int NOT NULL,
  `pid` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

