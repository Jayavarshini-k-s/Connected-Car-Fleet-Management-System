PROMPT '--- Main Menu ---'
PROMPT '1. Execute Function A'
PROMPT '2. Execute Function B'
ACCEPT user_choice CHAR PROMPT 'Enter your choice (1 or 2): '

COLUMN script_to_run NEW_VALUE v_script_name NOPRINT
SELECT
    CASE '&user_choice.'
        WHEN '1' THEN 'function_a_script.sql'
        WHEN '2' THEN 'function_b_script.sql'
        ELSE 'invalid_input.sql'
    END AS script_to_run
FROM DUAL;

CREATE table Vehicle(
    VIN NUMBER PRIMARY KEY, 
    Manfacturer VARCHAR(50),
    Model_ VARCHAR(50),
    FleetID NUMBER,
    Owner_ VARCHAR(50),
    Registration_status VARCHAR(50)
    );
    
DROP TABLE Vehicle;

--CREATE table Telemetry(
--    latitude NUMBER,
--    longitude NUMBER,
--    Speed NUMBER,
--    Engine_status VARCHAR(5),
--    Fuel_Battery_level NUMBER,
--    Odometer_reading NUMBER,
--    Diagnostic_codes VARCHAR(50),
--    Timestamp_reading TIMESTAMP
--    );
    
--CREATE table Analytics(
--    Active_vehicles NUMBER,
--    Inactive_vehicles NUMBER,
--    Average_fuel_battery_levels NUMBER,
--    Alert_summary NUMBER
--    );
    
CREATE table Vehicle_generated(
    VIN NUMBER, 
    latitude NUMBER,
    longitude NUMBER,
    Speed NUMBER,
    Engine_status VARCHAR(5),
    Fuel_Battery_level NUMBER,
    Odometer_reading NUMBER,
    Diagnostic_codes VARCHAR(50),
    Timestamp_reading TIMESTAMP
);
DROP table Vehicle_generated;
    
CREATE table Alert_system(
    Speed_violations VARCHAR(50),
    Low_fuel_battery VARCHAR(30)
);

CREATE TABLE engine_status (
    id NUMBER PRIMARY KEY,
    status VARCHAR2(100)
);

CREATE TABLE alert_summary(
    vin NUMBER,
    alert_speed BOOLEAN,
    alert_fuel BOOLEAN
);
    
INSERT INTO engine_status (id, status) VALUES (1, 'ON');
INSERT INTO engine_status (id, status) VALUES (2, 'OFF');
INSERT INTO engine_status (id, status) VALUES (3, 'IDLE');

---Inserting
INSERT INTO Vehicle VALUES(1, 'Tesla', 'model1', 1, 'Person1', 'Active');
INSERT INTO Vehicle VALUES(2, 'BMW', 'model2', 3, 'Person2', 'Decommissioned');

-- Listing
SELECT * from vehicle;

--query
SELECT * from vehicle where VIN=1;

-- Deleting vehicle
DELETE FROM Vehicle Where VIN=1;
-- Testing
--vin := 1;
--latitude := 'SELECT DBMS_RANDOM.VALUE(0,90)';
--longitude := 'SELECT DBMS_RANDOM.VALUE(0,90)';
--speed := 'SELECT DBMS_RANDOM.VALUE(0,700)';
--Engine_status := 'SELECT status FROM engine_status where id = DBMS_RANDOM.VALUE(1,(SELECT COUNT(*) FROM engine_status)';
--Fuel_battery_level := 'SELECT DBMS_RANDOM.VALUE(0,100)';
--Odometer_reading := 'SELECT DBMS_RANDOM.VALUE(0,1000)';
--Diagnostic_codes := 'SELECT DBMS_RANDOM.VALUE(1,5)';
--timestamp_reading := CURRENT_TIMESTAMP;

--INSERT INTO Vehicle_generated VALUES(vin, latitude, longitude, speed, Engine_status, Fuel_battery_level, Odometer_reading, Diagnostic_codes, timestamp_reading);


--CREATE OR REPLACE PROCEDURE count_active
--IS
--    
--BEGIN
--    DBMS_OUTPUT.PUT_LINE(

-- Calculate active vehicles
FUNCTION calculate_active RETURN NUMBER IS
    v_active_count NUMBER;
BEGIN
    SELECT COUNT(*) FROM Vehicle_generated INTO v_active_count 
        where timestamp_generated < SYSTIMESTAMP - INTERVAL '1' MINUTE;
        
    RETURN v_active_count
END calculate_active;

--Calculate inactive vehicles
FUNCTION calculate_active RETURN NUMBER IS
    v_inactive_count NUMBER;
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM Vehicle_generated INTO v_inactive_count 
        where timestamp_generated < SYSTIMESTAMP - INTERVAL '1' MINUTE)
        -
        (SELECT COUNT(*) FROM Vehicle) 
    FROM dual INTO v_inactive_count;
    
    RETURN v_inactive_count;
END;
    
--Calculate Average fuel or battery levels
FUNCTION calculate_average_fuel_battery RETURN NUMBER IS
    avg_level NUMBER;
BEGIN
    SELECT avg(Fuel_Battery_level) INTO avg_level FROM Vehicle_generated;
    
    RETURN avg_level;
END;
-- Calculate Total distance traveled
FUNCTION total_distance RETURN NUMBER IS
    total_dist NUMBER;
BEGIN
    SELECT sum(Odometer_reading) INTO total_dist FROM Vehicle_generated
        where (SELECT timestamp_reading - INTERVAL '1' HOUR FROM dual) < 0
    RETURN total_dist;
    
END;

--Calculate alert summary
FUNCTION calculate_alert_summary(vin NUMBER) IS
    alert_speed BOOLEAN;
    alert_fuel BOOLEAN;
BEGIN
    alert_speed := speed_violation(vin);
    alert_fuel:= low_fuel_battery(vin);
    
    INSERT INTO alert_summary VALUES(vin,alert_speed,alert_fuel);
END;

FUNCTION count_alert_summart IS
    speed_count NUMBER;
    fuel_count NUMBER;
BEGIN
    speed_count := 'SELECT count(*) FROM alert_summary where alert_speed=1';

    fuel_count := 'SELECT count(*) FROM alert_summary where alert_fuel=1';
    DBMS_OUTPUT.PUT_LINE(speed_count);
    DBMS_OUTPUT.PUT_LINE(fuel_count);
END;
-- Alert
FUNCTION speed_violation(vin NUMBER) RETURN BOOLEAN IS
    l_result_speed NUMBER;
BEGIN
    l_result:= 'SELECT Speed FROM Vehicle_generated where VIN=vin';
    IF l_result_speed > 120 THEN
        RETURN 1
    ELSE
        RETURN 0
    END IF
END;

FUNCTION low_fuel_battery(vin NUMBER) RETURN BOOLEAN IS
    l_result_fuel NUMBER;
BEGIN
    l_result_fuel:= 'SELECT Fuel_Battery_level FROM Vehicle_generated where VIN=vin';
    IF l_result_fuel > 15 THEN
        RETURN 1
    ELSE
        RETURN 0
    END IF
END;
-- Generate Vehicles
-- CREATE OR REPLACE FUNCTION data_generator_api AS
--         vin := generate_Vehicle_telemetry();
--         generate_telemetry(vin);
--     END data_generator_api;
--     /

CREATE OR REPLACE FUNCTION data_generator_api AS
    FUNCTION generate_Vehicle RETURN NUMBER IS
        v_sql NUMBER;
    BEGIN
        v_sql := 'SELECT VIN FROM VEHICLE ORDER BY DBMS_RANDOM.VALUE FETCH NEXT 1 ROWS ONLY';
        RETURN v_sql;
    END generate_Vehicle;

    FUNCTION generate_telemetry(vin IN NUMBER) IS
        vin NUMBER;
        latitude NUMBER;
        longitude NUMBER;
        speed NUMBER;
        Engine_status VARCHAR(5);
        Fuel_battery_level NUMBER;
        Odometer_reading NUMBER;
        Diagnostic_codes VARCHAR(50);
        Timestamp_reading TIMESTAMP;
    BEGIN
        vin := generate_Vehicle();
        latitude := DBMS_RANDOM.VALUE(0,90);
        longitude := 'SELECT DBMS_RANDOM.VALUE(0,90)';
        speed := 'SELECT DBMS_RANDOM.VALUE(0,700)';
        Engine_status := 'SELECT status FROM engine_status where id = DBMS_RANDOM.VALUE(1,(SELECT COUNT(*) FROM engine_status)';
        Fuel_battery_level := 'SELECT DBMS_RANDOM.VALUE(0,100)';
        Odometer_reading := 'SELECT DBMS_RANDOM.VALUE(0,1000)';
        Diagnostic_codes := 'SELECT DBMS_RANDOM.VALUE(1,5)';
        Timestamp_reading := CURRENT_TIMESTAMP;
        
        INSERT INTO Vehicle_generated VALUES(vin, latitude, longitude, speed, Engine_status, Fuel_battery_level, Odometer_reading, Diagnostic_codes, timestamp_reading);
    END generate_random_number;
END data_generator_api;
    
    
