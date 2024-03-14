CREATE OR REPLACE FUNCTION Monthly_salary() RETURNS TRIGGER AS $$
DECLARE
    v_driver_fname VARCHAR(50); 
    v_driver_lname VARCHAR(50);
    v_driver_ID INT;
    v_last_change_date DATE := OLD.pay_date;
    v_total_distance DECIMAL(13, 2);
    v_monthly_payment DECIMAL(10, 2);
BEGIN
    SELECT SUM(Distance), F_name, L_name, ID INTO v_total_distance, v_driver_fname, v_driver_lname, v_driver_ID
    FROM TRIP
    WHERE Driver_ID = NEW.ID
        AND Trip_Date >= DATE_TRUNC('month', OLD.pay_date);

    v_monthly_payment := v_total_distance * 5000; -- 5000 tomans for each killometer

    INSERT INTO monthly_payment (F_name, L_name, pay_date, Amount, ID)
    VALUES (v_driver_fname, v_driver_lname, CURRENT_DATE, v_monthly_payment, v_driver_ID);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER MonthlySalary
AFTER INSERT OR DELETE OR UPDATE ON monthly_payment
WHEN (EXTRACT(day FROM current_date) = 1)
EXECUTE FUNCTION Monthly_salary();




ALTER TABLE PASSENGER
ADD CONSTRAINT check_age_gt_15 CHECK (age >= 15);


CREATE OR REPLACE FUNCTION get_max_capacity(trip_id INT)
RETURNS NUMERIC AS
$$
DECLARE
    max_capacity NUMERIC;
BEGIN
    SELECT V.Capacity
    INTO max_capacity
    FROM Trip_load TL
    JOIN TRIP TR ON TL.Trip_ID = TR.Trip_ID
    JOIN Driver D ON TR.Driver_ID = D.ID
    JOIN VEHICHLE V ON D.ID = V.Driver_ID
    WHERE TL.Trip_ID = trip_id;

    RETURN max_capacity;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE Trip_load
ADD CONSTRAINT check_weight CHECK (Weight <= get_max_capacity(Trip_ID));




CREATE OR REPLACE FUNCTION Charging_wallet()
RETURNS TRIGGER AS
$BODY$
DECLARE
BEGIN
    IF NEW.Status = TRUE AND OLD.Status <> TRUE THEN
		UPDATE User_Wallet
		SET Balance = Balance + NEW.Amount
		WHERE ID = NEW.User_ID;
    END IF;

    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;



CREATE TRIGGER Charging_UserWallet
AFTER UPDATE ON User_Transaction
FOR EACH ROW
EXECUTE PROCEDURE Charging_wallet();


CREATE OR REPLACE FUNCTION check_password_expiry_function() RETURNS TRIGGER AS $$
DECLARE
    v_last_change_date DATE;
    v_current_date DATE := CURRENT_DATE;
BEGIN
    SELECT Check_password INTO v_last_change_date
    FROM EMPLOYEE
    WHERE ID = NEW.ID;

    IF v_last_change_date IS NOT NULL THEN
        IF OLD.password <> NEW.password THEN
            NEW.Check_password := v_current_date;
        ELSIF EXTRACT(MONTH FROM AGE(v_current_date, v_last_change_date)) >= 2 THEN
            RAISE EXCEPTION 'Password has not been changed for two months or more.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_password_expiry
AFTER INSERT OR UPDATE ON EMPLOYEE
FOR EACH ROW
EXECUTE FUNCTION check_password_expiry_function();

CREATE OR REPLACE VIEW SubsetDriverInfo AS
SELECT D.F_name, D.L_name, D.ID AS Driver_ID
FROM Driver D JOIN Subset S ON D.ID = S.Invited;
	
	
CREATE OR REPLACE VIEW PROGRAMMERS AS
SELECT E.L_name, E.F_name, E.ID
FROM EMPLOYEE E
WHERE Position_dept = 'PROGRAMMER';


CREATE OR REPLACE VIEW WOMEN_DRIVERS AS
SELECT D.L_name, D.F_name, D.ID
FROM Driver D
WHERE D.service_type = 'B_WOMEN';


CREATE OR REPLACE VIEW Driver_Transaction_View AS
SELECT D.L_name, D.F_name, Tr.Driver_ID, Tr.Transaction_Type, Tr.Amount, Tr.T_Date, Tr.Transaction_Time, Tr.Status
FROM Driver_Transaction Tr JOIN Driver D ON D.ID = Tr.Driver_id;

CREATE OR REPLACE VIEW Passenger_trans_View AS
SELECT 
FROM PASSENGER P, User_Transaction U, UserToDriverTransaction UT
WHERE P.ID = U.User_ID AND P.ID = UT.User_ID;



CREATE OR REPLACE VIEW DriverTrips AS
SELECT D.F_name || ' ' || D.L_name AS Driver_Name, T.Trip_ID, T.Trip_Date, T.Time_start, T.Distance, T.Wait_time, T.Start_location, T.Time_end, T.Canceled
FROM Driver D
JOIN TRIP T ON D.ID = T.Driver_ID;


CREATE OR REPLACE FUNCTION ban_for_debt()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Driver_ID IS NOT NULL THEN
        SELECT Amount INTO NEW.Amount
        FROM Driver_Wallet
        WHERE ID = NEW.Driver_ID;

        IF NEW.Amount <= -50000 THEN
            RAISE EXCEPTION 'Driver with insufficient balance cannot be inserted into TRIP table.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER check_driver_balance_trigger
BEFORE INSERT ON TRIP
FOR EACH ROW
EXECUTE FUNCTION ban_for_debt();

CREATE OR REPLACE FUNCTION take_commision()
RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.Status = TRUE THEN
        INSERT INTO Baxi_wallet (T_Date, Amount, Status, Payed, T_Time, Trip_ID, Driver_ID)
        VALUES (CURRENT_DATE, NEW.Amount, NEW.Status, TRUE, CURRENT_TIME, NEW.Trip_ID, NEW.Driver_ID);
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pay_driver()
RETURNS TRIGGER AS
$BODY$
DECLARE
    v_new_balance DECIMAL(10, 2);
BEGIN
    IF NEW.Status = TRUE AND OLD.Status <> TRUE THEN
        CASE
            WHEN NEW.Pay_type = 'TRANSACTION' THEN
                v_new_balance := NEW.Amount * 0.8;
                UPDATE Driver_Wallet
                SET Balance = Balance + v_new_balance
                WHERE ID = NEW.Driver_ID;
            WHEN NEW.Pay_type = 'CASH' THEN
                v_new_balance := NEW.Amount * 0.2;
                UPDATE Driver_Wallet
                SET Balance = Balance - v_new_balance
                WHERE ID = NEW.Driver_ID;
        END CASE;
    END IF;

    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION takeFromUserWallet()
RETURNS TRIGGER AS
$BODY$
DECLARE
BEGIN
    IF NEW.Status = TRUE AND OLD.Status <> TRUE AND NEW.Pay_type = 'CASH' THEN
		UPDATE User_Wallet
		SET Balance = Balance - NEW.Amount
		WHERE ID = NEW.User_ID;
    END IF;

    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION trip_payment()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF NEW.Status = TRUE AND OLD.Status <> TRUE THEN
        PERFORM take_commision();
        PERFORM pay_driver();
        PERFORM takeFromUserWallet();
    END IF;
    RETURN NEW;
END;
$$;



CREATE TRIGGER baxi_commision
AFTER UPDATE ON UserToDriverTransaction
FOR EACH ROW
EXECUTE PROCEDURE trip_payment();


CREATE OR REPLACE FUNCTION check_banned()
RETURNS TRIGGER AS $$
BEGIN
    DECLARE
        v_ssn_exists BOOLEAN;
    BEGIN
        SELECT TRUE
        INTO v_ssn_exists
        FROM Driver D
        JOIN BLACK_LIST B ON B.SSN = D.SSN
        WHERE NEW.Driver_ID = D.ID;

        IF v_ssn_exists THEN
            RAISE EXCEPTION 'The driver with SSN % has been violated and cannot register.', NEW.SSN;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION Check_information()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT *
        FROM CHECK_INF CI
        WHERE CI.Driver_ID = NEW.Driver_ID
          AND (CI.ChechForCriminal_Record <> TRUE OR CI.checkForCertificate <> TRUE OR CI.CheckCarCard <> TRUE OR CI.CheckForSSN <> TRUE OR CI.CheckForShaba <> TRUE  )
    ) THEN
        RAISE EXCEPTION 'The driver registration is not completed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_every_thing()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM check_banned();
	PERFORM Check_information();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trip_requirement
BEFORE INSERT ON Trip
FOR EACH ROW
EXECUTE FUNCTION check_every_thing();

CREATE OR REPLACE FUNCTION update_password_date()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.password <> OLD.password THEN
        NEW.Check_password := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_password_changed
BEFORE UPDATE ON EMPLOYEE
FOR EACH ROW
EXECUTE FUNCTION update_password_date();

