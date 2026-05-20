-- Boutique de Guitare — Package CLIENTS
CREATE OR REPLACE PACKAGE pkg_clients AS
    ex_not_found     EXCEPTION; PRAGMA EXCEPTION_INIT(ex_not_found,     -20011);
    ex_invalid_input EXCEPTION; PRAGMA EXCEPTION_INIT(ex_invalid_input, -20012);
    C_ERR_NOT_FOUND     CONSTANT PLS_INTEGER := -20011;
    C_ERR_INVALID_INPUT CONSTANT PLS_INTEGER := -20012;
    PROCEDURE get_all;
    PROCEDURE get_by_id(p_id IN clients.id_client%TYPE);
    PROCEDURE create_one(p_nom IN clients.nom_client%TYPE, p_tel IN clients.telephone%TYPE DEFAULT NULL, p_address IN clients.address%TYPE DEFAULT NULL);
    PROCEDURE update_one(p_id IN clients.id_client%TYPE, p_nom IN clients.nom_client%TYPE, p_tel IN clients.telephone%TYPE DEFAULT NULL, p_address IN clients.address%TYPE DEFAULT NULL);
    PROCEDURE delete_one(p_id IN clients.id_client%TYPE);
END pkg_clients;
/

CREATE OR REPLACE PACKAGE BODY pkg_clients AS

    PROCEDURE p_err(p_code IN PLS_INTEGER, p_msg IN VARCHAR2) IS
    BEGIN
        OWA_UTIL.STATUS_LINE(400,'Bad Request',FALSE);
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('status','error'); APEX_JSON.WRITE('code',p_code); APEX_JSON.WRITE('message',p_msg);
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE p_validate(p_nom IN VARCHAR2) IS
    BEGIN
        IF p_nom IS NULL OR LENGTH(TRIM(p_nom)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20012,'Le nom du client est obligatoire.');
        END IF;
    END;

    PROCEDURE p_write(p_rec IN clients%ROWTYPE) IS
    BEGIN
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('id_client', p_rec.id_client);
        APEX_JSON.WRITE('nom_client',p_rec.nom_client);
        APEX_JSON.WRITE('telephone', p_rec.telephone);
        APEX_JSON.WRITE('address',   p_rec.address);
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE get_all IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM clients;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success'); APEX_JSON.WRITE('count',v_n);
        APEX_JSON.OPEN_ARRAY('items');
        FOR r IN (SELECT * FROM clients ORDER BY nom_client) LOOP p_write(r); END LOOP;
        APEX_JSON.CLOSE_ARRAY; APEX_JSON.CLOSE_OBJECT;
    EXCEPTION WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE get_by_id(p_id IN clients.id_client%TYPE) IS
        v_rec clients%ROWTYPE;
    BEGIN
        SELECT * INTO v_rec FROM clients WHERE id_client = p_id;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success');
        APEX_JSON.OPEN_OBJECT('item'); p_write(v_rec); APEX_JSON.CLOSE_OBJECT;
        APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN p_err(-20011,'Client introuvable.');
        WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE create_one(p_nom IN clients.nom_client%TYPE, p_tel IN clients.telephone%TYPE DEFAULT NULL, p_address IN clients.address%TYPE DEFAULT NULL) IS
        v_id clients.id_client%TYPE;
    BEGIN
        p_validate(p_nom);
        INSERT INTO clients(nom_client,telephone,address)
        VALUES(TRIM(p_nom),NULLIF(TRIM(p_tel),''),NULLIF(TRIM(p_address),'')) RETURNING id_client INTO v_id;
        COMMIT;
        OWA_UTIL.STATUS_LINE(201,'Created',FALSE);
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','created'); APEX_JSON.WRITE('id_client',v_id); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_invalid_input THEN p_err(-20012,'Le nom du client est obligatoire.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE update_one(p_id IN clients.id_client%TYPE, p_nom IN clients.nom_client%TYPE, p_tel IN clients.telephone%TYPE DEFAULT NULL, p_address IN clients.address%TYPE DEFAULT NULL) IS
        v_rows NUMBER;
    BEGIN
        p_validate(p_nom);
        UPDATE clients SET nom_client=TRIM(p_nom), telephone=NULLIF(TRIM(p_tel),''), address=NULLIF(TRIM(p_address),'')
        WHERE id_client=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20011,'Client introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','updated'); APEX_JSON.WRITE('rows_updated',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20011,'Client introuvable.');
        WHEN ex_invalid_input THEN p_err(-20012,'Le nom du client est obligatoire.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE delete_one(p_id IN clients.id_client%TYPE) IS
        v_rows NUMBER;
    BEGIN
        DELETE FROM clients WHERE id_client=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20011,'Client introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','deleted'); APEX_JSON.WRITE('rows_deleted',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20011,'Client introuvable.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

END pkg_clients;
/
SELECT object_name, object_type, status FROM user_objects WHERE object_name='PKG_CLIENTS' ORDER BY object_type;
