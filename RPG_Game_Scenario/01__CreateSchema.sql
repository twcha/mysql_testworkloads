# =============================================================
# Game Example Schema: character, item, log
# MySQL 8.4 (InnoDB, utf8mb4)
# Version history:
#   - v1.0 - 2026-06-19
# =============================================================

CREATE DATABASE gamedb_test;
USE  gamedb_test;

## =============================================================
## 01. Table Creation
## =============================================================

    ## -------------------------------------------------------------
    ## 01.01 Character Table
    ## -------------------------------------------------------------
    CREATE TABLE IF NOT EXISTS tbl_game_character (
        character_id    BIGINT          NOT NULL AUTO_INCREMENT  COMMENT 'Character Unique ID',
        nickname        VARCHAR(32)     NOT NULL                 COMMENT 'Character Name',
        job_code        VARCHAR(20)     NOT NULL                 COMMENT 'Job Code (WARRIOR, MAGE, etc)',
        level           INT             NOT NULL DEFAULT 1       COMMENT 'Level',
        exp             BIGINT          NOT NULL DEFAULT 0       COMMENT 'Experience Points',
        hp              INT             NOT NULL DEFAULT 100     COMMENT 'Current HP',
        mp              INT             NOT NULL DEFAULT 50      COMMENT 'Current MP',
        gold            BIGINT          NOT NULL DEFAULT 0       COMMENT 'Gold Owned',
        status          TINYINT         NOT NULL DEFAULT 1       COMMENT '0:deleted 1:active 2:suspended',
        created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id),
        UNIQUE  KEY uk_character_nickname (nickname)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Game Character';

    ## -------------------------------------------------------------
    ## 01.02. Item Master Table (Item Definition)
    ## -------------------------------------------------------------
    CREATE TABLE IF NOT EXISTS tbl_item_master (
        item_id         INT             NOT NULL AUTO_INCREMENT  COMMENT 'Item Master ID',
        item_name       VARCHAR(64)     NOT NULL                 COMMENT 'Item Name',
        item_type       VARCHAR(20)     NOT NULL                 COMMENT 'WEAPON, ARMOR, POTION, ETC',
        grade           VARCHAR(20)     NOT NULL DEFAULT 'NORMAL' COMMENT 'NORMAL, RARE, EPIC, LEGEND',
        max_stack       INT             NOT NULL DEFAULT 1       COMMENT 'Max Stack Quantity',
        buy_price       BIGINT          NOT NULL DEFAULT 0       COMMENT 'Buy Price (Gold)',
        sell_price      BIGINT          NOT NULL DEFAULT 0       COMMENT 'Sell Price (Gold)',
        created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (item_id),
        KEY     idx_item_type (item_type),
        KEY     idx_item_grade (grade)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Item Master';

    ## -------------------------------------------------------------
    ## 01.03. Character Item Table (Inventory)
    ## -------------------------------------------------------------
    CREATE TABLE IF NOT EXISTS tbl_character_item (
        inventory_id    BIGINT          NOT NULL AUTO_INCREMENT  COMMENT 'Inventory Slot ID',
        character_id    BIGINT          NOT NULL                 COMMENT 'Character ID',
        item_id         INT             NOT NULL                 COMMENT 'Item Master ID',
        quantity        INT             NOT NULL DEFAULT 1       COMMENT 'Quantity Owned',
        enhance_level   INT             NOT NULL DEFAULT 0       COMMENT 'Enhancement Level',
        is_equipped     TINYINT         NOT NULL DEFAULT 0       COMMENT '0:not equipped 1:equipped',
        acquired_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (inventory_id),
        KEY     idx_charitem_character_item_id (character_id,item_id)
        #CONSTRAINT fk_charitem_character FOREIGN KEY (character_id) REFERENCES tbl_game_character (character_id) ON DELETE CASCADE,
        #CONSTRAINT fk_charitem_item      FOREIGN KEY (item_id)      REFERENCES tbl_item_master (item_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Character Inventory';

    ## -------------------------------------------------------------
    ## 01.04. Action Log Table
    ## -------------------------------------------------------------
    CREATE TABLE IF NOT EXISTS tbl_action_log (
        log_id          BIGINT          NOT NULL AUTO_INCREMENT  COMMENT 'Log ID',
        character_id    BIGINT          NOT NULL                 COMMENT 'Character ID',
        action_type     VARCHAR(30)     NOT NULL                 COMMENT 'LOGIN, LOGOUT, LEVEL_UP, ITEM_GET, ITEM_USE, TRADE, etc',
        item_id         INT             NULL                     COMMENT 'Related Item (NULL if none)',
        amount          BIGINT          NULL                     COMMENT 'Change Quantity/Amount',
        detail          JSON            NULL                     COMMENT 'Additional Details',
        created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp',
        PRIMARY KEY (log_id),
        KEY     idx_log_character (character_id),
        KEY     idx_log_action (action_type),
        KEY     idx_log_created (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Character Action Log';

    ## -------------------------------------------------------------
    ## 01.05. tbl_numbers
    ## -------------------------------------------------------------

    CREATE  TABLE IF NOT EXISTS tbl_numbers
    SELECT  ROW_NUMBER() OVER(ORDER BY (SELECT NULL))  AS num
    FROM  INFORMATION_SCHEMA.COLUMNS C1
        ,   INFORMATION_SCHEMA.COLUMNS C2
    LIMIT  1000000
    ;

## =============================================================
## 02. Insert Test Data 
## =============================================================

    ## Create Characters (100,000 each for Warrior, Mage, Archer)
    # TRUNCATE TABLE tbl_game_character;
    INSERT  INTO tbl_game_character (nickname, job_code, level, gold)
    SELECT  CONCAT('Warrior_',RIGHT(CONCAT('0000000',CAST(num AS CHAR)),7)) AS nickname
        ,   'WARRIOR'   AS job_code
        ,   1           AS level
        ,   0           AS gold
    FROM  tbl_numbers
    ORDER  BY num
    LIMIT  100000
    ;
    
    INSERT  INTO tbl_game_character (nickname, job_code, level, gold)
    SELECT  CONCAT('Mage_',RIGHT(CONCAT('0000000',CAST(num AS CHAR)),7)) AS nickname
        ,   'MAGE'      AS job_code
        ,   1           AS level
        ,   0           AS gold
    FROM  tbl_numbers
    ORDER  BY num  
    LIMIT  100000
    ;
    
    INSERT  INTO tbl_game_character (nickname, job_code, level, gold)
    SELECT  CONCAT('Archer_',RIGHT(CONCAT('0000000',CAST(num AS CHAR)),7)) AS nickname
        ,   'ARCHER'      AS job_code
        ,   1           AS level
        ,   0           AS gold
    FROM  tbl_numbers
    ORDER  BY num  
    LIMIT  100000
    ;


    -- Create Items 
    INSERT  INTO tbl_item_master (item_name, item_type, grade, max_stack, buy_price, sell_price)
    VALUES  ('Long Sword'    , 'WEAPON'  ,   'RARE'  ,   1,  10000, 3000 )
        ,   ('Leather Armor' , 'ARMOR'   ,   'NORMAL',   1,  5000,  1500 )
        ,   ('Health Potion' , 'POTION'  ,   'NORMAL',   99, 100,   30   )
        ,   ('Legendary Bow' , 'WEAPON'  ,   'LEGEND',   1,  500000,0    )
        ,   ('Mana Potion'   , 'POTION'  ,   'NORMAL',   99, 120,   40   )
        ,   ('Steel Shield'  , 'ARMOR'   ,   'RARE'  ,   1,  15000, 4500 )
        ,   ('Magic Staff'   , 'WEAPON'  ,   'EPIC'  ,   1,  80000, 24000)
        ,   ('Iron Helmet'   , 'ARMOR'   ,   'NORMAL',   1,  3000,  900  )
        ,   ('Dragon Sword'  , 'WEAPON'  ,   'LEGEND',   1,  700000,0    )
        ,   ('Elixir'        , 'POTION'  ,   'EPIC'  ,   10, 5000,  1500 )
    ;

    -- Insert Character Inventory
        INSERT  INTO tbl_character_item
        (       character_id    
            ,   item_id         
            ,   quantity        
            ,   enhance_level   
            ,   is_equipped     
            ,   acquired_at     
        )
        SELECT  GC.character_id
            ,   EM.item_id
            ,   1 AS quantity
            ,   1 AS enhance_level
            ,   0 AS is_equipped
            ,   NOW()
          FROM  tbl_game_character AS GC
            ,   tbl_item_master    AS EM
         ORDER  BY
                RAND()
        ;

## =============================================================
## 03. Create Stored Procedures for Testing Concurrent Updates
## =============================================================
    DROP PROCEDURE IF EXISTS sp_test_item_update;
    DROP PROCEDURE IF EXISTS sp_test_item_update_outer;

    DELIMITER $$
    CREATE PROCEDURE sp_test_item_update()
    BEGIN
        DECLARE v_character_id    INT;
        DECLARE v_item_id         INT;
        DECLARE v_inventory_id    INT;
        DECLARE v_quantity_before INT;
        DECLARE v_DETAIL          JSON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        START  TRANSACTION;

            # 1. Select Character_ID and Item_ID for randomly.
            # EXPLAIN ANALYZE 
            SELECT  (CAST(CONNECTION_ID()*RAND() *1000000 AS UNSIGNED)%300000)+1 AS character_id
                ,   (CAST(CONNECTION_ID()*RAND() *1000000 AS UNSIGNED)%10)+1     AS item_id
            INTO  v_character_id , v_item_id
            ;

            # Get Invewtory ID and current quantity
            # EXPLAIN ANALYZE 
            SELECT  inventory_id
                ,   quantity
              INTO  v_inventory_id
                ,   v_quantity_before
              FROM  tbl_character_item 
             WHERE  character_id = v_character_id
               AND  item_id      = v_item_id
               FOR  UPDATE # WITH(UPDLOCK)        
            ;

            SET v_DETAIL = JSON_OBJECT  (       'inventory_id'      , v_inventory_id
                                            ,   'quantity_before'   , v_quantity_before
                                            ,   'quantity_after'    , v_quantity_before+1
                                            ,   'reason'            , 'test_grant'
                                            ,   'add_quantity'      , '1'
                                        )
            ;

            # Debug
            # SELECT  v_inventory_id, v_character_id, v_item_id, v_quantity_before;
            IF v_inventory_id IS NOT NULL THEN
                # Update quantity
                UPDATE  tbl_character_item
                   SET  quantity = quantity + 1
                 WHERE  character_id = v_character_id
                   AND  item_id      = v_item_id
                   AND  inventory_id = v_inventory_id
                ;
                
                -- 3) 변경 내용을 액션 로그에 기록
                INSERT  INTO tbl_action_log (character_id, action_type, item_id, amount, detail)
                VALUES  (       v_character_id
                            ,   'ITEM_GET'
                            ,   v_item_id
                            ,   1
                            ,   v_DETAIL
                        )
                ;
            END IF;
        COMMIT;
    END $$

    CREATE PROCEDURE sp_test_item_update_outer()
    BEGIN
        DECLARE v_i INT DEFAULT 0;
        # Run sp_test_item_update 100 times
        WHILE v_i < 100 DO
            CALL sp_test_item_update();
            SET v_i = v_i + 1;
        END WHILE;
    END $$
    DELIMITER ;


## =============================================================
## 04. Run Procedure Test ======================================
## =============================================================
    USE gamedb_test;

    CALL sp_test_item_update_outer();

    SELECT * FROM tbl_action_log ORDER BY log_id DESC LIMIT 100;



