--
-- db2 -td"@" -f p2.sql
--
CONNECT TO CS157A@
--
--
drop procedure P2.CUST_CRT@
drop procedure P2.CUST_LOGIN@
drop PROCEDURE P2.ACCT_OPN@
drop PROCEDURE p2.ACCT_CLS@
drop PROCEDURE p2.ACCT_DEP@
drop PROCEDURE p2.ACCT_WTH@
drop PROCEDURE p2.ACCT_TRX@
drop PROCEDURE p2.ADD_INTEREST@

CREATE PROCEDURE P2.CUST_CRT
(IN username varchar(15), IN gender CHAR, IN age INTEGER, IN pin INTEGER, OUT ID INTEGER, OUT sql_code varchar(20), OUT err_msg varchar(20))
Language SQL 
    BEGIN 
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        IF age < 0 THEN 
            set err_msg = 'Age must be postive';
            return;
        END if;
        Insert into P2.CUSTOMER(name, gender, age, pin) values(username, gender, age, p2.encrypt(pin));
        SET ID = (select ID from p2.CUSTOMER where name = username and gender = gender and age = age);
        SET sql_code = sqlstate;
        IF sql_code != 00000 THEN 
            SET err_msg = 'Error in creating customer';
        End IF;
END @

CREATE PROCEDURE P2.CUST_LOGIN 
(IN ID integer, IN Pin_s integer, OUT Valid integer, OUT sql_code varchar(20), OUT err_msg varchar(20))
LANGUAGE SQL
    BEGIN
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DEClARE pin_ integer DEFAULT 0;
        DECLARE id_ integer DEFAULT 0;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        set pin_ = (Select pin from p2.Customer where id = ID and pin = p2.encrypt(Pin_s));
        set id_ = (Select ID from p2.customer where id = ID and pin = p2.encrypt(Pin_s));
        If Pin_s = p2.decrypt(pin_) AND id_ = ID THEN
            set valid = 1;
            set err_msg = 'Right credentials';
        else 
            set valid = 0;
            set err_msg = 'Wrong credentials';
        END if;
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in logging in';
        end if;
END @

CREATE PROCEDURE p2.ACCT_OPN 
(IN ID integer, IN balance INTEGER, In type_ VARCHAR(20), OUT Num INTEGER, OUT sql_code varchar(20), OUT err_msg varchar(20))
LANGUAGE SQL 
    BEGIN 
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        if balance < 0 or type_ not in ('C', 'c', 'S', 's') THEN
            set err_msg = 'Invalid input';
        END if;
        Insert into P2.account(ID, Balance, Type, Status) values (ID, balance, type_, 'A');
        set Num = (select Number from P2.account where id = ID limit 1);
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in opening account';
        end if;
END @

CREATE PROCEDURE p2.ACCT_CLS
(IN num integer, OUT sql_code varchar(20), OUT err_msg VARCHAR(20))
LANGUAGE SQL
    BEGIN 
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        Update P2.account set status = 'I', balance = 0 where number = num;
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in closing account';
        END if;
END @

CREATE PROCEDURE p2.ACCT_DEP
(IN num integer, IN amt integer, OUT sql_code varchar(20), out err_msg varchar(20))
LANGUAGE SQL 
    BEGIN
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        if amt < 0 THEN 
            set err_msg = 'Amt must be postive';
            return;
        end if;
        Update P2.account set Balance = Balance + amt where Number = num and status = 'A';
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in depositing';
        END if;
END @

CREATE PROCEDURE p2.ACCT_WTH
(IN num integer, IN amt integer, OUT sql_code varchar(20), out err_msg varchar(20))
LANGUAGE SQL 
    BEGIN
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE total_balance INTEGER DEFAULT 0;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        Update P2.account set Balance = Balance - amt where Number = num and status = 'A';
        set total_balance = (select balance from p2.account where Number = num and status = 'A');
        if total_balance < 0 or amt < 0 THEN 
            set err_msg = 'Overdrawn';
            return;
        end if;
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in withdrawing';
        END if;
END @


CREATE PROCEDURE p2.ACCT_TRX
(IN src_acct integer, IN dest_acct integer, IN amt integer, OUT sql_code varchar(20), OUT err_msg varchar(20))
LANGUAGE SQL
    BEGIN
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE sql_code varchar(20);
        DECLARE err_msg VARCHAR(20);
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        call p2.ACCT_WTH(src_acct, amt, sql_code, err_msg);
        call p2.ACCT_DEP(dest_acct, amt, sql_code, err_msg);
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in transferring';
        END if;
END @

CREATE PROCEDURE p2.ADD_INTEREST
(IN savings_rate float, IN checking_rate float, OUT sql_code varchar(20), OUT err_msg varchar(20))
LANGUAGE SQL
    BEGIN
        DECLARE SQLSTATE CHAR(5);
        DECLARE error_cond CONDITION FOR SQLSTATE '22001';
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SET err_msg = 'Invalid input';
        update p2.account set balance = (1 + checking_rate) * balance where type = 'C' and status = 'A';
        update p2.account set balance = (1 + savings_rate) * balance where type = 'S' and status = 'A';
        set sql_code = sqlstate;
        if sql_code != 00000 THEN 
            set err_msg = 'Error in transferring';
        END if;
END @
--
TERMINATE@
--
--
