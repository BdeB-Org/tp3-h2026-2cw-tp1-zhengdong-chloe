-- Boutique de Guitare — Package FABRICANTS
CREATE OR REPLACE PACKAGE pkg_fabricants AS
    ex_not_found     EXCEPTION; PRAGMA EXCEPTION_INIT(ex_not_found,     -20001);
    ex_invalid_input EXCEPTION; PRAGMA EXCEPTION_INIT(ex_invalid_input, -20002);
    C_ERR_NOT_FOUND     CONSTANT PLS_INTEGER := -20001;
    C_ERR_INVALID_INPUT CONSTANT PLS_INTEGER := -20002;
    PROCEDURE get_all;
    PROCEDURE get_by_id(p_id IN fabricants.id_manu%TYPE);
    PROCEDURE create_one(p_nom IN fabricants.nom_manu%TYPE, p_tel IN fabricants.telephone%TYPE DEFAULT NULL);
    PROCEDURE update_one(p_id IN fabricants.id_manu%TYPE, p_nom IN fabricants.nom_manu%TYPE, p_tel IN fabricants.telephone%TYPE DEFAULT NULL);
    PROCEDURE delete_one(p_id IN fabricants.id_manu%TYPE);
END pkg_fabricants;
/

CREATE OR REPLACE PACKAGE BODY pkg_fabricants AS

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
            RAISE_APPLICATION_ERROR(-20002,'Le nom du fabricant est obligatoire.');
        END IF;
    END;

    PROCEDURE p_write(p_rec IN fabricants%ROWTYPE) IS
    BEGIN
        APEX_JSON.OPEN_OBJECT;
        APEX_JSON.WRITE('id_manu',  p_rec.id_manu);
        APEX_JSON.WRITE('nom_manu', p_rec.nom_manu);
        APEX_JSON.WRITE('telephone',p_rec.telephone);
        APEX_JSON.CLOSE_OBJECT;
    END;

    PROCEDURE get_all IS
        v_n NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_n FROM fabricants;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success'); APEX_JSON.WRITE('count',v_n);
        APEX_JSON.OPEN_ARRAY('items');
        FOR r IN (SELECT * FROM fabricants ORDER BY nom_manu) LOOP p_write(r); END LOOP;
        APEX_JSON.CLOSE_ARRAY; APEX_JSON.CLOSE_OBJECT;
    EXCEPTION WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE get_by_id(p_id IN fabricants.id_manu%TYPE) IS
        v_rec fabricants%ROWTYPE;
    BEGIN
        SELECT * INTO v_rec FROM fabricants WHERE id_manu = p_id;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','success');
        APEX_JSON.OPEN_OBJECT('item'); p_write(v_rec); APEX_JSON.CLOSE_OBJECT;
        APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN p_err(-20001,'Fabricant introuvable.');
        WHEN OTHERS THEN p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE create_one(p_nom IN fabricants.nom_manu%TYPE, p_tel IN fabricants.telephone%TYPE DEFAULT NULL) IS
        v_id fabricants.id_manu%TYPE;
    BEGIN
        p_validate(p_nom);
        INSERT INTO fabricants(nom_manu,telephone) VALUES(TRIM(p_nom),NULLIF(TRIM(p_tel),'')) RETURNING id_manu INTO v_id;
        COMMIT;
        OWA_UTIL.STATUS_LINE(201,'Created',FALSE);
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','created'); APEX_JSON.WRITE('id_manu',v_id); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_invalid_input THEN p_err(-20002,'Le nom du fabricant est obligatoire.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE update_one(p_id IN fabricants.id_manu%TYPE, p_nom IN fabricants.nom_manu%TYPE, p_tel IN fabricants.telephone%TYPE DEFAULT NULL) IS
        v_rows NUMBER;
    BEGIN
        p_validate(p_nom);
        UPDATE fabricants SET nom_manu=TRIM(p_nom), telephone=NULLIF(TRIM(p_tel),'') WHERE id_manu=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20001,'Fabricant introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','updated'); APEX_JSON.WRITE('rows_updated',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20001,'Fabricant introuvable.');
        WHEN ex_invalid_input THEN p_err(-20002,'Le nom du fabricant est obligatoire.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

    PROCEDURE delete_one(p_id IN fabricants.id_manu%TYPE) IS
        v_rows NUMBER;
    BEGIN
        DELETE FROM fabricants WHERE id_manu=p_id;
        v_rows := SQL%ROWCOUNT; COMMIT;
        IF v_rows = 0 THEN RAISE_APPLICATION_ERROR(-20001,'Fabricant introuvable.'); END IF;
        APEX_JSON.OPEN_OBJECT; APEX_JSON.WRITE('status','deleted'); APEX_JSON.WRITE('rows_deleted',v_rows); APEX_JSON.CLOSE_OBJECT;
    EXCEPTION
        WHEN ex_not_found THEN p_err(-20001,'Fabricant introuvable.');
        WHEN OTHERS THEN ROLLBACK; p_err(-20099,'Erreur : '||SQLERRM);
    END;

END pkg_fabricants;
/
SELECT object_name, object_type, status FROM user_objects WHERE object_name='PKG_FABRICANTS' ORDER BY object_type;
